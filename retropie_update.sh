#!/bin/sh

if [ $(id -u) -ne 0 ]; then
  sudo -E "$0"
  exit $?
fi

scriptdir="$(dirname "$0")"
scriptdir="$(cd "$scriptdir" && pwd)"

IAMSURE=y __nodialog=0 "$scriptdir/retropie_packages.sh" setup update_packages_gui
