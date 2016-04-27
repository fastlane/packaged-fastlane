require 'net/http'
require 'json'

module FastlaneRake
  extend Rake::DSL

  BUNDLED_ENV_VERSION = 2
  # ^ This has to be at line 0
  # This is so that a build on CP.app can be fast,
  # it can make assumptions that removing `BUNDLED_ENV_VERSION = `
  # from the first line will get the version.

  ruby_gems_json = Net::HTTP.get URI('https://rubygems.org/api/v1/gems/fastlane.json')
  version = JSON.parse(ruby_gems_json)['version']
  FASTLANE_GEM_VERSION = version

  puts "****** No Version Set! ******" unless FASTLANE_GEM_VERSION
  exit(1) unless FASTLANE_GEM_VERSION

  puts "****** BUILDING VERSION #{FASTLANE_GEM_VERSION} ******"

  VERBOSE = !!RakeFileUtils.verbose_flag

  RELEASE_PLATFORM = '10.11'
  DEPLOYMENT_TARGET = '10.10'

  # Ideally this would be deployment target, but
  # we use generics which didn't exist in 10.10.
  DEPLOYMENT_TARGET_SDK = "MacOSX#{RELEASE_PLATFORM}.sdk"

  $build_started_at = Time.now
  at_exit do
    min, sec = (Time.now - $build_started_at).divmod(60)
    sec = sec.round
    puts
    puts "Finished in #{min} minutes and #{sec} seconds"
    puts
  end

  # OpenSSL fails if we set this make configuration through MAKEFLAGS, so we pass
  # it to each make invocation seperately.
  MAKE_CONCURRENCY = `sysctl hw.physicalcpu`.strip.match(/\d+$/)[0].to_i + 1

  FULL_BUNDLE_PATH = "bundle-#{FASTLANE_GEM_VERSION}"
  ROOT = File.dirname(__FILE__)
  PKG_DIR = 'pkg'
  DOWNLOAD_DIR = 'downloads'
  WORKBENCH_DIR = 'workbench'
  DESTROOT = "#{FULL_BUNDLE_PATH}/fastlane_lib"
  BUNDLE_DESTROOT = File.join(DESTROOT, 'bundle')
  DEPENDENCIES_DESTROOT = File.join(DESTROOT, 'dependencies')

  PATCHES_DIR = File.expand_path('patches')
  BUNDLE_PREFIX = File.expand_path(BUNDLE_DESTROOT)
  DEPENDENCIES_PREFIX = File.expand_path(DEPENDENCIES_DESTROOT)
  BUNDLE_ENV = File.join(BUNDLE_PREFIX, 'bin', 'bundle-env')

  directory PKG_DIR
  directory DOWNLOAD_DIR
  directory WORKBENCH_DIR
  directory DEPENDENCIES_DESTROOT

  # Prefer the SDK of the DEPLOYMENT_TARGET, but otherwise fallback to the current one.
  sdk_dir = File.join(`xcrun --show-sdk-platform-path --sdk macosx`.strip, 'Developer/SDKs')
  if Dir.entries(sdk_dir).include?(DEPLOYMENT_TARGET_SDK)
    SDKROOT = File.join(sdk_dir, DEPLOYMENT_TARGET_SDK)
  else
    SDKROOT = File.expand_path(`xcrun --show-sdk-path --sdk macosx`.strip)
  end
  unless File.exist?(SDKROOT)
    puts "[!] Unable to find a SDK for the Platform target `macosx`."
    exit 1
  end

  ORIGINAL_PATH = ENV['PATH']
  ENV['PATH'] = "#{File.join(DEPENDENCIES_PREFIX, 'bin')}:/usr/bin:/bin"
  ENV['CC'] = '/usr/bin/clang'
  ENV['CXX'] = '/usr/bin/clang++'
  ENV['CFLAGS'] = "-mmacosx-version-min=#{DEPLOYMENT_TARGET} -isysroot #{SDKROOT}"
  ENV['CPPFLAGS'] = "-I#{File.join(DEPENDENCIES_PREFIX, 'include')}"
  ENV['LDFLAGS'] = "-L#{File.join(DEPENDENCIES_PREFIX, 'lib')}"

  # If we don't create this dir and set the env var, the ncurses configure
  # script will simply decide that we don't want any .pc files.
  PKG_CONFIG_LIBDIR = File.join(DEPENDENCIES_PREFIX, 'lib/pkgconfig')
  ENV['PKG_CONFIG_LIBDIR'] = PKG_CONFIG_LIBDIR

  # ------------------------------------------------------------------------------
  # Package metadata
  # ------------------------------------------------------------------------------

  PKG_CONFIG_VERSION = '0.28'
  PKG_CONFIG_URL = "http://pkg-config.freedesktop.org/releases/pkg-config-#{PKG_CONFIG_VERSION}.tar.gz"

  LIBYAML_VERSION = '0.1.6'
  LIBYAML_URL = "http://pyyaml.org/download/libyaml/yaml-#{LIBYAML_VERSION}.tar.gz"

  ZLIB_VERSION = '1.2.8'
  ZLIB_URL = "http://zlib.net/zlib-#{ZLIB_VERSION}.tar.gz"

  OPENSSL_VERSION = '1.0.2'
  OPENSSL_PATCH = 'g'
  OPENSSL_URL = "https://www.openssl.org/source/openssl-#{OPENSSL_VERSION}#{OPENSSL_PATCH}.tar.gz"

  NCURSES_VERSION = '5.9'
  NCURSES_URL = "http://ftpmirror.gnu.org/ncurses/ncurses-#{NCURSES_VERSION}.tar.gz"

  READLINE_VERSION = '6.3'
  READLINE_URL = "http://ftpmirror.gnu.org/readline/readline-#{READLINE_VERSION}.tar.gz"

  RUBY__VERSION = '2.2.4'
  RUBY_URL = "http://cache.ruby-lang.org/pub/ruby/2.2/ruby-#{RUBY__VERSION}.tar.gz"

  RUBYGEMS_VERSION = '2.5.2'
  RUBYGEMS_URL = "https://rubygems.org/downloads/rubygems-update-#{RUBYGEMS_VERSION}.gem"

  # ------------------------------------------------------------------------------
  # Bundle Build Tools
  # ------------------------------------------------------------------------------

  def log(group, message)
    $stderr.puts "[#{Time.now.strftime('%T')}] [#{group}] #{message}"
  end

  def relative_path(path)
    path.start_with?(ROOT) ? path[ROOT.size+1..-1] : path
  end

  # These changes are so that copy-pasting the logged commands should work.
  def log_command(group, command, output_file)
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

  def execute(group, command, output_file = nil)
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


  GEM_HOME = File.join(BUNDLE_DESTROOT, 'lib/ruby/gems', RUBY__VERSION.sub(/\d+$/, '0'))

  def install_gem(name, version = nil, group = 'Gems')
    execute group, [BUNDLE_ENV, 'gem', 'install', name, ("--version=#{version}" if version), '--no-document', '--env-shebang'].compact
  end

  def update_gem(name, group = 'Gem Update')
    execute group, [BUNDLE_ENV, 'gem', 'update', name, '--no-document', '--env-shebang'].compact
  end
end