# packaged-fastlane 🚀

## Usage 🛠

- Install by running `./install`
  1. Checks if _fastlane_ is already installed at `~/.fastlane/bin`
      1. Check if `PACKAGED_FASTLANE_VERSION.txt` and will completely uninstall if older version of packaged _fastlane_ if not
  1. Checks if `PACKAGED_RUBY_VERSION.txt` doesn't exist or if different. If so...
      1. Installs/updates `ruby-build` via `brew`
      1. Installs/updates `openssl` via `brew`
      1. Installs new version of Ruby
  1. Copies all files needed for running _fastlane_ with this Ruby version
  1. Installs `bundler` and `fastlane`
- Uninstall by running `./uninstall`
  1. Deletes `~/.fastlane/bin`

## Deployment

### Cask
Updated the `cask/fastlane.rb` if necessary and PR into https://github.com/Homebrew/homebrew-cask/blob/master/Casks/fastlane.rb

### fastlane.zip
zip this entire directoy and PR into https://github.com/fastlane/fastlane.tools/blob/gh-pages/fastlane.zip