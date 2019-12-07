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

Run `rake package['<new_version>']`

This will...

1) Package all needed files in a new zip file at `output/packaged-fastlane-#{new_version}.zip`
2) Updates `cask/fastlane.rb` with version and sha256
3) Gives instructions on what to do next

### Example output

```
➜  rake package["2.0.0"]
📦 Packaged at /Users/josh/Projects/fastlane/packaged-fastlane/output/packaged-fastlane-2.0.0.zip
✅ sha256:  e89bf6d1270f4c9455a523c0dafae3cfe2a704e8e9953390dcdef9852f64b4f7

version '2.0.0' to '2.0.0'
sha256 '8503027d192da59ac1ab5e2715fb103451b178cce035d994b185440b6c9ab1aa' to 'e89bf6d1270f4c9455a523c0dafae3cfe2a704e8e9953390dcdef9852f64b4f7'
💪 Updated cask/fastlane.rb

🚀 Now do two more things!
1) Upload zip file to https://github.com/fastlane/fastlane.tools
2) Update https://github.com/Homebrew/homebrew-cask/blob/master/Casks/fastlane.rb
```