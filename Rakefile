require 'aws-sdk-v1'
require 'json'

load './bundle_tasks.rake'
extend FastlaneRake

BUNDLE_VERSION = 1.1

FULL_BUNDLE_PATH = FastlaneRake::FULL_BUNDLE_PATH
VERBOSE = FastlaneRake::VERBOSE
BUNDLE_DESTROOT = FastlaneRake::BUNDLE_DESTROOT
BUNDLE_ENV = FastlaneRake::BUNDLE_ENV
WORKBENCH_DIR = FastlaneRake::WORKBENCH_DIR
DOWNLOAD_DIR = FastlaneRake::DOWNLOAD_DIR
DESTROOT = FastlaneRake::DESTROOT
FASTLANE_GEM_VERSION = FastlaneRake::FASTLANE_GEM_VERSION

load './shims_and_bins.rake'

ZIPPED_BUNDLE = "#{FULL_BUNDLE_PATH}.zip"
ZIPPED_STANDALONE = "bundle-#{BUNDLE_VERSION}.zip"

namespace :bundle do
  desc "Print Bundle Version"
  task :version do
    puts BUNDLE_VERSION
  end

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

  desc "Creates a VERSION file in the root of the bundle"
  task :stamp_version do
    path = File.join(DESTROOT, 'VERSION')
    File.open(path, 'w') { |f| f.write "#{BUNDLE_VERSION}\n"}
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

  desc "Responsible for preparing the actual bundle for the fastlane standalone"
  desc "to also include the install script and other helper files"
  task :finish_fastlane_standalone_bundle do
    output_dir = File.expand_path("..", DESTROOT)

    # We don't need those empty shims
    Dir[File.join(output_dir, "*")].each do |path|
      next if File.directory?(path)
      puts "Deleting file we don't need '#{path}'"
      File.delete(path)
    end

    prepare_bundle_env_for_env(standalone: true)

    cp("install", File.join(output_dir, "install"))
    cp("uninstall", File.join(output_dir, "uninstall"))
    cp("common.sh", File.join(output_dir, "common.sh"))
    cp("bundle_update_checker.rb", File.join(DESTROOT, "bundle_update_checker.rb"))
    cp("README.txt", File.join(output_dir, "README.txt"))
  end

  desc "Prepare current Cask file by substituting the correct values in the template"
  task :prepare_cask_template do
    brew_template_path = File.join(File.dirname(__FILE__), "cask", "fastlane.rb.template")
    brew_file_path = File.join(File.dirname(__FILE__), "cask", "fastlane.rb")

    template = File.read(brew_template_path)
    template.gsub!("{{CURRENT_VERSION}}", BUNDLE_VERSION.to_s)

    sha256sum = Digest::SHA256.file(ZIPPED_STANDALONE).hexdigest
    template.gsub!("{{SHA_NUM}}", sha256sum)

    File.write(brew_file_path, template)
  end

  desc "Build Standalone Bundle"
  task :build_standalone => [:build, :finish_fastlane_standalone_bundle, ZIPPED_STANDALONE, :prepare_cask_template, :upload_standalone_bundle, :update_standalone_bundle_version_json, 'clean:leftovers']

  desc "Responsible for preparing the actual bundle for the Mac app"
  task :finish_fastlane_mac_app_bundle do
    prepare_bundle_env_for_env(standalone: false)
  end

  # Update the bundle-env file to contain information
  # about the environment, in particular if the bundle
  # should be self-contained
  def prepare_bundle_env_for_env(standalone: false)
    path = File.join(DESTROOT, "bundle", "bin", "bundle-env")
    content = File.read(path)
    placeholder = "{{IS_STANDALONE}}"
    raise "Could not find placeholder #{placeholder} in '#{path}'" unless content.include?(placeholder)
    content.gsub!(placeholder, standalone.to_s)
    File.write(path, content)
    puts "Updated '#{path}' for IS_STANDALONE environment '#{standalone}'"
  end

  desc "Build complete dist bundle"
  task :build => [:build_tools, :remove_unneeded_files, :stamp_version, :copy_scripts]

  desc "Compress the bundle into a zipfile for distribution"
  file ZIPPED_BUNDLE do
    execute 'DITTO', ['ditto', '-ck', '--noqtn', '--sequesterRsrc', FULL_BUNDLE_PATH, ZIPPED_BUNDLE]
  end

  desc "Compress the STANDALONE bundle into a zipfile for distribution"
  file ZIPPED_STANDALONE do
    execute 'DITTO', ['ditto', '-ck', '--noqtn', '--sequesterRsrc', FULL_BUNDLE_PATH, ZIPPED_STANDALONE]
  end

  desc "Bundle the whole bundle"
  task :bundle => [:build, ZIPPED_BUNDLE]

  desc 'Upload Mac app bundle to S3'
  task :upload_bundle do
    upload_bundle_to_s3
  end

  desc 'Update Mac app version JSON on S3'
  task :update_bundle_version_json do
    update_version_json
  end

  desc 'Upload Standalone Bundle to S3'
  task :upload_standalone_bundle do
    upload_bundle_to_s3(is_standalone: true)
    upload_latest(is_standalone: true)
  end

  desc 'Update Standalone version JSON on S3'
  task :update_standalone_bundle_version_json do
    update_version_json(is_standalone: true)
  end

  def upload_latest(is_standalone: false)
    latest_path = is_standalone ? "fastlane/standalone/latest.zip" : "fastlane/latest.zip"
    fastlane_path = is_standalone ? "fastlane/standalone/fastlane.zip" : "fastlane/fastlane.zip"
    s3_path = is_standalone ? Pathname.new(ZIPPED_STANDALONE) : Pathname.new(ZIPPED_BUNDLE)
    latest_obj = s3_bucket.objects[latest_path].write(s3_path)
    fastlane_obj = s3_bucket.objects[fastlane_path].write(s3_path)
    latest_obj.acl = :public_read
    fastlane_obj.acl = :public_read
  end

  def upload_bundle_to_s3(is_standalone: false)
    path = is_standalone ? "fastlane/standalone/#{ZIPPED_STANDALONE}" : "fastlane/#{ZIPPED_BUNDLE}"
    s3_path = is_standalone ? Pathname.new(ZIPPED_STANDALONE) : Pathname.new(ZIPPED_BUNDLE)
    obj = s3_bucket.objects[path].write(s3_path)
    obj.acl = :public_read
  end

  def update_version_json(is_standalone: false)
    version = ENV['FASTLANE_GEM_OVERRIDE_VERSION'] || FASTLANE_GEM_VERSION
    json = {
      version: version,
      bundle_version: BUNDLE_VERSION,
      updated_at: Time.now.getutc,
      }.to_json
    path = is_standalone ? 'fastlane/standalone/version.json' : 'fastlane/version.json'
    obj = s3_bucket.objects[path].write json
    obj.acl = :public_read
  end

  def s3_bucket
    ENV['AWS_ACCESS_KEY_ID'] = ENV['CI_AGENT_AWS_ACCESS_KEY']
    ENV['AWS_SECRET_ACCESS_KEY'] = ENV['CI_AGENT_AWS_SECRET_ACCESS_KEY']
    ENV['AWS_REGION'] = 'us-east-1'
    s3 = AWS::S3.new
    s3.buckets['kits-crashlytics-com']
  end

  desc 'Make sure that there is an update that needs to be bundled before building'
  task :check_if_bundle_is_necessary do
    obj = s3_bucket.objects['fastlane/version.json']
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
  task :ci_bundle => [:check_if_bundle_is_necessary, :bundle, :upload_bundle, :update_bundle_version_json, 'clean:leftovers']

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
