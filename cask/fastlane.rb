cask 'fastlane' do
  VERSION_NUMBER = '1.0'.freeze

  version VERSION_NUMBER
  sha256 'f642cdae3d4841f85d4a9260866361d136fad82974cf5905629d48f70d86f294'

  # kits-crashlytics-com.s3.amazonaws.com/fastlane/ was verified as official when first introduced to the cask
  url "https://kits-crashlytics-com.s3.amazonaws.com/fastlane/standalone/bundle-#{VERSION_NUMBER}.zip"
  name 'fastlane'
  homepage 'https://fastlane.tools'

  installer script: './install', args: ['-p', '-u', '-b'], sudo: false

  uninstall script: { executable: './uninstall', args: ['-y'], sudo: false }
end
