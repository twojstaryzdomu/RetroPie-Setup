#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="hexen2-sdl12"
rp_module_desc="Hexen II - Hammer of Thyrion source port (SDL1.2)"
rp_module_licence="GPL2 https://raw.githubusercontent.com/sezero/uhexen2/master/docs/COPYING"
rp_module_help="For registered version, please add your full version PAK files to $romdir/ports/hexen2-sdl1/data1/ to play. These files for the registered version are required: pak0.pak, pak1.pak and strings.txt. The registered pak files must be patched to 1.11 for Hammer of Thyrion."
rp_module_section="exp"
rp_module_flags=""

function depends_hexen2-sdl12() {
    getDepends cmake libsdl1.2-dev libsdl-net1.2-dev libsdl-sound1.2-dev libsdl-mixer1.2-dev libsdl-image1.2-dev timidity freepats
}

function sources_hexen2-sdl12() {
#    gitPullOrClone "$md_build" https://github.com/sezero/uhexen2
    gitPullOrClone "$md_build" https://github.com/twojstaryzdomu/uhexen2
}

function build_hexen2-sdl12() {
    cd "$md_build/engine/hexen2"
    ./build_all.sh
    md_ret_require="$md_build/engine/hexen2/hexen2"
}

function install_hexen2-sdl12() {
    md_ret_files=(
       'engine/hexen2/hexen2'
    )
}

function game_data_hexen2-sdl12() {
    if [[ ! -f "$romdir/ports/hexen2-sdl12/data1/pak0.pak" ]]; then
        downloadAndExtract "https://netix.dl.sourceforge.net/project/uhexen2/Hexen2Demo-Nov.1997/hexen2demo_nov1997-linux-i586.tgz" "$romdir/ports/hexen2-sdl12" --strip-components 1 "hexen2demo_nov1997/data1"
        chown -R $user:$user "$romdir/ports/hexen2-sdl12/data1"
    fi
}

function install_bin_hexen2-sdl12() {
    aptInstall "uhexen2"
}

function remove_hexen2-sdl12() {
    delEmulator "$md_id" "hexen2-sdl12" 

    dpkg -s uhexen2 1>/dev/null 2>&1 && aptRemove "uhexen2"
}

function configure_hexen2-sdl12() {
    dpkg -s uhexen2 1>/dev/null 2>&1 && bindir=/usr/bin || bindir=$md_inst

    addPort "$md_id" "hexen2-sdl12" "Hexen II (SDL1)" "$bindir/hexen2 %ROM%"
    [ -d $romdir/ports/hexen2-sdl12/portals ] \
        && addPort "$md_id" "hexen2-sdl12" "Hexen II (SDL1) - Portal of Praevus" "$bindir/hexen2 %ROM%" "-portals"

    if dpkg -s hexen2-data 1>/dev/null 2>&1; then
        ln -sfT /usr/share/hexen2 "$romdir/ports/hexen2-sdl12"
    else
        mkRomDir "ports/hexen2-sdl12"

        moveConfigDir "$home/.hexen2" "$romdir/ports/hexen2-sdl12"

        [[ "$md_mode" == "install" ]] && game_data_hexen2-sdl12
    fi
}
