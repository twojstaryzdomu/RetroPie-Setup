#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="dolphin"
rp_module_desc="Gamecube/Wii emulator Dolphin"
rp_module_help="ROM Extensions: .gcm .iso .wbfs .ciso .gcz .rvz .wad .wbfs\n\nCopy your Gamecube roms to $romdir/gc and Wii roms to $romdir/wii"
rp_module_licence="GPL2 https://raw.githubusercontent.com/dolphin-emu/dolphin/master/COPYING"
rp_module_repo="git https://github.com/dolphin-emu/dolphin.git master :_get_commit_dolphin"
rp_module_section="exp"
rp_module_flags="!all 64bit"

function _get_commit_dolphin() {
    local commit
    # current HEAD of dolphin doesn't build without a C++20 capable compiler
    [[ "$__gcc_version" -lt 10 ]] && commit="f59f1a2a"
    # support gcc 8.4.0 for Ubuntu 18.04
    [[ "$__gcc_version" -lt 9  ]] && commit="1c0ca09e"
    echo "$commit"
}

function depends_dolphin() {
    local depends=(cmake gettext pkg-config libao-dev libasound2-dev libavcodec-dev libavformat-dev libbluetooth-dev libenet-dev liblzo2-dev libminiupnpc-dev libopenal-dev libpulse-dev libreadline-dev libsfml-dev libsoil-dev libsoundtouch-dev libswscale-dev libusb-1.0-0-dev libxext-dev libxi-dev libxrandr-dev portaudio19-dev zlib1g-dev libudev-dev libevdev-dev libmbedtls-dev libcurl4-openssl-dev libegl1-mesa-dev liblzma-dev)
    if [[ "$__gcc_version" -lt 8 ]]; then
        md_ret_errors+=("Sorry, you need an OS with gcc 8 or newer to compile $md_id")
        return 1
    fi
    # check if qt6 is available, otherwise use qt5
    local has_qt6=$(apt-cache madison qt6-base-private-dev 2>/dev/null | cut -d'|' -f1)
    if [[ -n "$has_qt6" ]]; then
        depends+=(qt6-base-private-dev)
    else
        depends+=(qt5-base-private-dev)
    fi
    getDepends "${depends[@]}"
}

function sources_dolphin() {
    gitPullOrClone
}

function build_dolphin() {
    mkdir build
    cd build
    # use the bundled 'speexdsp' libs, distro versions before 1.2.1 produce a 'cmake' error
    cmake .. -DBUNDLE_SPEEX=ON -DCMAKE_INSTALL_PREFIX="$md_inst"
    make clean
    make
    md_ret_require="$md_build/build/Binaries/dolphin-emu"
}

function install_dolphin() {
    cd build
    make install
}

function configure_dolphin() {
    mkRomDir "gc"
    mkRomDir "wii"

    moveConfigDir "$home/.dolphin-emu" "$md_conf_root/gc"

    if [[ ! -f "$md_conf_root/gc/Config/Dolphin.ini" ]]; then
        mkdir -p "$md_conf_root/gc/Config"
        cat >"$md_conf_root/gc/Config/Dolphin.ini" <<_EOF_
[Display]
FullscreenResolution = Auto
Fullscreen = True
_EOF_
        chown -R $user:$user "$md_conf_root/gc/Config"
    fi

    addEmulator 1 "$md_id" "gc" "$md_inst/bin/dolphin-emu-nogui -e %ROM%"
    addEmulator 0 "$md_id-gui" "gc" "$md_inst/bin/dolphin-emu -b -e %ROM%"
    addEmulator 1 "$md_id" "wii" "$md_inst/bin/dolphin-emu-nogui -e %ROM%"
    addEmulator 0 "$md_id-gui" "wii" "$md_inst/bin/dolphin-emu -b -e %ROM%"

    addSystem "gc"
    addSystem "wii"
}
