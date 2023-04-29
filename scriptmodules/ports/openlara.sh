#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="openlara"
rp_module_desc="OpenLara - Classic Tomb Raider open-source engine"
rp_module_licence="BSD 2-Clause License https://github.com/XProger/OpenLara/blob/master/LICENSE"
rp_module_section="opt"
rp_module_repo="git https://github.com/XProger/OpenLara master"
rp_module_flags="!x86 !mali !kms"

function depends_openlara() {
  getDepends git clang libx11-dev libgl1-mesa-dev libpulse-dev
}

function sources_openlara() {
  gitPullOrClone
  applyPatch "$md_data/dragonrise_joy.patch"
  applyPatch "$md_data/tr3_audiotrack.patch"
  if isPlatform "rpi"; then
    applyPatch "$md_data/rpi_opengl.patch"
  fi
  applyPatch "$md_data/tr2_file_case.patch"
}

function build_openlara() {
  cd "$md_build/src/platform/rpi"
  ./build.sh
}

function install_bin_openlara {
  aptInstall "openlara"
  aptInstall "openlara-tr1-data"
  aptInstall "openlara-tr2-data"
  aptInstall "openlara-tr3-data"
}

function install_openlara() {
  md_ret_files=('bin/OpenLara')
}

function download_asset() {
  local url="$1"
  local file="$2"
  [ -d ${file%/*} ] \
    || mkdir -p ${file%/*}
  [ -f $file ] \
    || wget $url -O $file
  [ -s $file ] \
    || rm $file
  try_uncompress_file $2
}

function try_uncompress_file() {
  file ${1} | grep gzip \
    && mv ${1} ${1}.gz \
      && gzip -dN ${1}.gz
}

function game_data_openlara() {
  typeset openlara_url
  cut -f2 -d' ' <<< $rp_module_repo | read openlara_url
  [ -f $md_build/src/gameflow.h ] || gitPullOrClone
  perl -lne 'if (/"(\S+)"\s*,\s*"(.*)",\s*([A-Z_]*([0-9])|NO_TRACK)/){if(defined $4){print "$4 $1 $2";$l=$4}else{print "$l $1 $2"}}' $md_build/src/gameflow.h \
  | while read part level name; do
    download_asset "$openlara_url/level/$part/$level.PSX" "$romdir/ports/$md_id/level/$part/$level.PSX"
  done
  local audio_dir=$romdir/ports/$md_id/audio
  for part in 1 2; do 
    for s in $(seq -w 2 61); do
      download_asset "$openlara_url/audio/$part/track_$s.ogg" "$audio_dir/$part/track_$s.ogg"
    done
  done
  for s in $(seq -w 2 99) $(seq -w 100 123); do
    download_asset "$openlara_url/audio/3/track_$s.wav" "$audio_dir/3/track_$s.wav"
  done
  for v in PNG Web; do
    for asset in $(awk -F\" '(/'$v'/) {print $2}' $md_build/src/gameflow.h); do
      download_asset "$openlara_url/$asset" "$romdir/ports/$md_id/$asset"
    done
  done
  # always chown as moveConfigDir in the configure_ script would move the root owned demo files
  chown -R $user:$user "$romdir/ports/openlara"
}

function configure_openlara() {
  local bindir datadir dir
  for dir in level audio; do
    mkdir -p "$romdir/ports/$md_id/$dir"
    ln -snf "$romdir/ports/$md_id/$dir" "$md_inst/$dir"
  done
  dpkg -s openlara 1>/dev/null 2>&1 \
    && bindir=/usr/bin \
      || bindir=$md_inst
  dpkg -s openlara-tr1-data 1>/dev/null 2>&1 \
    || game_data_openlara
  for part in 1 2 3; do 
    dpkg -s openlara-tr${part}-data 1>/dev/null 2>&1 \
      && datadir=/usr/share/$md_id/tr${part} \
        || datadir=$romdir/ports/$md_id/${part}
    [ -d ${datadir} ] \
      && addPort "$md_id-tr${part}" "openlara-tr${part}" "Tomb Raider ${part}" "pushd $datadir; $bindir/OpenLara %ROM%; popd"
  done
  [ -f $md_build/src/gameflow.h ] || gitPullOrClone
  for part in 1 2 3; do
    dpkg -s openlara-tr${part}-data 1>/dev/null 2>&1 \
      && datadir=/usr/share/$md_id/tr${part} \
        || datadir=$romdir/ports/$md_id/${part}
    paste <(grep -Po '(?<=")[A-Z0-9]+(?="\s+, STR_TR'${part}'_)' $md_build/src/gameflow.h) \
          <(grep -Pzo '(?s)(?<=TR'${part}' levels\n)[^/]*(?=//|};)' $md_build/src/lang/en.h \
            | grep -Poa '(?<=")[^"]+(?=")') \
    | while read level name; do
      case $part in
      $last_part)
         :;;
      *) 
         i=0;;
      esac
      [ -n "$name" ] \
        && printf -v i '%02d' $i \
          && for ext in PHD PSX TR2 tr2 tr4; do
               file="$(find ${datadir} -iname "${level}.${ext}" -printf %P)"
               [ -f "${datadir}/${file}" ] \
                 && addPort "${md_id}-tr${part}" "openlara-tr${part}" "TR${part}: $i $name" "pushd $datadir; $bindir/OpenLara %ROM%; popd" "$file" \
                   && i=$((10#$i+1)) \
                     && last_part=$part \
                       && break
             done      
    done   
  done
}

function remove_openlara() {
  rm -rf $romdir/ports/$md_id 
  for part in 1 2 3; do
    delEmulator ${md_id}-tr${part} ${md_id}-tr${part}
  done
}
