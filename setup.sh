#!/bin/bash
#### REPOS START
sudo add-apt-repository -y ppa:berglh/pulseaudio-a2dp
# wine
wget -qO - https://dl.winehq.org/wine-builds/winehq.key | sudo apt-key add -
sudo add-apt-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ groovy main'
# sublime text
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
# repos
sudo add-apt-repository -y ppa:kisak/kisak-mesa
sudo add-apt-repository -y ppa:kubuntu-ppa/backports
sudo add-apt-repository -y ppa:lutris-team/lutris
#sudo add-apt-repository -y ppa:maxiberta/kwin-lowlatency
#### REPOS END

sudo apt upgrade -y

cd /tmp || exit 1
# syncplay
wget --content-disposition  https://www.vpn.net/installers/logmein-hamachi_2.1.0.203-1_amd64.deb https://github.com/Syncplay/syncplay/releases/download/v1.6.6/syncplay_1.6.6.deb
sudo apt install -y ./*.deb

packages=(
  # optdeps
  network-manager-openvpn
  # dolphin
  dolphin-plugins
  # not deps
  adb
  bleachbit
  earlyoom
  fd-find
  fish
  gamemode
  gimp
  chntpw
  git-cola
  htop
  keepassxc
  kubuntu-restricted-extras
  lutris
  mpv
  obs-studio
  plasma-discover-backend-flatpak
  ppa-purge
  pulseaudio-modules-bt
  python3-{pip,venv}
  python3.9{,-venv}
  qbittorrent
  ripgrep
  qdirstat
  seahorse
  safeeyes
  shellcheck
  sirikali
  steam
  stow
  syncthing
  vitetris
  winehq-staging
  zeal
  sublime-text
)
# wine and steam need this
sudo dpkg --add-architecture i386
# Install my packages
sudo apt install --install-recommends -y "${packages[@]}"

# flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub io.github.antimicrox.antimicrox org.telegram.desktop com.github.vladimiry.ElectronMail com.github.ztefn.haguichi com.spotify.Client com.discordapp.Discord com.github.micahflee.torbrowser-launcher com.mojang.Minecraft org.freefilesync.FreeFileSync com.neatdecisions.Detwinner com.dropbox.Client org.gtk.Gtk3theme.Breeze
sudo flatpak override org.telegram.desktop --filesystem=home
sudo flatpak override com.discordapp.Discord --filesystem=home

# python
pip3 install -U git+https://github.com/simons-public/protonfixes@master protontricks

# /etc/pam.d/sudo and /etc/pam.d/polkit-1
sudo apt install -y fprintd libpam-fprintd
sudo pam-auth-update

# setup dofiles
../etc_cp/install.sh
../home/install.sh

systemctl --user enable --now syncthing
chsh -s /usr/bin/fish

# fuck this shit
sudo update-locale --reset

# SBC HD
# https://github.com/EHfive/pulseaudio-modules-bt/issues/63#issuecomment-613432583 https://gitlab.freedesktop.org/pulseaudio/pulseaudio/-/merge_requests/227
sudo sed -i 's|load-module module-bluetooth-discover$|load-module module-bluetooth-discover a2dp_config="sbc_min_bp=47 sbc_max_bp=47 sbc_freq=44k sbc_cmode=dual sbc_alloc=loudness sbc_sbands=8 sbc_blen=16"|g' /etc/pulse/default.pa

mkdir -p $HOME/.local/bin