require 'aws-sdk-v1'
load './bundle_tasks.rake'
extend FastlaneRake

FULL_BUNDLE_PATH = FastlaneRake::FULL_BUNDLE_PATH
VERBOSE = FastlaneRake::VERBOSE
BUNDLE_DESTROOT = FastlaneRake::BUNDLE_DESTROOT
BUNDLED_ENV_VERSION = FastlaneRake::BUNDLED_ENV_VERSION
BUNDLE_ENV = FastlaneRake::BUNDLE_ENV
WORKBENCH_DIR = FastlaneRake::WORKBENCH_DIR
DOWNLOAD_DIR = FastlaneRake::DOWNLOAD_DIR
DESTROOT = FastlaneRake::DESTROOT
FASTLANE_GEM_VERSION = FastlaneRake::FASTLANE_GEM_VERSION


load './shims_and_bins.rake'


ZIPPED_BUNDLE = "#{FULL_BUNDLE_PATH}.zip"

namespace :bundle do
  task :build_ruby => FastlaneRake.ruby_task
  task :install_fastlane => FastlaneRake.fastlane_task
  task :install_bundler => FastlaneRake.bundler_task

  task :build_tools => [
    :build_ruby,
    FastlaneRake.cacert_task,
    :install_bundler,
    :install_fastlane,
    FastlaneRake.bundle_env_task,
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

  desc 'Copy the parse_env.rb script into the root of the bundle'
  file "#{DESTROOT}/parse_env.rb"  do
    cp 'parse_env.rb', "#{DESTROOT}/parse_env.rb"
  end

  desc "Copy all the shims and bins."
  task :copy_all_shims_and_bins => [
    "#{DESTROOT}/fastlane",
    "#{FULL_BUNDLE_PATH}/fastlane",
    "#{DESTROOT}/sigh",
    "#{FULL_BUNDLE_PATH}/sigh",
    "#{DESTROOT}/snapshot",
    "#{FULL_BUNDLE_PATH}/snapshot",
    "#{DESTROOT}/pem",
    "#{FULL_BUNDLE_PATH}/pem",
    "#{DESTROOT}/frameit",
    "#{FULL_BUNDLE_PATH}/frameit",
    "#{DESTROOT}/deliver",
    "#{FULL_BUNDLE_PATH}/deliver",
    "#{DESTROOT}/produce",
    "#{FULL_BUNDLE_PATH}/produce",
    "#{DESTROOT}/gym",
    "#{FULL_BUNDLE_PATH}/gym",
    "#{DESTROOT}/scan",
    "#{FULL_BUNDLE_PATH}/scan",
    "#{DESTROOT}/match",
    "#{FULL_BUNDLE_PATH}/match",
    "#{DESTROOT}/cert",
    "#{FULL_BUNDLE_PATH}/cert"
  ]

  task :copy_scripts => [:copy_all_shims_and_bins, "#{DESTROOT}/parse_env.rb"]

  desc "Responsible for preparing the actual bundle"
  desc "to also include the install.sh file"
  task :refactor_fastlane_bundle do
    output_dir = File.expand_path("..", DESTROOT)

    # We don't need those empty shims
    Dir[File.join(output_dir, "*")].each do |path|
      next if File.directory?(path)
      puts "Deleting file we don't need '#{path}'"
      File.delete(path)
    end

    cp("install.sh", File.join(output_dir, "install.sh"))
  end

  desc "Build complete dist bundle"
  task :build => [:build_tools, :remove_unneeded_files, :stamp_version, :copy_scripts]

  desc "Compress the bundle into a zipfile for distribution"
  file ZIPPED_BUNDLE do
    execute 'DITTO', ['ditto', '-ck', '--noqtn', '--sequesterRsrc', FULL_BUNDLE_PATH, ZIPPED_BUNDLE]
  end

  desc "Bundle the whole bundle"
  task :bundle => [:build, ZIPPED_BUNDLE]

  desc 'Upload bundle to S3'
  task :upload_bundle do
    s3 = AWS::S3.new
    bucket = s3.buckets['kits-crashlytics-com']
    obj = bucket.objects["fastlane/#{ZIPPED_BUNDLE}"].write(Pathname.new(ZIPPED_BUNDLE))
    obj.acl = :public_read
  end

  desc 'Update version JSON on S3'
  task :update_bundle_version_json do
    version = ENV['FASTLANE_GEM_OVERRIDE_VERSION'] || FASTLANE_GEM_VERSION
    json = "{\"version\": \"#{version}\", \"updated_at\": \"#{Time.now.getutc}\"}"
    s3 = AWS::S3.new
    bucket = s3.buckets['kits-crashlytics-com']
    obj = bucket.objects['fastlane/version.json'].write json
    obj.acl = :public_read
  end

  desc 'Make sure that there is an update that needs to be bundled before building'
  task :check_if_bundle_is_necessary do
    s3 = AWS::S3.new
    bucket = s3.buckets['kits-crashlytics-com']
    obj = bucket.objects['fastlane/version.json']
    json = JSON.parse obj.read
    version_on_s3 = Gem::Version.new(json['version'])
    unless version_on_s3 < Gem::Version.new(FASTLANE_GEM_VERSION)
      puts "****** No need to build the bundle because #{version_on_s3} is already on S3! ******"
      exit 0
    else
      puts "****** BUILDING VERSION #{FASTLANE_GEM_VERSION} ******"
    end
  end

  desc "Create and save the bundle for CI."
  task :ci_bundle => [:check_if_bundle_is_necessary, :bundle, :upload_bundle, :update_bundle_version_json, 'clean:all']

  namespace :clean do
    task :workbench do
      rm_rf WORKBENCH_DIR
    end

    task :downloads do
      rm_rf DOWNLOAD_DIR
    end

    task :bundle do
      rm_rf Dir['bundle-*/']
    end

    task :zip do
      rm_rf Dir['*.zip']
    end

    desc "Clean build leftovers"
    task :leftovers => [:workbench, :downloads, :bundle]

    desc "Clean all artefacts, including downloads, and zip."
    task :all => [:leftovers, :zip]
  end
end