#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="sdlpop"
rp_module_desc="SDLPoP - Port of Prince of Persia"
rp_module_licence="GPL3 https://raw.githubusercontent.com/NagyD/SDLPoP/master/COPYING"
rp_module_repo="git https://github.com/NagyD/SDLPoP.git master"
rp_module_section="opt"

function depends_sdlpop() {
    getDepends libsdl2-dev libsdl2-mixer-dev libsdl2-image-dev
}

function sources_sdlpop() {
    gitPullOrClone
}

function install_bin_sdlpop {
    aptInstall "sdlpop"
}

function _update_hook_sdlpop () {
    # to show as installed in retropie-setup 4.x
    hasPackage "sdlpop" && mkdir -p "$md_inst"
}

function build_sdlpop() {
    cd src
    make
    md_ret_require="$md_build/prince"
}

function install_sdlpop() {
    md_ret_files=(
        'prince'
        'data'
        'doc'
        'COPYING'
    )
    cp -v "SDLPoP.ini" "$md_inst/SDLPoP.ini.def"
    sed -i "s/use_correct_aspect_ratio = false/use_correct_aspect_ratio = true/" "$md_inst/SDLPoP.ini.def"
}

function remove_sdlpop() {
    aptRemove "sdlpop"
    rm $romdir/ports/"Prince of Persia.sh"
}

function configure_sdlpop() {
    typeset cmd
    dpkg -s sdlpop >/dev/null 2>&1 \
        && cmd="prince" \
        || cmd="pushd $md_inst; $md_inst/prince full; popd"

    addPort "$md_id" "sdlpop" "Prince of Persia" "$cmd"

    [[ "$md_mode" == "remove" ]] && return

    copyDefaultConfig "$md_inst/SDLPoP.ini.def" "$md_conf_root/$md_id/SDLPoP.ini"
    moveConfigFile "$md_inst/SDLPoP.ini" "$md_conf_root/$md_id/SDLPoP.ini"

    moveConfigFile "$md_inst/PRINCE.SAV" "$md_conf_root/$md_id/PRINCE.SAV"
    moveConfigFile "$md_inst/QUICKSAVE.SAV" "$md_conf_root/$md_id/QUICKSAVE.SAV"
    moveConfigFile "$md_inst/SDLPoP.cfg" "$md_conf_root/$md_id/SDLPoP.cfg"

    chown -R $user:$user "$md_conf_root/$md_id"
}
