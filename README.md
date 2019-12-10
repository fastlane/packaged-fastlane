# packaged-fastlane 🚀

## Usage 🛠

`brew install fastlane`

## Run Locally 🏃‍♂️

1. `./install ~/somedir`
1. `~/somedir/bin/fastlane`

## Deployment 🚢

Any changes to the `bundle_env`, `fastlane`, or `install` will require a new release/tag and an update to the `fastlane.rb` formula in https://github.com/Homebrew/homebrew-core.

1. Create release/tag in GitHub
1. Download the `.tar.gz`
1. Get the sha256 of the `.tar.gz` with `openssl dgst -sha256 <file>`
1. Update the `fastlane.rb` formula in https://github.com/Homebrew/homebrew-core and open a PR
    1. Update `url`
    1. Update `sha256`
    1. Update `revision` (if needed)