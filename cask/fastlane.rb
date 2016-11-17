cask 'fastlane' do
  VERSION_NUMBER='1.0'

  version VERSION_NUMBER
  sha256 '0130980b94034b163e7d45d50bfe114af5345888267572edad640fe1b2d66ea5'

  url "https://kits-crashlytics-com.s3.amazonaws.com/fastlane/standalone/bundle-#{VERSION_NUMBER}.zip"
  name 'fastlane'
  homepage 'https://fastlane.tools'

  installer script: "./install",
            args: ['-p', '-u', '-b'],
            sudo: false

  uninstall script: { executable: "./uninstall",
                            args: ['-y'],
                            sudo: false }
end
