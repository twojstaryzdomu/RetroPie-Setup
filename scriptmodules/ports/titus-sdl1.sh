#!/bin/ksh

rp_module_id="titus-sdl1"
rp_module_desc="Blues Brothers, Blues Brothers Jukebox Adventure & Prehistorik 2 (SDL1)"
rp_module_repo="git https://github.com/twojstaryzdomu/blues-sdl1 sdl1"
rp_module_section="opt"

function depends_titus-sdl1() {
    getDepends libsdl1.2-dev
}

function sources_titus-sdl1() {
    gitPullOrClone
}

function build_titus-sdl1() {
    if isPlatform "rpi"; then
        applyPatch "$md_data/titus-sdl1-datapath.patch"
    fi
    make
    md_require_files=(
        'pre2'
        'blues'
        'bbja'
    )
}

function install_titus-sdl1() {
    md_ret_files=(
        'pre2'
        'blues'
        'bbja'
    )
    for f in ${md_ret_files[@]}; do
        ln -sf $f $md_inst/${f}-sdl1
    done
}

function _update_hook_titus-sdl1() {
    # to show as installed in retropie-setup 4.x
    hasPackage "titus-sdl1" && mkdir -p "$md_inst"
}

function addPort2 {
    filename="$1"
    cmd="$2"
    options="$3"
    [ -d "${romdir}/ports" ] || mkdir -p "${romdir}/ports"
    echo -e "#!/bin/bash\n${cmd} ${options}" > "${romdir}/ports/${filename}.sh"
    chown pi:pi "${romdir}/ports/${filename}.sh"
    chmod 755 "${romdir}/ports/${filename}.sh"
}

function install_bin_titus-sdl1 {
    aptInstall "titus-sdl1"
}

function remove_titus-sdl1 {
    aptRemove "titus-sdl1"
    rm $romdir/ports/"Blues Brothers.sh" $romdir/ports/"Blues Brothers (1920x1040).sh" \
    rm $romdir/ports/"Blues Brothers Jukebox Adventure.sh" $romdir/ports/"Blues Brothers Jukebox Adventure (1920x1040).sh" \
      $romdir/ports/"Prehistorik 2.sh" $romdir/ports/"Prehistorik 2 (1920x1040).sh"
}

function configure_titus-sdl1 {
    dpkg -s titus-data >/dev/null 2>&1 \
        && [ -d /usr/share/titus ] \
            && typeset datapath="--datapath /usr/share/titus"
    addPort "$md_id" "blues-sdl1" "Blues Brothers (SDL1)" "sudo blues-sdl1 --fullscreen${datapath:+ ${datapath}/blues}"
    addPort2 "Blues Brothers Jukebox Adventure (SDL1)" "sudo bbja-sdl1" "--fullscreen${datapath:+ ${datapath}/bbja}"
    addPort2 "Blues Brothers (SDL1)" "sudo blues-sdl1" "--fullscreen${datapath:+ ${datapath}/blues}"
    addPort2 "Prehistorik 2 (SDL1)" "sudo pre2-sdl1" "--fullscreen${datapath:+ ${datapath}/pre2}"
    addPort2 "Blues Brothers Jukebox Adventure (1920x1040) (SDL1)" "bbja-sdl1" "--screensize=1920x1040${datapath:+ ${datapath}/bbja}"
    addPort2 "Blues Brothers (1920x1040) (SDL1)" "sudo blues-sdl1" "--screensize=1920x1040${datapath:+ ${datapath}/blues}"
    addPort2 "Prehistorik 2 (1920x1040) (SDL1)" "sudo pre2-sdl1" "--screensize=1920x1040${datapath:+ ${datapath}/pre2}"
}
