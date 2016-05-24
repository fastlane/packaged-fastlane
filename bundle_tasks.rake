load './setup.rb'
load './bundle_dependency_tasks.rb'

module FastlaneRake
  include Rake::DSL
  def self.log(group, message)
    $stderr.puts "[#{Time.now.strftime('%T')}] [#{group}] #{message}"
  end

  def self.install_gem(name, version = nil, group = 'Gems')
    execute group, [BUNDLE_ENV, 'gem', 'install', name, ("--version=#{version}" if version), '--no-document', '--env-shebang'].compact
  end

  def self.install_local_fastlane
    fastlane_dir = ENV['LOCAL_FASTLANE_DIR']
    dot_gem = Dir["#{fastlane_dir}/fastlane-*.gem"][0]
    execute 'Gems', [BUNDLE_ENV, 'gem', 'install', dot_gem, '--no-document', '--env-shebang'].compact
  end

  def self.execute(group, command, output_file = nil)
    command.map!(&:to_s)
    log_command(group, command, output_file)

    if output_file
      out = File.open(output_file, 'a')
    end
    if VERBOSE
      out ||= $stdout
      err = $stderr
    else
      err = File.open("/tmp/fabric-app-bundle-build-#{Process.pid}", 'w+')
      out ||= err
    end
    command << { :out => out, :err => err }

    Process.wait(Process.spawn(*command))
    unless $?.success?
      unless VERBOSE
        out.rewind
        $stderr.puts(out.read)
      end
      exit $?.exitstatus
    end
  ensure
    out.close if out && output_file
    err.close if err && !VERBOSE
  end

  def self.log_command(group, command, output_file)
    command_for_presentation = command.map do |component|
      if component.include?('=')
        key, value = component.split('=', 2)
        # Add extra quotes around values of key=value pairs
        %{#{key}="#{value}"}
      else
        component
      end
    end
    wd = Dir.pwd
    if wd == ROOT
      # Make command path relative, if inside `ROOT`
      command_for_presentation[0] = relative_path(command_for_presentation[0])
    else
      # Change working-dir to `wd`
      command_for_presentation.unshift("cd #{relative_path(wd)} &&")
    end
    if output_file
      # Redirect output to `output_file`
      command_for_presentation << '>'
      command_for_presentation << output_file
    end

    log(group, command_for_presentation.join(' '))
  end

  def self.relative_path(path)
    path.start_with?(ROOT) ? path[ROOT.size+1..-1] : path
  end

  # ------------------------------------------------------------------------------
  # pkg-config
  # ------------------------------------------------------------------------------

  pkg_config_tasks = PkgConfigTasks.define do |t|
    t.url            = PKG_CONFIG_URL
    t.artefact_file  = 'pkg-config'
    t.installed_file = 'bin/pkg-config'
    t.prefix         = DEPENDENCIES_PREFIX
    t.configure      = %w{ --enable-static --with-internal-glib }
  end

  @@installed_pkg_config = pkg_config_tasks.installed_path
  def self.pkg_config_task
    @@installed_pkg_config
  end

  # ------------------------------------------------------------------------------
  # YAML
  # ------------------------------------------------------------------------------

  yaml_tasks = BundleDependencyTasks.define do |t|
    t.url            = LIBYAML_URL
    t.artefact_file  = 'src/.libs/libyaml.a'
    t.installed_file = 'lib/libyaml.a'
    t.configure      = %w{ --disable-shared }
    t.prefix         = DEPENDENCIES_PREFIX
    t.dependencies   = [@@installed_pkg_config]
  end

  @@installed_yaml = yaml_tasks.installed_path
  def self.yaml_task
    @@installed_yaml
  end

  # ------------------------------------------------------------------------------
  # ZLIB
  # ------------------------------------------------------------------------------

  zlib_tasks = BundleDependencyTasks.define do |t|
    t.url            = ZLIB_URL
    t.artefact_file  = 'libz.a'
    t.installed_file = 'lib/libz.a'
    t.configure      = %w{ --static }
    t.prefix         = DEPENDENCIES_PREFIX
    t.dependencies   = [@@installed_pkg_config]
  end

  @@installed_zlib = zlib_tasks.installed_path
  def self.zlib_task
    @@installed_zlib
  end

  # ------------------------------------------------------------------------------
  # OpenSSL
  # ------------------------------------------------------------------------------

  openssl_tasks = OpenSSLTasks.define do |t|
    t.url            = OPENSSL_URL
    t.artefact_file  = 'libssl.a'
    t.installed_file = 'lib/libssl.a'
    t.prefix         = DEPENDENCIES_PREFIX
    t.dependencies   = [@@installed_pkg_config, @@installed_zlib]
  end

  @@installed_openssl = openssl_tasks.installed_path
  def self.openssl_task
    @@installed_openssl
  end

  # ------------------------------------------------------------------------------
  # Ruby
  # ------------------------------------------------------------------------------

  ruby_tasks = RubyTasks.define do |t|
    t.url            = RUBY_URL
    t.artefact_file  = 'libruby-static.a'
    t.installed_file = 'bin/ruby'
    t.prefix         = BUNDLE_PREFIX
    t.configure      = %w{ --enable-load-relative --disable-shared --with-static-linked-ext --disable-install-doc --with-out-ext=,dbm,gdbm,sdbm,dl/win32,fiddle/win32,tk/tkutil,tk,win32ole,-test-/win32/dln,-test-/win32/fd_setsize,-test-/win32/dln/empty }
    t.dependencies   = [@@installed_pkg_config, @@installed_yaml, @@installed_openssl]

    t.installed_libruby_path = File.join('app', 'CPReflectionService', 'libruby+exts.a')
    t.installed_dependencies = [@@installed_yaml]
  end

  @@installed_ruby = ruby_tasks.installed_path
  @@installed_ruby_static_lib = ruby_tasks.installed_libruby_path
  def self.ruby_task
    @@installed_ruby
  end
  def self.ruby_static_lib_task
    @@installed_ruby_static_lib
  end
  # ------------------------------------------------------------------------------
  # bundle-env
  # ------------------------------------------------------------------------------

  @@installed_env_script = File.join(BUNDLE_DESTROOT, 'bin/bundle-env')
  file @@installed_env_script do
    log 'bundle-env', 'Installing'
    cp 'bundle-env', @@installed_env_script
    chmod '+x', @@installed_env_script
  end
  def self.bundle_env_task
    @@installed_env_script
  end

  # ------------------------------------------------------------------------------
  # Gems
  # ------------------------------------------------------------------------------

  @@rubygems_tasks = RubyGemsTasks.new { |t| t.url = RUBYGEMS_URL }.tap(&:define_download_task)
  @@rubygems_gem = @@rubygems_tasks.downloaded_file

  rubygems_update_dir = File.join(GEM_HOME, 'gems', @@rubygems_tasks.package_name)
  directory rubygems_update_dir => [@@installed_ruby, @@installed_env_script, @@rubygems_gem] do
    install_gem(@@rubygems_gem, nil, @@rubygems_tasks.package_name)
    execute(@@rubygems_tasks.package_name, [BUNDLE_ENV, 'update_rubygems'])
    # Fix shebang of `gem` bin to use bundled Ruby.
    bin = File.join(BUNDLE_DESTROOT, 'bin/gem')
    log(@@rubygems_tasks.package_name, "Patching: #{bin}")
    lines = File.read(bin).split("\n")
    lines[0] = '#!/usr/bin/env ruby'
    File.open(bin, 'w') { |f| f.write(lines.join("\n")) }
    chmod '+x', bin
  end

  # ------------------------------------------------------------------------------
  # Bundler
  # ------------------------------------------------------------------------------
  @@installed_bundler_bin = File.join(BUNDLE_DESTROOT, 'bin/bundle')
  file @@installed_bundler_bin => rubygems_update_dir do
    install_gem 'bundler'
  end
  def self.bundler_task
    @@installed_bundler_bin
  end

  # ------------------------------------------------------------------------------
  # Fastlane Gems
  # ------------------------------------------------------------------------------

  @@installed_fastlane_bin = File.join(BUNDLE_DESTROOT, 'bin/fastlane')
  file @@installed_fastlane_bin => rubygems_update_dir do
    version = ENV['FASTLANE_GEM_VERSION'] || FASTLANE_GEM_VERSION
    if version == 'local'
      puts 'Please pass LOCAL_FASTLANE_DIR environment variable.' unless ENV['LOCAL_FASTLANE_DIR']
      exit 0 unless ENV['LOCAL_FASTLANE_DIR']
      install_local_fastlane
    else
      install_gem 'fastlane', version
    end
  end
  def self.fastlane_task
    @@installed_fastlane_bin
  end

  # ------------------------------------------------------------------------------
  # Third-party gems
  # ------------------------------------------------------------------------------

  # Note, this assumes its being build on the latest OS X version.
  @@installed_osx_gems = []
  Dir.glob('/System/Library/Frameworks/Ruby.framework/Versions/[0-9]*/usr/lib/ruby/gems/*/specifications/*.gemspec').each do |gemspec|
    # We have to make some file that does not contain any version information, otherwise we'd first have to query rubygems
    # for the available versions, which is going to take a long time.
    installed_gem = File.join(GEM_HOME, 'specifications', "#{File.basename(gemspec, '.gemspec').split('-')[0..-2].join('-')}.Fabric-app.installed")
    @@installed_osx_gems << installed_gem
    file installed_gem => rubygems_update_dir do
      suppress_upstream = false
      require 'rubygems/specification'
      gem = Gem::Specification.load(gemspec)
      # First install the exact same version that Apple included in OS X.
      case gem.name
      when 'libxml-ruby'
        # libxml-ruby-2.6.0 has an extconf.rb that depends on old behavior where `RbConfig` was available as `Config`.
        install_gem(File.join(PATCHES_DIR, "#{File.basename(gemspec, '.gemspec')}.gem"))
      when 'sqlite3'
        # sqlite3-1.3.7 depends on BigDecimal header from before BigDecimal was made into a gem. I doubt anybody really
        # uses sqlite for fastlane dependencies anyways, so just skip this old version.
      when 'nokogiri'
        # nokogiri currently has a design flaw that results in its build
        # failing every time unless I manually patch extconf.rb. I have
        # included a patched copy of nokogiri in the patches/ directory.
        # Until this is remedied, I cannot install the upstream version
        # of nokogiri.
        install_gem(File.join(PATCHES_DIR, "#{File.basename(gemspec, '.gemspec')}.gem"))
        suppress_upstream = true
      else
        install_gem(gem.name, gem.version)
      end
      # Now install the latest version of the gem.
      install_gem(gem.name) unless suppress_upstream
      # Create our nonsense file that's only used to track whether or not the gems were installed.
      touch installed_gem
    end
  end
  def self.install_gems_tasks
    @@installed_osx_gems
  end

  # ------------------------------------------------------------------------------
  # Root Certificates
  # ------------------------------------------------------------------------------

  @@installed_cacert = File.join(BUNDLE_DESTROOT, 'share/cacert.pem')
  file @@installed_cacert do
    %w{ /Library/Keychains/System.keychain /System/Library/Keychains/SystemRootCertificates.keychain }.each do |keychain|
      execute 'Certificates', ['/usr/bin/security', 'find-certificate', '-a', '-p', keychain], @@installed_cacert
    end
  end
  def self.cacert_task
    @@installed_cacert
  end
end