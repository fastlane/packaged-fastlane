require 'net/http'
require 'json'

uri = URI('https://kits-crashlytics-com.s3.amazonaws.com/fastlane/standalone/version.json')
json_string = Net::HTTP.get(uri)
json = JSON.parse(json_string)
available_bundle_version = json["bundle_version"]

path_to_version = File.expand_path(File.join(File.dirname(__FILE__), 'VERSION'))

version_string = File.open(path_to_version) { |file| file.each_line.first }
current_bundle_version = version_string.chomp.to_f

if available_bundle_version > current_bundle_version
  puts "Fastlane update available"
  if ENV["FASTLANE_INSTALLED_VIA_HOMEBREW"] == "true"
    puts "Please run `brew cask reinstall fastlane`"
  else
    puts "Please update fastlane by downloading an updated bundle from"
    puts "https://kits-crashlytics-com.s3.amazonaws.com/fastlane/standalone/latest.zip"
  end
end
