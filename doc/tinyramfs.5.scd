tinyramfs(5) "tinyramfs" "2024-12-03"

# NAME

tinyramfs - configuration file

# DESCRIPTION

A tinyramfs configuration file is written in POSIX sh. Configuration is done
via variable asignment (eg. *option=value*). Special characters and whitespace
must be quoted or escaped, more info: *sh*(1). By default tinyramfs looks to
*/etc/tinyramfs/config* for a configuration file.

# OPTIONS

Option marked with *(bool)* can hold a value of true or false. False if the
variable is unset or empty, true otherwise.

Some options only apply to certain hooks and have been categorized accordingly.

Options which expect a device as a value can also refer to the device via
*UUID*, *LABEL*, and *PARTUUID* (eg. LABEL=<label>). This requires a blkid
utility which supports that identifier.

hooks

	A comma separated list of hooks to include in the initramfs. Hooks can
	be found in /lib/tinyramfs/hook.d/.

## MOUNTING

root

	The device your root filesystem is located on.

	(available formats: /dev/sdX, LABEL=label, PARTUUID=partuuid, UUID=uuid)
	
	Note: using /dev/sdX is not recommeded since device path mappings may change
	after changing hardware or even updating the kernel.

root_type

	The filesystem you're using for your root device (eg. ext4).

root_opts

	Arguments passed to mount command when mounting root device.

rorw

	Define root partition ro/rw mounting, default to use ro to make use of init system.
	
	(available options: ro, rw)

## MODULES

modules_copy

	Instructs tinyramfs whether or not to include kernel modules in the initramfs.
	
	off: prevent modules to be copied
	hostonly: (default) copy only modules used in host system
	config: copy only modules defined (modules_list) in config files
	all: copy all modules (likely to be HUGE!!!)
	
	(available options: off, hostonly, config, all)

modules_list

	Define modules to be copied when modules_copy=config, will be passed to "find" command

## COMPRESSION

compress

	The utility to use for compressing the initramfs. The option accepts
	arbitrary commands (eg. 'gzip -9'). Use 'cat' for an uncompressed
	initramfs.

## LOADKEYMAP / LOADKEYS

keymap_path

	Path to your keymap.

## LUKS

luks_discard

	(bool) Allow the use of discard (TRIM) requests for your luks device.

	*WARNING*: This option may have a negative security impact. For more info
	read *cryptsetup*(8).

luks_header

	Path to your LUKS header.

luks_root

	The device your LUKS volume is located on.

luks_name

	The name to map your LUKS device to.

luks_key

	Path to your LUKS keyfile.

## RESUME

resume

	The location of your swap partition.

## LIVE

live_disk_type

	Define live medium partition locator type

	(available format: label, partuuid, uuid)

live_disk

	define live medium partition located in /dev/disk/by-live_disk_type

live_disk_fs

	define live medium partition fs type, iso9660 by default

live_sfs_opts

	define squashfs mount options, "defaults,ro" by default

live_ram

	define if squashfs should be copied into ram

live_ram_opts

	define ramdisk mounting options

## PLYMOUTH

plymouth_nocopymodule

	define to prevent copying modules during plymouth hook

plymouth_earlyquit

	define to quit plymouth when late hook executed (instead of using init system)

# FILES

/lib/tinyramfs/hook.d/
	tinyramfs hooks

# SEE ALSO

*tinyramfs*(8)

# AUTHORS

tinyramfs by illiliti *https://github.com/illiliti*++
man page by fluorescent_haze *https://github.com/fluorescent-haze*
