#!/bin/bash
sudo add-apt-repository -y ppa:berglh/pulseaudio-a2dp
sudo add-apt-repository -y ppa:lutris-team/lutris
sudo add-apt-repository -y ppa:maxiberta/kwin-lowlatency
sudo add-apt-repository -y ppa:cdemu/ppa
sudo add-apt-repository -y ppa:kubuntu-ppa/backports
sudo add-apt-repository -y ppa:tomtomtom/woeusb
sudo add-apt-repository -y ppa:libretro/stable
sudo add-apt-repository -y ppa:feignint/dosbox-staging
wget -qO - https://deb.nodesource.com/setup_current.x | sudo -E bash -
sudo dpkg-reconfigure code # re-enable repo after upgrade
# https://wiki.winehq.org/Ubuntu
wget -qO - https://dl.winehq.org/wine-builds/winehq.key | sudo apt-key add -
sudo add-apt-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ groovy main'
# linux-kernel for fsync
echo 'deb https://deb.xanmod.org releases main' | sudo tee /etc/apt/sources.list.d/xanmod-kernel.list && wget -qO - https://dl.xanmod.org/gpg.key | sudo apt-key add -
# rclone with mega backend https://github.com/rclone/rclone/issues/3980
echo "deb https://packages.azlux.fr/debian/ buster main" | sudo tee /etc/apt/sources.list.d/azlux.list
wget -qO - https://azlux.fr/repo.gpg.key | sudo apt-key add -
# can be disabled on distro upgrade
sudo add-apt-repository -y ppa:kisak/kisak-mesa
sudo add-apt-repository -y ppa:mymedia/telegram

sudo apt upgrade -y

cd /tmp || exit 1
# https://www.egregorion.net/ https://store.kde.org/p/1231579/
wget --content-disposition 'https://go.microsoft.com/fwlink/?LinkID=760868' https://www.egregorion.net/works/kde/servicemenus/reimage/kde-service-menu-reimage_2.5_all.deb https://github.com/Syncplay/syncplay/releases/download/v1.6.6/syncplay_1.6.6.deb
sudo apt install -y ./kde-service-menu-reimage*.deb ./syncplay*.deb ./code*.deb

packages=(
  # optdeps
  # partitionmanager
  smartmontools # TODO: https://bugs.kde.org/show_bug.cgi?id=422877 https://www.phoronix.com/scan.php?page=news_item&px=Plasma-5.20-SMART-More replace with https://repology.org/project/plasma-disks/versions https://invent.kde.org/neon/neon/seeds/-/blob/Neon/unstable/desktop#L89
  # dolphin
  dolphin-plugins # https://invent.kde.org/neon/neon/seeds/-/blob/Neon/unstable/desktop#L94
  # boxtron
  inotify-tools timidity fluid-soundfont-gm
  # not deps
  adb
  bleachbit
  colobot
  dosbox-staging
  earlyoom
  fd-find
  fish
  gamemode
  gcdemu
  gimp
  git-cola
  htop
  internetarchive
  keepassxc
  kubuntu-restricted-extras
  linux-xanmod
  lutris
  mpv
  obs-studio
  openmw-launcher
  piper
  plasma-discover-backend-flatpak
  ppa-purge
  pulseaudio-modules-bt
  python3-{pip,venv}
  qbittorrent
  qdirstat
  rclone-browser
  retroarch
  ripgrep
  safeeyes
  shellcheck
  sirikali
  steam
  stow
  syncthing
  telegram-desktop
  translate-shell
  vitetris
  winehq-staging
  woeusb
  xclip
  yarnpkg
  zeal
)
# wine and steam need this
sudo dpkg --add-architecture i386
# Install my packages
sudo apt install --install-recommends -y "${packages[@]}"

# dupeguru https://github.com/arsenetar/dupeguru/issues/484
git clone --depth=1 https://github.com/arsenetar/dupeguru /tmp/dupeguru
cd /tmp/dupeguru || exit 1
bash -c "python3 -m venv --system-site-packages env && source env/bin/activate && pip install -r requirements.txt && python3 build.py --clean && python3 package.py"
cd build || exit 1
sudo apt install ./dupeguru*.deb

# snaps https://snapcraft.io/docs/keeping-snaps-up-to-date
# https://bugs.launchpad.net/snappy/+bug/1887217
sudo snap set system refresh.retain=2
sudo snap set system refresh.timer=fri,9:00~21:00

# node
yarn set version berry

# flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub org.jdownloader.JDownloader org.taisei_project.Taisei com.viber.Viber com.github.vladimiry.ElectronMail com.github.ztefn.haguichi com.spotify.Client com.discordapp.Discord com.github.micahflee.torbrowser-launcher com.mojang.Minecraft io.github.antimicrox.antimicrox com.uploadedlobster.peek  com.neatdecisions.Detwinner org.gtk.Gtk3theme.Breeze
flatpak install -y https://flatpak.citra-emu.org/citra-nightly.flatpakref
flatpak install -y https://flathub.org/beta-repo/appstream/com.obsproject.Studio.flatpakref # for wayland

# python
pip3 install -U git+https://github.com/mrjackv/protonfixes.git@fix_soldier protontricks vdf git+https://github.com/z411/trackma

# mpv scripts
cd "$HOME/.config/mpv/scripts" || exit 1
curl -LO https://raw.githubusercontent.com/ElegantMonkey/mpv-webm/master/build/webm.lua

# setup dofiles
../etc_cp/install.sh
../home/install.sh

systemctl enable --now amdgpu
systemctl --user enable --now syncthing
chsh -s /usr/bin/fish

# SBC HD
# https://github.com/EHfive/pulseaudio-modules-bt/issues/63#issuecomment-613432583 https://gitlab.freedesktop.org/pulseaudio/pulseaudio/-/merge_requests/227
sudo sed -i 's|load-module module-bluetooth-discover|load-module module-bluetooth-discover a2dp_config="sbc_min_bp=47 sbc_max_bp=47 sbc_freq=44k sbc_cmode=dual sbc_alloc=loudness sbc_sbands=8 sbc_blen=16"|g' /etc/pulse/default.pa
