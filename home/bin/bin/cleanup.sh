#!/bin/bash

HOMEDIR="/home/bausch"
XDD="$HOMEDIR/.local/share"
rmlist=(
  #/var/lib/systemd/coredump/*
  /var/{cache,log}/*
  /var/log/journal
  "$HOMEDIR"/.pulse-cookie
  #$HOMEDIR/.*sh_history
  "$HOMEDIR"/.cache/{ranger,thumbnails,gstreamer-1.0,less,wine,youtube-dl,qt_compose_cache*}
  "$HOMEDIR/.dbus"
  "$XDD/{xorg,RecentDocuments}"
  "$XDD/*.xbel*"
)
/bin/rm -r "${rmlist[@]}"
/usr/bin/ccache -C
/usr/bin/find $HOMEDIR/.{config,cache} ! -path "*/syncthing/*" ! -path "*/zplug/*" -empty -delete
/usr/bin/find ! -path "*/Steam/*" ! -path "*/systemd/*" ! -path "*/lutris/*" -empty -delete
/usr/bin/fd -t f -H "^\.[0-9][0-9][0-9][0-9]?[0-9]?$" "$HOMEDIR" -x "rm" {}
/usr/bin/journalctl --vacuum-time=1d
/usr/bin/youtube-dl --rm-cache-dir
/usr/bin/psd c
/usr/bin/localepurge
/usr/bin/yay -Scc
