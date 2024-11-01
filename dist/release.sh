#!/usr/bin/env bash

# Get directory of this script
SD=$(dirname "$0")

# Include common variables
source ${SD}/release-common.env

MACHINE_TYPE="${1}"
MACHINE_ID="${2}"

[[ -z "${MACHINE_ID}" ]] && {
	echo "Usage: $0 <machine-type> <machine-id>"
	exit 1
}

[[ -z "${MACHINE_TYPE}" ]] && {
	echo "Usage: $0 <machine-type> <machine-id>"
	exit 1
}

# Source build function
source ${SD}/functions.sh

make_cache_dir

# Add release notes header
cat <<-EOF >"${CACHE_DIR}/${RNOTES_PATH}"
	# Release ${COMMIT_ID}

	## Upgrading

	* You can upload any of these release zip files from Duet Web Control (DWC), via the "Files -> System" link in the menu.
	* **NOTE**: If you upload the file via DWC and click 'Yes' to upgrade, the WiFi module will be flashed twice. There is currently no way around this, we need to do this to support extracting the file directly to the SD card for initial installations.
	* The first time your machine reboots after installing the new release, it will switch back into Access Point mode and will _not_ connect to your WiFi network if it was configured to do so - this is because WiFi network details might be wiped when the WiFi module is updated, and bringing the board back up in AP mode allows recovery without having to connect over USB.
	* You can connect to the access point using the password in the [documentation](https://millenniummachines.github.io/docs/milo/manual/chapters/90_install_rrf/#accessing-duet-web-control), and check if your WiFi network details need to be re-added using [M587](https://millenniummachines.github.io/docs/milo/manual/chapters/90_install_rrf/#configure-your-wifi-network).
	* You may then reboot, and the machine will revert to the existing configuration in \`network-default.g\` or \`network.g\` (if you have one).
	* Please see below for details of what is included in each release.

	## Milo V1.5

EOF

# Build the release package for this machine
load_release "${MACHINE_TYPE}" "${MACHINE_ID}"
build_release

clean_cache_dir