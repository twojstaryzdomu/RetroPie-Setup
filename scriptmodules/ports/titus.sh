#!/bin/ksh

rp_module_id="titus"
rp_module_desc="Blues Brothers, Blues Brothers Jukebox Adventure & Prehistorik 2 (SDL2)"
rp_module_repo="git https://github.com/twojstaryzdomu/blues master"
rp_module_section="opt"

function depends_titus() {
    getDepends libsdl2-dev
}

function sources_titus() {
    gitPullOrClone
}

function build_titus() {
    if isPlatform "rpi"; then
        applyPatch "$md_data/titus-datapath.patch"
    fi
    make
    md_ret_require="$md_build/pre2"
}

function install_titus() {
    md_ret_files=(
        'pre2'
        'blues'
        'bbja'
    )
}

function _update_hook_titus() {
    # to show as installed in retropie-setup 4.x
    hasPackage "titus" && mkdir -p "$md_inst"
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

function install_bin_titus {
    aptInstall "titus"
}

function remove_titus {
    aptRemove "titus"
    rm $romdir/ports/"Blues Brothers.sh" $romdir/ports/"Blues Brothers (1920x1040).sh" \
    rm $romdir/ports/"Blues Brothers Jukebox Adventure.sh" $romdir/ports/"Blues Brothers Jukebox Adventure (1920x1040).sh" \
        $romdir/ports/"Prehistorik 2.sh" $romdir/ports/"Prehistorik 2 (1920x1040).sh"
}

function configure_titus {
    dpkg -s titus-data >/dev/null 2>&1 \
        && [ -d /usr/share/titus ] \
            && typeset datapath="--datapath /usr/share/titus"
    addPort "$md_id" "blues" "Blues Brothers" "blues --fullscreen${datapath:+ ${datapath}/blues}"
    addPort2 "Blues Brothers Jukebox Adventure" "bbja" "--fullscreen${datapath:+ ${datapath}/bbja}"
    addPort2 "Blues Brothers" "blues" "--fullscreen${datapath:+ ${datapath}/blues}" ${datapath}"
    addPort2 "Prehistorik 2" "pre2" "--fullscreen${datapath:+ ${datapath}/pre2}" ${datapath}"
    addPort2 "Blues Brothers Jukebox Adventure (1920x1040)" "bbja" "--screensize=1920x1040 --scale=1${datapath:+ ${datapath}/bbja}"
    addPort2 "Blues Brothers (1920x1040)" "blues" "--screensize=1920x1040 --scale=1${datapath:+ ${datapath}/blues}"
    addPort2 "Prehistorik 2 (1920x1040)" "pre2" "--screensize=1920x1040 --scale=1${datapath:+ ${datapath}/pre2}"
}
