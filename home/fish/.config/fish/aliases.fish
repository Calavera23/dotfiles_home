# rclone alias
# TODO: remove when https://github.com/rclone/rclone/issues/2697 is done
alias uploadd 'rclone sync --transfers 8 --delete-excluded --fast-list --delete-before'
# Better copy, move, copy with update and synchronize folder aliases
# --archive = archive mode; equals -rlptgoD (no -H,-A,-X)
alias mrsync='rsync --archive --hard-links --acls --xattrs --compress --progress --verbose --executability -h'
alias bcp='mrsync'
alias bmv='mrsync --remove-source-files'
alias cpu='mrsync --update'
alias cps='mrsync --update --delete'
# Shorter
# https://wiki.archlinux.org/index.php/Kexec
alias kernelup 'sudo kexec -l /boot/vmlinuz-linux-tkg-pds-zen --initrd=/boot/initramfs-linux-tkg-pds-zen.img --reuse-cmdline && systemctl kexec'
# find broken symlinks
alias badlinks 'find . -type l -exec test ! -e {} \; -print'
# https://wiki.archlinux.org/index.php/.SRCINFO https://wiki.archlinux.org/index.php/Arch_package_guidelines
alias aurup 'makepkg --printsrcinfo > .SRCINFO; updpkgsums'
#alias build_proton 'tkgup; cd wine-tkg-git/proton-tkg && ./proton-tkg.sh'
#alias build_wine 'tkgup; cd wine-tkg-git/wine-tkg-git && makepkg -si'
#alias mountandroidfs 'sshfs -o kernel_cache android:/ /media/android'
alias back 'cd $OLDPWD'
alias build_all 'build_faudio && build_staging'
alias build_faudio 'tkgup; cd faudio-git && makepkg -si' # https://github.com/Tk-Glitch/PKGBUILDS/issues/458#issuecomment-575811620 and https://git.archlinux.org/svntogit/community.git/tree/trunk/PKGBUILD?h=packages/lib32-faudio#n30
alias build_staging 'tkgup; cd wine-tkg-git/wine-tkg-git && ./non-makepkg-build.sh $HOME/.config/frogminer/wine-tkg-staging.cfg'
alias e 'code'
alias exip 'curl -s https://ipecho.net/plain'
alias finddupes 'jdupes -R -Nd1Ap'
alias g 'git'
alias jc 'journalctl'
alias jcu 'journalctl --user'
alias linkmusic 'ln -sfv /media/disk0/torrents/Music/* $HOME/Music'
alias ls 'ls --color=auto -ah --quoting-style=escape --group-directories-first'
alias sc 'systemctl'
alias scu 'systemctl --user'
alias t_danet2 'telegram-desktop -many -workdir $HOME/.local/share/TelegramDesktop_danet2'
alias tkgup 'cd $HOME/git/PKGBUILDS; git reset --hard origin/frogging-family; git submodule foreach --recursive git reset --hard origin; git pull'
alias vts 'echo vitetris --connect (exip):27015 && vitetris -listen 27015'