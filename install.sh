FASTLANE_DIR=~/.fastlane/bin

# Copy fastlane to ~/.fastlane
echo "Installing fastlane to $FASTLANE_DIR... this might take a few seconds"
mkdir -p $FASTLANE_DIR
cp -R "fastlane_lib/" $FASTLANE_DIR

echo "Successfully copied fastlane to $FASTLANE_DIR"
echo ""


manual_installation() {
  echo "Please add the following line to your bash profile:"
  echo ""
  echo $1
  echo ""
  echo "After doing so close the terminal session and restart it to start using fastlane  🚀"
}

# check if it's already in the user's path
echo $PATH | grep -o $FASTLANE_DIR > /dev/null
if [ $? -ne 0 ]; then
  export LINE_TO_ADD="export PATH=$FASTLANE_DIR:\$PATH"

  # Detect shell environment
  shell=$(basename $(echo $SHELL))
  case "$shell" in
    bash )
      if [ -f "${HOME}/.bashrc" ] && [ ! -f "${HOME}/.bash_profile" ]; then
        profile='~/.bashrc'
      else
        profile='~/.bash_profile'
      fi
      ;;
    zsh )
      profile='~/.zshrc'
      ;;
    fish )
      profile='~/.config/fish/config.fish'
      LINE_TO_ADD="set -x PATH $FASTLANE_DIR \$PATH" # fish has its own way of setting variables
      ;;
    * )
      profile="unknown"
      ;;
  esac

  profile_expanded="$(eval echo $profile)"
  if [ -f $profile_expanded ]; then
    echo "Detected shell config file at path '$profile'"
    echo "We can add the following line to your shell config"
    echo "so you can run fastlane from any directory on your machine"
    echo ""
    echo $LINE_TO_ADD
    echo ""
    read -p "Do you want fastlane to add itself to the path by updating your profile? (y/n) " -n 1 choice
    case "$choice" in 
      y|Y ) 
        echo ""
        echo $LINE_TO_ADD >> $profile_expanded
        echo "Successfully updated $profile"
        echo "Please close the terminal session and restart it to start using fastlane 🚀"
    ;;
      * )
        echo ""
        manual_installation "$LINE_TO_ADD"
    ;;
    esac
  else
    echo "Couldn't detect shell config file ($shell - $profile)"
    manual_installation "$LINE_TO_ADD"
  fi
else
  echo "Detected fastlane is already in your path 🚀"
fi
