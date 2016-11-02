FASTLANE_DIR=~/.fastlane/bin

# Copy fastlane to ~/.fastlane
echo "Installing fastlane to $FASTLANE_DIR... this might take a few seconds"
mkdir -p $FASTLANE_DIR
cp -R "fastlane_lib/" $FASTLANE_DIR

# Add fastlane to the user's path
echo "Adding fastlane to your path..."
echo "export PATH=$PATH:$FASTLANE_DIR" >> ~/.bash_profile # TODO: this should only happen once, and we should ask the user first
