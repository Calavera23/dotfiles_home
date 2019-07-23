# shellcheck disable=2034,2148

# play all in mpv
mpa() { if [[ -d "${PWD}/VIDEO_TS" ]] || [[ -d "${PWD}/BDMV" ]]; then
    mpv "${PWD}"
  else
    files=( $(ls -b ${PWD}/*.{mp4,mkv,webm,avi,wmv} 2>/dev/null) )
    mpv "${PWD}"/"${1:-${files[@]}}" "$2"
  fi
}

# Create a new directory and enter it.
# In oh-my-zsh take function is identical to this
mkd() {
  mkdir -p "$@" && cd "$_" || exit 1;
}

# `tre` is a shorthand for `tree` with hidden files and color enabled, ignoring
# the `.git` directory, listing directories first. The output gets piped into
# `less` with options to preserve color and line numbers, unless the output is
# small enough for one screen.
tre() {
  tree -aC -I '.git|node_modules|bower_components' --dirsfirst "$@" | less -FRNX;
}

# Convert currencies; cconv {amount} {from} {to}
#cconv() {
#  curl --socks5-hostname 127.0.0.1:9250 -s "https://finance.google.com/finance/converter?a=$1&from=$2&to=$3&hl=es" | sed '/res/!d;s/<[^>]*>//g';
#}

# Convert currencies; cconv {amount} {from} {to}
# https://stackoverflow.com/questions/13242469/how-to-use-sed-grep-to-extract-text-between-two-words
cconv() {
  #| grep '&#8372;</strong>'
  result="$(curl -s "https://exchangerate.guru/$2/$3/$1/" | grep --color=never -o -P '(?<=<input data-role="secondary-input" type="text" class="form-control" value=").*(?=" required>)')"
  echo "$1 $2 = $result $3"
}

# Upload to transfer.sh
transfer() { if [ $# -eq 0 ]; then echo "No arguments specified. Usage:\necho transfer /tmp/test.md\ncat /tmp/test.md | transfer test.md"; return 1; fi
             tmpfile=$( mktemp -t transferXXX ); if tty -s; then basefile=$(basename "$1" | sed -e 's/[^a-zA-Z0-9._-]/-/g'); curl --progress-bar --upload-file "$1" "https://transfer.sh/$basefile" >> "$tmpfile"; else curl --progress-bar --upload-file "-" "https://transfer.sh/$1" >> "$tmpfile" ; fi; cat "$tmpfile"; rm -f "$tmpfile"; }

# Background with log
# https://github.com/mpv-player/mpv/issues/1377#issuecomment-90370504
bkg() {
  logfile=$(mktemp -t "$(basename $1)"-"$(date +%d.%m.%G-%T)"-XXX.log)
  nohup "$@" &>"$logfile" &
}

wttr() {
  # moon or city name
  curl -A curl -k https://wttr.in/"${1}"?lang=ru
}

# Calculate actual size of {HD,SS}D; actualsize {size} {gb}[optional, use gigabytes instead of terabytes]
# http://www.sevenforums.com/hardware-devices/23890-hdds-advertized-size-vs-actual-size.html
actualsize() {
  if [[ "$2" == gb ]]; then a="0.9313226"; else a="0.9094947"; fi
  echo 'Actual size is:' "$(bc -l <<< "$1 * $a")"
}

# Calculate ppi; ppicalc {widght} {height} {display size[eg 27]}
# http://isthisretina.com/
# https://en.wikipedia.org/wiki/Pixel_density#Calculation_of_monitor_PPI
ppicalc() {
  echo 'DPI/PPI is:' "$(bc <<< "sqrt($1^2+$2^2)/$3")"
}

# 5gb max
# stores for 24 hours
cockfile() {
   if [[ "$1" =~ ^https?://.*$ ]]; then local prefix="curl --fail -L --progress-bar ${1} || exit 1"; else local suffix="${1}"; fi
   # eval or sh -c
   eval "${prefix:-true}" | curl --fail -L --progress-bar -F name="${2:-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 20 | head -n 1 | grep -i '[a-zA-Z0-9]').${1##*.}}" -F file=@"${suffix:--}" https://cockfile.com/api.php?d=upload-tool
}

# Validate tar archives
tarval() {
  tar -tJf "$@" >/dev/null
}

# Automatically cd to the directory you were in when quitting ranger if you haven't already:
ranger() {
    tempfile="$(mktemp -t ranger-tmp.XXXXXX)"
    /usr/bin/ranger --choosedir="$tempfile" "${@:-$(pwd)}"
    test -f "$tempfile" &&
    if [ "$(cat -- "$tempfile")" != "$(echo -n "$(pwd)")" ]; then
        cd -- "$(cat "$tempfile")"
    fi
    rm -f -- "$tempfile"
}

# Algorithm borrowed from http://wiki.rtorrent.org/MagnetUri and adapted to work with zsh.
# Copied from https://github.com/robbyrussell/oh-my-zsh/blob/master/plugins/torrent/torrent.plugin.zsh
magnet_to_torrent() {
  [[ "$1" =~ xt=urn:btih:([^\&/]+) ]] || return 1
  hashh=${match[1]}
  if [[ "$1" =~ dn=([^\&/]+) ]]; then
    filename=${match[1]}
  else
    filename=$hashh
  fi
  echo "d10:magnet-uri${#1}:${1}e" > "$filename.torrent"
}


px() {
  # https://stackoverflow.com/questions/23258413/expand-aliases-in-non-interactive-shells/23259088#23259088
  setopt aliases
  _command="$(which "$1" | sed 's/.*: aliased to //g' )"
  # http://wiki.bash-hackers.org/syntax/pe#substring_expansion
  eval proxychains -q "$_command" ${@:2}
}

j() {
case "$1" in
  g) cd "$HOME/git" ;;
  s) cd "$HOME/sync" ;;
  t) cd /media/disk0/torrents ;;
  gd) cd "$HOME/sync/main/Documents/googledocs" ;;
  dch) cd "$HOME/sync/main/Documents/dollchan" ;;
  b) cd "$HOME/sync/main/Documents/bookmarks" ;;
  bak) cd "$HOME/sync/system-data" ;;
  m) cd "$HOME/media" ;;
  *) echo "No folder defined for this alias." ;;
esac
}

random() {
  shuf -i "${1}-${2}" -n "${3:-1}"
}

linuxsteamgames() {
  _url="https://store.steampowered.com/search/?category1=998&os="
  for os in win linux mac; do
    local ${os}games="$(curl --http2 -s "${_url}${os}" | grep -o "showing 1 - 25 of [0-9]*" | sed "s/showing 1 - 25 of //")"
  done
  echo "Windows steam games: ${wingames}"
  echo "Mac steam games: ${macgames}"
  echo "Linux steam games: ${linuxgames}"
  # https://stackoverflow.com/a/41265735
  echo "Percentage of linux games compared to windows:" $(echo "scale = 2; ($linuxgames / $wingames)" | bc -l | awk -F '.' '{print $2}')%
  echo "Percentage of linux games compared to macOS:" $(echo "scale = 2; ($linuxgames / $macgames)" | bc -l | awk -F '.' '{print $2}')%
}

# https://stackoverflow.com/a/10060342
# https://stackoverflow.com/a/10060342
# 512mb max
# stores for 30+ days
0x0() {
  if [[ "$1" =~ ^http?[s]://.*$ ]]; then local prefix="url="; else local prefix="file=@"; fi
  curl -F"${prefix}${1}" https://0x0.st
}

# https://github.com/chrippa/livestreamer/issues/550#issuecomment-222061982
streamnodown() {
  streamlink --loglevel debug --player-external-http --player-no-close --player-external-http-port "5555" --retry-streams 1 --retry-open 100 --stream-segment-attempts 20 --stream-timeout 180 --ringbuffer-size 64M --rtmp-timeout 240 "$1" "${2}"
}

# backup
backup() {
  # local
  cps "$HOME/sync/arch" "$HOME/sync/system-data" "$XDG_DATA_HOME/keepass/NewDatabase.kdbx" /media/disk0/backup
  cps "$XDG_DATA_HOME/keepass/NewDatabase.kdbx" "/run/media/bausch/Windows 10/Users/User/Desktop/"
  cps "$XDG_DATA_HOME/keepass/NewDatabase.kdbx" "$HOME/sync/share/"
  # dropbox
  #rclone sync --fast-list -P "$HOME/sync/arch" dropbox:/arch
  rclone sync --fast-list -P "$XDG_DATA_HOME/keepass/NewDatabase.kdbx" dropbox:/
  # opendrive
  rclone sync -P "$XDG_DATA_HOME/keepass/NewDatabase.kdbx" opendrive:/
  # google drive
  #rclone sync --drive-use-trash --fast-list -P "$HOME/sync/arch" google_drive:/arch
  rclone sync --drive-use-trash --fast-list -P "$HOME/sync/system-data" google_drive:/system-data
  rclone sync --drive-use-trash -P "$XDG_DATA_HOME/keepass/NewDatabase.kdbx" google_drive:/
  # mega.nz
  #rclone sync --mega-hard-delete --fast-list -P "$HOME/sync/arch" 50gbmega:/arch
  rclone sync --mega-hard-delete --fast-list -P "$HOME/sync/main/Documents" 50gbmega:/Documents
  rclone sync --mega-hard-delete --fast-list -P "$HOME/sync/main/me" 50gbmega:/me
  rclone sync --mega-hard-delete --fast-list -P "$HOME/sync/main/Images" 50gbmega:/Images
  rclone sync --mega-hard-delete --fast-list -P "$HOME/sync/system-data" 50gbmega:/system-data
  rclone sync --mega-hard-delete --fast-list -P "$XDG_DATA_HOME/keepass/NewDatabase.kdbx" 50gbmega:/
  # yandex.disk
  #rclone sync --fast-list -P "$HOME/sync/arch" mega_nz:/arch
  #rclone sync --fast-list -P "$HOME/sync/system-data" mega_nz:/system-data
  #rclone sync --fast-list -P "$XDG_DATA_HOME/keepass/NewDatabase.kdbx" mega_nz:/
}

update-grub() {
  # mount esp
  [[ ! $(grep /boot/efi /proc/mounts)  ]] && sudo mount /boot/efi
  # copy microcode
  sudo cp /boot/amd-ucode.img /boot/efi
  # generate config
  ZPOOL_VDEV_NAME_PATH=1 sudo -E grub-mkconfig -o /boot/grub/grub.cfg
  sudo umount /boot/efi
}
