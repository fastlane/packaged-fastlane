load './bundle_tasks.rake'
extend FastlaneRake

VERBOSE = FastlaneRake::VERBOSE
BUNDLE_DESTROOT = FastlaneRake::BUNDLE_DESTROOT
BUNDLED_ENV_VERSION = FastlaneRake::BUNDLED_ENV_VERSION
BUNDLE_ENV = FastlaneRake::BUNDLE_ENV
WORKBENCH_DIR = FastlaneRake::WORKBENCH_DIR
DOWNLOAD_DIR = FastlaneRake::DOWNLOAD_DIR
DESTROOT = FastlaneRake::DESTROOT

namespace :bundle do
  task :build_tools => [
    FastlaneRake.ruby_task,
    FastlaneRake.fastlane_task,
    FastlaneRake.cocoapods_task,
    FastlaneRake.pry_task,
    FastlaneRake.bundle_env_task,
    FastlaneRake.cacert_task,
  ].concat(FastlaneRake.install_gems_tasks)

  task :remove_unneeded_files => :build_tools do
    remove_if_existant = lambda do |*paths|
      paths.each do |path|
        rm_rf(path) if File.exist?(path)
      end
    end
    if VERBOSE
      puts
      puts "Before clean:"
      sh "du -hs #{BUNDLE_DESTROOT}"
    end
    remove_if_existant.call *FileList[File.join(BUNDLE_DESTROOT, 'lib/**/*.{,l}a')]
    remove_if_existant.call *Dir.glob(File.join(BUNDLE_DESTROOT, 'lib/ruby/gems/**/*.o'))
    remove_if_existant.call *Dir.glob(File.join(BUNDLE_DESTROOT, 'lib/ruby/gems/*/cache'))
    remove_if_existant.call *Dir.glob(File.join(BUNDLE_DESTROOT, '**/man[0-9]'))
    remove_if_existant.call *Dir.glob(File.join(BUNDLE_DESTROOT, '**/.DS_Store'))
    remove_if_existant.call File.join(BUNDLE_DESTROOT, 'man')
    remove_if_existant.call File.join(BUNDLE_DESTROOT, 'share/gitweb')
    remove_if_existant.call File.join(BUNDLE_DESTROOT, 'share/man')
    # TODO clean Ruby stdlib
    if VERBOSE
      puts "After clean:"
      sh "du -hs #{BUNDLE_DESTROOT}"
    end
  end

  desc 'Copy the fastlane shim into the root of the bundle.'
  file "#{DESTROOT}/fastlane" do
    cp 'fastlane_shim', "#{DESTROOT}/fastlane"
  end

  desc 'Setup CocoaPods master repo'
  file "~/.cocoapods/repos/master" do
    execute 'CocoaPods', [BUNDLE_ENV, 'pod', 'setup']
  end

  desc "Creates a VERSION file in the destroot folder"
  task :stamp_version do
    path = File.join(BUNDLE_DESTROOT, "VERSION")
    File.open(path, 'w') { |file| file.write "#{BUNDLED_ENV_VERSION}\n" }
  end

  desc "Verifies that no binaries in the bundle link to incorrect dylibs"
  task :verify_linkage => :remove_unneeded_files do
    skip = %w( .h .rb .py .pyc .tmpl .pem .png .ttf .css .rhtml .js .sample )
    Dir.glob(File.join(BUNDLE_DESTROOT, '**/*')).each do |path|
      next if File.directory?(path)
      next if skip.include?(File.extname(path))
      linkage = `otool -arch x86_64 -L '#{path}'`.strip
      unless linkage.include?('is not an object file')
        linkage = linkage.split("\n")[1..-1]

        puts
        puts "Linkage of `#{path}`:"
        puts linkage

        good = linkage.grep(%r{^\s+(/System/Library/Frameworks/|/usr/lib/)})
        bad = linkage - good
        unless bad.empty?
          puts
          puts "[!] Bad linkage found in `#{path}`:"
          puts bad
          exit 1
        end
      end
    end
  end

  desc "Test bundle"
  task :test => :build_tools do
    execute 'Test', [BUNDLE_ENV, 'fastlane', 'actions']
  end

  desc "Build complete dist bundle"
  task :build => [:build_tools, :remove_unneeded_files, :stamp_version, "#{DESTROOT}/fastlane"]

  desc "Compress #{DESTROOT} into a zipfile."
  file "#{DESTROOT}.zip" do
    execute 'DITTO', ['ditto', '-ck', '--noqtn', '--sequesterRsrc', "#{DESTROOT}", "#{DESTROOT}.zip"]
  end

  desc "Bundle the whole bundle"
  task :bundle => [:build, "#{DESTROOT}.zip"]

  namespace :clean do
    task :build do
      rm_rf WORKBENCH_DIR
    end

    task :downloads do
      rm_rf DOWNLOAD_DIR
    end

    task :destroot do
      rm_rf DESTROOT
    end

    desc "Clean build and destroot artefacts"
    task :artefacts => [:build, :destroot]

    desc "Clean all artefacts, including downloads"
    task :all => [:artefacts, :downloads]
  end
end
