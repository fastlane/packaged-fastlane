task default: %w[package]

# Helper for 'cask/fastlane.rb'
# Prints out version and sha256
# Updates version and sha256 in 'cask/fastane.rb' if arguments passed
task :cask, [:property, :new_value] do |t, args|
  property = args[:property]
  new_value = args[:new_value]

  filename = "cask/fastlane.rb"
  text = File.read(filename)

  # Iterate over lines to find verison and sha256
  lines = text.lines
  lines = lines.map do |line|
    line.match(/#{property} \'(.*)\'/)
    value = $1

    # Prints (and updates) version
    puts "#{property}: #{value}" if value && !new_value
    if value && new_value
      puts "#{property} '#{value}' to '#{new_value}'"
      line = line.gsub(value, new_value)
    end

    line
  end

  # Updates cask/fastlane.rb if needed
  if new_value
    f = File.new(filename, 'w')
    lines.each do |line|
      f.puts(line)
    end
    f.close
  end
end

task :package, [:new_version] do |t, args|
  new_version = args[:new_version]
  puts "ERROR: Please pass a new version" unless new_version

  output_dir = File.absolute_path("output")
  FileUtils.rm_rf(output_dir)

  input_filenames = [
    'LICENSE',
    'NOTICE.txt',
    'THIRDPARTYLICENSES.txt',
    'bundle-env',
    'common.sh',
    'fastlane_shim',
    'install',
    'parse_env.rb',
    'uninstall'
  ]

  FileUtils.mkdir_p(output_dir)
  zipfile_path = File.join(output_dir, "packaged-fastlane-#{new_version}.zip")

  # Zips all needed files
  require 'zip'
  Zip::File.open(zipfile_path, Zip::File::CREATE) do |zipfile|
    input_filenames.each do |filename|
      zipfile.add(filename, File.absolute_path(filename))
    end
  end

  # Gets sha256 of zip file
  require 'digest'
  sha256 = Digest::SHA256.file(zipfile_path).to_s

  puts "📦 Packaged at #{zipfile_path}"
  puts "✅ sha256:  #{sha256}"
  puts ""

  # Updates cask/fastlane.rb
  Rake::Task["cask"].invoke('version', new_version)
  Rake::Task["cask"].reenable
  Rake::Task["cask"].invoke('sha256', sha256)
  puts "💪 Updated cask/fastlane.rb"

  puts ""
  puts "🚀 Now do two more things!"
  puts "1) Upload zip file to https://github.com/fastlane/fastlane.tools"
  puts "2) Update https://github.com/Homebrew/homebrew-cask/blob/master/Casks/fastlane.rb"
end
