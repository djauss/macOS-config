#!/bin/sh

# ask sudo for the whole script session
echo '\n 👨‍🚀 For actions requiring sudo right, please provide sudo password now :'
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

CONFIG_FILE="/Volumes/Kama-encrypted/#Kama/macOS-config-variables"

if [ -f $CONFIG_FILE ]
then
  source $CONFIG_FILE
else
  # mas credentials
  echo '\n👨‍🚀 For installations from MAS, please provide Mac App Store credentials :'
  read -p '    - iTunes account (email) : ' MAS_ACCOUNT
  read -p '    - iTunes password : ' -s MAS_PASSWORD

  # git config
  echo '\n👨‍🚀 For git configuration, please provide needed infos :'
  read -p '    - git username : ' GIT_USER
  read -p '    - git email : ' GIT_EMAIL

  # Atom sync-settings
  echo '\n👨‍🚀 For Atom sync-settings configuration, please provide configuration :'
  read -p '    - personnal access token : ' ATOM_SS_TOKEN
  read -p '    - gist id : ' ATOM_SS_GIST
fi

# Homebrew install
if test ! $(which brew)
then
  echo '\n👨‍🚀 Homebrew install'
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Homebrew update
echo '\n👨‍🚀 Homebrew update'
brew update

# mas install & signin
echo '\n👨‍🚀 MAS install & signin : cauz the AppStore is waaaaaaay tooooooo sloooooooooooooow'
brew install mas
mas signin $MAS_ACCOUNT "$MAS_PASSWORD"

echo '\n👨‍🚀 Installing Homebrew Taps'
brew tap buo/cask-upgrade
brew tap proxmark/proxmark3

echo '\n👨‍🚀 Installing command-line utils'
brew install git android-platform-tools asdf curl imagemagick@6 node rbenv wget zsh cmake coreutils

echo '\n👨‍🚀 Installing oh-my-zsh in a new window'
osascript -e 'tell app "Terminal"
    do script "sh -c \"$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)\""
end tell'

echo '\n👨‍🚀 git configuration'
git config --global core.editor "nano"
git config --global user.name $GIT_USER
git config --global user.email $GIT_EMAIL
echo *.DS_Store > ~/.gitignore_global
git config --global core.excludesfile '~/.gitignore_global'
git config --global pull.rebase false

# MAS app install (source : https://github.com/argon/mas/issues/41#issuecomment-245846651)
function mas_install () {
  # Check if the App is already installed
  mas list | grep -i "$1" > /dev/null

  if [ "$?" == 0 ]; then
    echo "==> $1 is already installed"
  else
    echo "==> Installing $1..."
    mas search "$1" | { read app_ident app_name ; mas install $app_ident ; }
  fi
}

echo '\n👨‍🚀 Installing web navigators'
brew install firefox google-chrome min opera opera-neon

echo '\n👨‍🚀 Installing social apps'
brew install discord skype slack telegram
mas_install 'Twitter'

echo '\n👨‍🚀 Installing utilities apps'
brew install aerial daisydisk exiftool balenaetcher eul exodus handbrake hugin iperf lolcat ncdu nmap nyancat spectacle speedtest_cli terminal-notifier thefuck trash virtualbox wakeonlan wireshark xmind
mas_install 'Amphetamine'
mas_install 'Gifski'
mas_install 'Spark'
mas_install 'The Unarchiver'
mas_install 'Yummy FTP'
npm install -g brb tldr

echo '\n👨‍🚀 Installing music apps'
brew install lastfm spotify

echo '\n👨‍🚀 Installing video apps'
brew install iina vlc

echo '\n👨‍🚀 Installing development apps'
brew install arduino atom dbeaver-community docker intellij-idea-ce java kitematic postman python python3 sublime-text visual-studio-code
mas_install 'Xcode'
mas_install 'DevCleaner'
apm install sync-settings
rbenv install 2.5.0
rbenv global 2.5.0
asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git
asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
asdf install erlang 23.3.4.4
asdf install elixir 1.11.4
asdf install elixir 1.12.3
asdf global erlang 23.3.4.4
asdf global elixir 1.11.4
GITHUB_TOKEN=$ATOM_SS_TOKEN GIST_ID=$ATOM_SS_GIST atom

echo '\n👨‍🚀 Installing security apps'
brew install authy bitwarden keybase proxmark3 tunnelblick
mas_install 'Encrypto'

