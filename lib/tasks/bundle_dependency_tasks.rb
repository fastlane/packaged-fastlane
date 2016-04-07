class BundleDependencyTasks
  include FastlaneRake
  include Rake::DSL

  def relative_path(path)
    path.start_with?(ROOT) ? path[ROOT.size+1..-1] : path
  end

  def self.define(&block)
    new(&block).tap(&:define_tasks)
  end

  # The URL from where to download the package.
  attr_accessor :url

  # An array of options that should be passed to the `configure` script. The `prefix` is already set.
  attr_accessor :configure

  # A relative path to a file that should exist (in the `WORKBENCH_DIR`) after building the package.
  attr_accessor :artefact_file

  # A relative path to a file that should exist (in the `prefix`) after installing the package.
  attr_accessor :installed_file

  # The installed paths (e.g. `BundleDependencyTasks#installed_path`) that this package depends on.
  attr_accessor :dependencies

  # The `--prefix` value passed to the `configure` script.
  attr_accessor :prefix

  def initialize
    @dependencies = []
    @configure = []
    yield self
  end

  def define_tasks
    define_download_task
    define_unpack_task
    define_build_task
    define_install_task
  end

  def package_name
    File.basename(@url).split('.tar.').first
  end

  def execute(*command)
    super(package_name, command)
  end

  def downloaded_file
    File.join(DOWNLOAD_DIR, File.basename(@url))
  end

  def download_task
    execute '/usr/bin/curl', '-sSL', @url, '-o', downloaded_file
  end

  def define_download_task
    file(downloaded_file => DOWNLOAD_DIR) { download_task }
  end

  def build_dir
    File.join(WORKBENCH_DIR, package_name)
  end

  def unpack_command
    ['/usr/bin/tar', '-zxvf', downloaded_file, '-C', WORKBENCH_DIR]
  end

  def unpack_task
    execute *unpack_command
  end

  def define_unpack_task
    directory(build_dir => [downloaded_file, WORKBENCH_DIR]) { unpack_task }
  end

  def artefact_path
    File.join(build_dir, @artefact_file)
  end

  def build_command
    ['/usr/bin/make', '-j', MAKE_CONCURRENCY]
  end

  def build_task
    Dir.chdir(build_dir) do
      execute '/bin/sh', 'configure', '--prefix', @prefix, *@configure
      execute *build_command
    end
  end

  def define_build_task
    dependencies = @dependencies + [build_dir]
    file(artefact_path => dependencies) { build_task }
  end

  def installed_path
    File.join(relative_path(@prefix), @installed_file)
  end

  def install_task
    Dir.chdir(build_dir) do
      execute '/usr/bin/make', 'install'
    end
  end

  def define_install_task
    file(installed_path => artefact_path) { install_task }
  end
end

class PythonSetupTasks < BundleDependencyTasks
  def self.python_version
    @python_version ||= `/usr/bin/python --version 2>&1`.match(/\d\.\d/)[0]
  end

  def artefact_script=(script_name)
    self.artefact_file = File.join('build', "scripts-#{self.class.python_version}", script_name)
  end

  def build_task
    Dir.chdir(build_dir) do
      execute '/usr/bin/python', 'setup.py', 'build'
    end
  end

  def install_task
    Dir.chdir(build_dir) do
      execute '/usr/bin/python', 'setup.py', 'install', '--prefix', BUNDLE_PREFIX
    end
  end
end

class PkgConfigTasks < BundleDependencyTasks
  def install_task
    super
    mkdir_p PKG_CONFIG_LIBDIR
  end
end

class OpenSSLTasks < BundleDependencyTasks
  def build_task
    Dir.chdir(build_dir) do
      execute '/usr/bin/perl', 'Configure', "--prefix=#{DEPENDENCIES_PREFIX}", 'no-shared', 'zlib', 'darwin64-x86_64-cc'
      # OpenSSL needs to be build with at max 1 process
      execute '/usr/bin/make', '-j', '1'
    end
    # Seems to be a OpenSSL bug in the pkg-config, as libz is required when
    # linking libssl, otherwise Ruby's openssl ext will fail to configure.
    # So add it ourselves.
    %w( libcrypto.pc libssl.pc ).each do |pc_filename|
      pc_file = File.join(build_dir, pc_filename)
      log(package_name, "Patching: #{pc_file}")
      original_content = File.read(pc_file)
      content = original_content.sub(/Libs:/, 'Libs: -lz')
      if original_content == content
        raise "[!] Did not patch anything in: #{pc_file}"
      end
      File.open(pc_file, 'w') { |f| f.write(content) }
    end
  end
end

class NCursesTasks < BundleDependencyTasks
  def unpack_task
    super
    Dir.chdir(build_dir) do
      execute '/usr/bin/patch', '-p', '1', '-i', File.join(PATCHES_DIR, 'ncurses.diff')
    end
  end
end

class RubyTasks < BundleDependencyTasks
  attr_accessor :installed_libruby_path, :installed_dependencies

  # TODO Look into using ext/extinit.c instead, but this will autoload the extensions,
  #      so that makes more sense to look into when switching to a dynamic libruby.
  def define_install_libruby_task
    file installed_libruby_path => artefact_path do
      cp artefact_path, installed_libruby_path
      %w{ bigdecimal date/date_core.a digest fiddle pathname psych stringio strscan }.each do |ext|
        ext = "#{ext}/#{ext}.a" unless File.extname(ext) == '.a'
        execute '/usr/bin/libtool', '-static', '-o', installed_libruby_path, installed_libruby_path, File.join(build_dir, 'ext', ext)
      end

      execute '/usr/bin/libtool', '-static', '-o', installed_libruby_path, installed_libruby_path, File.join(build_dir, 'enc', 'libenc.a')
      execute '/usr/bin/libtool', '-static', '-o', installed_libruby_path, installed_libruby_path, File.join(build_dir, 'enc', 'libtrans.a')

      installed_dependencies.each do |installed_dependency|
        execute '/usr/bin/libtool', '-static', '-o', installed_libruby_path, installed_libruby_path, installed_dependency
      end
    end
  end

  def define_tasks
    super
    define_install_libruby_task
  end
end

class RubyGemsTasks < BundleDependencyTasks
  def package_name
    File.basename(@url, '.gem')
  end
end
