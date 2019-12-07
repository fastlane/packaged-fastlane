cask 'fastlane' do
  version '2.0.0'
  sha256 :no_check

  url "https://fastlane.tools/packaged-fastlane-#{version}.zip"
  name 'fastlane'
  homepage 'https://fastlane.tools/'

  installer script: {
                      executable: "#{staged_path}/install",
                      args:       ['-p', '-b', '-y'],
                    }

  uninstall script: {
                      executable: "#{staged_path}/uninstall",
                      args:       ['-y'],
                    }
end