echo '\n👨‍🚀 Installing office apps'
brew install macdown
mas_install 'Keynote'
mas_install 'Numbers'
mas_install 'Pages'

echo '\n👨‍🚀 Installing games'
sbrew install league-of-legends minecraft openemu steam

echo '\n👨‍🚀 Post install cleanup'
brew cleanup
brew cleanup

echo '\n👨‍🚀 Setting up macOS preferences'
# daily updates
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled true
defaults write com.apple.SoftwareUpdate ScheduleFrequency 1
defaults write com.apple.SoftwareUpdate AutomaticDownload true
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall true
defaults write com.apple.commerce AutoUpdate true
# power chime sound
defaults write com.apple.PowerChime ChimeOnAllHardware -bool true
# don't write DS_store files on network and usb devices
defaults write com.apple.desktopservices DSDontWriteNetworkStores true
defaults write com.apple.desktopservices DSDontWriteUSBStores true
# finder
defaults write com.apple.finder ShowStatusBar false
defaults write com.apple.finder FXPreferredViewStyle 'clmv'
defaults write com.apple.finder NewWindowTargetPath "'file://$HOME'"
defaults write com.apple.finder FXEnableExtensionChangeWarning false
defaults write com.apple.finder _FXSortFoldersFirst true
defaults write com.apple.finder FXDefaultSearchScope "SCcf"
# contacts sorting
defaults write com.apple.AddressBook ABNameDisplay false
defaults write com.apple.AddressBook ABNameSortingFormat 'sortingFirstName sortingLastName'
# desktop
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 29" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 32" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:textSize 32" ~/Library/Preferences/com.apple.finder.plist
# safari : do not track, push notifications
defaults write com.apple.Safari SendDoNotTrackHTTPHeader false
defaults write com.apple.Safari CanPromptForPushNotifications false
# dock
defaults write com.apple.dock magnification true
defaults write com.apple.dock orientation 'Left'
defaults write com.apple.dock autohide true
defaults write com.apple.dock tilesize 30
defaults write com.apple.dock largesize 67
# screensaver
defaults -currentHost write com.apple.screensaver askForPassword true
defaults -currentHost write com.apple.screensaver askForPasswordDelay 0
defaults -currentHost write com.apple.screensaver idleTime 300
# screenshots
defaults write com.apple.screencapture location "${HOME}/Desktop"
defaults write com.apple.screencapture type "png"
# dashboard
defaults write com.apple.dashboard mcx-disabled false
defaults write com.apple.dock dashboard-in-overlay true
# simulators
sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app" "/Applications/Simulator.app"
sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/Simulator (Watch).app" "/Applications/Simulator (Watch).app"
# corners
defaults write com.apple.dock wvous-tl-corner 2
defaults write com.apple.dock wvous-tl-modifier 0
defaults write com.apple.dock wvous-tr-corner 3
defaults write com.apple.dock wvous-tr-modifier 0
defaults write com.apple.dock wvous-bl-corner 7
defaults write com.apple.dock wvous-bl-modifier 0
defaults write com.apple.dock wvous-br-corner 4
defaults write com.apple.dock wvous-br-modifier 0
# timemachine
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup true
# disable photo pop-up
defaults -currentHost write com.apple.ImageCapture disableHotPlug true
# ignore quarantine
defaults write com.apple.LaunchServices LSQuarantine false
# trackpad
defaults write NSGlobalDomain com.apple.swipescrolldirection false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior true
# textedit : txt
defaults write com.apple.TextEdit RichText -int 0

echo '\n👨‍🚀 Setting up applications preferences'
# spectacle shortcuts
curl -o ~/Library/Application\ Support/Spectacle/Shortcuts.json https://raw.githubusercontent.com/Kamasoutra/macOS-config/master/app_settings/spectacle/Shortcuts.json
# zshrc
curl -o ~/.zshrc https://raw.githubusercontent.com/Kamasoutra/macOS-config/master/app_settings/zsh/zshrc
# oh-my-zsh theme
curl -o ~/.oh-my-zsh/themes/kama.zsh-theme https://raw.githubusercontent.com/Kamasoutra/macOS-config/master/app_settings/oh-my-zsh/kama.zsh-theme

echo '\n👨‍🚀 Checking for macOS updates'
softwareupdate -ia

echo '\n👨‍🚀 All set up, just reboot !'
