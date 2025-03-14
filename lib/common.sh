# vim: set ft=sh:
# shellcheck shell=sh
#
# https://shellcheck.net/wiki/SC2154
# shellcheck disable=2154

print()
{
    printf "%s %s\n" "${2:-">>"}" "$1"
}

print_loglevel()
{
    [ "$1" -gt "$loglevel" ] && return
    prefix=""
    case "$1" in
        0) prefix="ERROR:" ;;
        1) prefix="WARN:"  ;;
        2) prefix="INFO:"  ;;
    esac
    print "$2" "$prefix"
    unset prefix
}

print_warn()
{
    print_loglevel 1 "$1"
}

print_verbose()
{
    print_loglevel 2 "$1"
}

panic()
{
    # if inside initramfs
    [ -z "$_tinyramfs" ] || eval_hooks init.fail

    print "${1:-unexpected error occurred}" '!>' >&2

    if [ "$$" = 1 ]; then
        busybox --install
        sh
    else
        exit 1
    fi
}

# TODO ensure correctness
copy_file()
(
    file=$1; dest=$2
    [ "$dest" ] || dest=$file

    [ -e "${tmpdir}/${dest}" ] && return

    while [ -h "$file" ]; do
        mkdir -p "${tmpdir}/${file%/*}"
        cp -P "$file" "${tmpdir}/${file}"
        cd -P "${file%/*}" || exit

        symlink=$(ls -ld "$file")
        symlink=${symlink##* -> }

        case $symlink in
            /*) file=$symlink ;;
            .*) file="${PWD}/${symlink}" ;;
            *)  file="${PWD}/${symlink##*/}" ;;
        esac
    done

    [ -h "${tmpdir}/${dest}" ] && dest=$file

    mkdir -p "${tmpdir}/${dest%/*}"
    cp "$file" "${tmpdir}/${dest}"

    [ "$3" ] && chmod "$3" "${tmpdir}/${dest}"

    # https://shellcheck.net/wiki/SC2015
    # shellcheck disable=2015
    [ "$4" ] && strip "${tmpdir}/${dest}" > /dev/null 2>&1 || :
)

copy_exec()
{
    _bin=$(command -v "$1")

    case $_bin in /*) ;;
        '')
            panic "unable to find command: $1"
        ;;
        *)
            # https://shellcheck.net/wiki/SC2086
            # shellcheck disable=2086
            { IFS=:; set -- $PATH; unset IFS; }

            for _dir; do
                __bin="${_dir}/${_bin}"

                [ -x "$__bin" ] && break
            done

            # https://shellcheck.net/wiki/SC2015
            # shellcheck disable=2015
            [ -x "$__bin" ] && _bin=$__bin || panic "unable to find command: $_bin"
        ;;
    esac

    copy_file "$_bin" "/bin/${_bin##*/}" 0755 1

    # TODO copy libs to the directory of interpreter.
    ldd "$_bin" 2> /dev/null |

    while read -r _lib || [ "$_lib" ]; do
        _lib=${_lib#* => }
        _lib=${_lib% *}

        [ -e "$_lib" ] && copy_file "$_lib" "" 0755 1
    done
}

copy_kmod()
{
    # prevent modules to be copied even in hooks
    [ "$modules_copy"  = "off" ] && return

    if modinfo -k "$kernel" "$1" >/dev/null 2>&1; then
        modname=$(modinfo -k "$kernel" -F name "$1" | cut -d ' ' -f1 | head -n1)
        [ "$modname" = "name:" ] && return 0
        modpath=$(modinfo -k "$kernel" -F filename "$1" | cut -d ' ' -f1 | head -n1)
        [ "$modpath" = "name:" ] && return 0
        [ "$modpath" = "(builtin)" ] && return 0
    else
        print_verbose "missing module: $1"
        return
    fi
    [ -f "${tmpdir}/$modpath" ] && return
    copy_file "$modpath"
    modinfo -F firmware -k "$kernel" "$modname" | while read -r line; do
        firmwarefile=""
        for comp_format in "" gz xz zst; do
            if [ -f "/lib/firmware/$line.$comp_format" ]; then
                firmwarefile="$line.$comp_format"
                break
            fi
        done
        if [ ! -f "/lib/firmware/$firmwarefile" ]; then
            print_warn "missing firmware for $modname: $line"
        else
            copy_file "/lib/firmware/$firmwarefile"
        fi
    done

    for i in $(modinfo -F depends -k "$kernel" "$modname" | tr ',' ' '); do
        copy_kmod "$i"
    done

    unset modname modpath firmwarefile
}

# TODO allow full path to hook
copy_hook()
{
    for _dir in ${local+./hook} /etc/tinyramfs/hook.d /lib/tinyramfs/hook.d; do
        _hook="${_dir}/${1}/${1}"
        [ -f "$_hook" ] && break
    done

    [ -f "$_hook" ] || panic "unable to find hook: $1"

    for _ext in init init.late init.fail; do
        [ -f "${_hook}.${_ext}" ] || continue

        print "copying hook: ${1}.${_ext}"

        copy_file "${_hook}.${_ext}" "/lib/tinyramfs/hook.d/${1}/${1}.${_ext}" 0644
    done

    print "evaluating hook: $1"

    # https://shellcheck.net/wiki/SC1090
    # shellcheck disable=1090
    . "$_hook"
}

resolve_device()
{
    device=$1; _count=${2:-30}

    case ${device%%=*} in
        UUID)     device="/dev/disk/by-uuid/${device#*=}"     ;;
        LABEL)    device="/dev/disk/by-label/${device#*=}"    ;;
        PARTUUID) device="/dev/disk/by-partuuid/${device#*=}" ;;
        /dev/*)          ;;
        *)        return ;;
    esac

    # Race condition may occur if device manager is not yet initialized device.
    # To fix this, we simply waiting until device is available. If device
    # didn't appear in specified time, we panic.
    while :; do
        if [ -b "$device" ]; then
            return
        elif [ "$((_count -= 1))" = 0 ]; then
            break
        else
            sleep 1
        fi
    done

    panic "failed to lookup partition: $device"
}
