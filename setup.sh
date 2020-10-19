#!/bin/bash
#### REPOS START
sudo add-apt-repository -y ppa:berglh/pulseaudio-a2dp # https://github.com/EHfive/pulseaudio-modules-bt/issues/132
# wine
wget -qO - https://dl.winehq.org/wine-builds/winehq.key | sudo apt-key add -
sudo add-apt-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ focal main'
# can be disabled on distro upgrade
sudo add-apt-repository -y ppa:kisak/kisak-mesa
sudo add-apt-repository -y ppa:mymedia/telegram
sudo add-apt-repository -y ppa:kubuntu-ppa/backports
# groovy is supported
sudo add-apt-repository -y ppa:cdemu/ppa
sudo add-apt-repository -y ppa:lutris-team/lutris
sudo add-apt-repository -y ppa:maxiberta/kwin-lowlatency
#### REPOS END

sudo apt upgrade -y

cd /tmp || exit 1
# syncplay
wget --content-disposition https://github.com/Syncplay/syncplay/releases/download/v1.6.5/syncplay_1.6.5.deb
sudo apt install -y ./syncplay*.deb
# vscode
wget --content-disposition 'https://go.microsoft.com/fwlink/?LinkID=760868'
sudo apt install -y ./code*.deb

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
  gcdemu
  gimp
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
  qbittorrent
  ripgrep
  safeeyes
  shellcheck
  sirikali
  steam
  stow
  syncthing
  telegram-desktop
  vitetris
  winehq-staging
  zeal
)
# wine and steam need this
sudo dpkg --add-architecture i386
# Install my packages
sudo apt install --install-recommends -y "${packages[@]}"

# snap
sudo snap set system refresh.retain=2
sudo snap set system refresh.timer=fri,9:00~21:00

# vmware https://www.namhuy.net/227/enable-3d-hardware-graphics-acceleration-for-vmware-workstation-on-ubuntu
echo 'mks.gl.allowBlacklistedDrivers = "TRUE"' >> "$HOME/.vmware/preferences"

# flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.github.vladimiry.ElectronMail com.github.ztefn.haguichi com.spotify.Client com.discordapp.Discord com.github.micahflee.torbrowser-launcher com.mojang.Minecraft org.freefilesync.FreeFileSync org.gtk.Gtk3theme.Breeze

# /etc/pam.d/sudo and /etc/pam.d/polkit-1
sudo apt install -y fprintd libpam-fprintd
sudo pam-auth-update

# python
pip3 install -U git+https://github.com/simons-public/protonfixes.git protontricks vdf

# setup dofiles
../etc_cp/install.sh
../home/install.sh

systemctl --user enable --now syncthing
chsh -s /usr/bin/fish

# meh
# https://wiki.archlinux.org/index.php/XDG_Autostart
# https://bugs.kde.org/show_bug.cgi?id=413053#c7
mkdir "$HOME/.config/autostart"
cd "$HOME/.config/autostart" || exit 1
sed -e '$aHidden=True' /etc/xdg/autostart/org.kde.discover.notifier.desktop > org.kde.discover.notifier.desktop
sed -e '$aHidden=True' /etc/xdg/autostart/gcdemu.desktop > gcdemu.desktop

# SBC HD
# https://github.com/EHfive/pulseaudio-modules-bt/issues/63#issuecomment-613432583 https://gitlab.freedesktop.org/pulseaudio/pulseaudio/-/merge_requests/227
sudo sed -i 's|load-module module-bluetooth-discover|load-module module-bluetooth-discover a2dp_config="sbc_min_bp=47 sbc_max_bp=47 sbc_freq=44k sbc_cmode=dual sbc_alloc=loudness sbc_sbands=8 sbc_blen=16"|g' /etc/pulse/default.pa

mkdir -p $HOME/.local/bin