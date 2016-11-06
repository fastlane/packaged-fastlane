FASTLANE_DIR=~/.fastlane/bin

read -p "Do you want to uninstall fastlane from $FASTLANE_DIR? (y/n) " -n 1 choice
case "$choice" in 
y|Y )
  echo ""
  rm -rf $FASTLANE_DIR
  echo "Please close the terminal session and restart it to start using fastlane 🚀"
;;
* )
  echo ""
  echo "Cancelled uninstall process"
;;
esac
