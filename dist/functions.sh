#!/usr/bin/env bash

function get_header()
{
	cat <<-EOF >"${CACHE_DIR}/header.md"
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

}


function make_cache_dir() {
	[[ -z "${CACHE_DIR}" ]] && {
		CACHE_DIR=$(mktemp -d -t rrf-config-cache-XXXXX)
	}
}

function clean_cache_dir() {
	[[ -d "${CACHE_DIR}" ]] && {
		rm -rf "${CACHE_DIR}"
	}
}

function load_release() {
	MACHINE_TYPE="${1}"
	MACHINE_ID="${2}"

	[[ -z "${MACHINE_ID}" ]] && {
		echo "Usage: $0 <machine-type> <machine-id>"
		clean_cache_dir
		exit 1
	}

	[[ -z "${MACHINE_TYPE}" ]] && {
		echo "Usage: $0 <machine-type> <machine-id>"
		clean_cache_dir
		exit 1
	}

	MACHINE_ID_ENV="${SD}/../${MACHINE_TYPE}/${MACHINE_ID}/build.env"

	[[ -f "${MACHINE_ID_ENV}" ]] && {
		echo "Machine build env found: ${MACHINE_ID}";
		source ${MACHINE_ID_ENV};
	}

	# A machine type can have a single base type that it extends.
	# This is useful for machines that are very similar, but have
	# a few differences.
	BASE_DIR="${SD}/../${MACHINE_TYPE}/${BASE_TYPE}"

	[[ -d "${BASE_DIR}" ]] && {
		[[ -f "${BASE_ENV}" ]] && {
			echo "Base build env found: ${BASE_TYPE}";
		}
	}

	MACHINE_ENV="${SD}/release-${MACHINE_TYPE}.env"

	[[ ! -f "${MACHINE_ENV}" ]] && {
		echo "Machine type not found: ${MACHINE_TYPE}"
		clean_cache_dir
		exit 1
	}

	# Include machine-specific variables
	source ${MACHINE_ENV}

	BOARD_TYPE_ENV="${SD}/release-${RRF_BOARD_TYPE}.env"

	[[ -f "${BOARD_TYPE_ENV}" ]] && {
		echo "Board build env found: ${RRF_BOARD_TYPE}"
		source ${BOARD_TYPE_ENV}
	}

	MACHINE_DIR="${MACHINE_TYPE}/${MACHINE_ID}"
	COMMON_DIR="${MACHINE_TYPE}/common"

	# Abort if machine dir does not exist
	[[ ! -d "${WD}/${MACHINE_DIR}" ]] && {
		echo "Machine directory not found: ${MACHINE_DIR}"
		clean_cache_dir
		exit 1
	}

	MACHINE_NAME="${MACHINE_DIR//\//-}"

	ZIP_PATH="${DIST_DIR}/rrf-${MACHINE_NAME}-${COMMIT_ID}"
}

function build_release() {

	[[ -f "${ZIP_PATH}" ]] && rm "${ZIP_PATH}"

	echo "Building release ${COMMIT_ID} for ${MACHINE_NAME}..."

	# Create temporary directory
	TMP_DIR=$(mktemp -d -t rrf-config-XXXXX)

	# Make stub folder-structure
	mkdir -p "${TMP_DIR}/${SYS_DIR}" "${TMP_DIR}/${WWW_DIR}" "${TMP_DIR}/${FIRMWARE_DIR}" "${TMP_DIR}/${MACRO_DIR}" "${TMP_DIR}/${GCODE_DIR}"

	# Copy common config files to correct location
	${SYNC_CMD} "${WD}/${COMMON_DIR}/" "${TMP_DIR}/${SYS_DIR}/"

	# Copy base config files to correct location
	[[ ! -z "${BASE_DIR}" ]] && [[ -d "${BASE_DIR}" ]] && {
		${SYNC_CMD} "${WD}/${BASE_DIR}/" "${TMP_DIR}/${SYS_DIR}/"
	}

	# Copy machine-specific config files to correct location
	${SYNC_CMD} "${WD}/${MACHINE_DIR}/" "${TMP_DIR}/${SYS_DIR}/"

	# Remove example files that have been overridden by the
	# machine-specific config files.
	find "${TMP_DIR}/${SYS_DIR}" -name '*.g' -print | xargs -n 1 bash -c '[[ -f "${0}.example" ]] && rm ${0}.example && echo "Removed overridden ${0}.example"'

	# RRF STM32 is now released as a single Zip file
	# Copy firmware files to correct location
	[[ ! -f "${CACHE_DIR}/${RRF_FIRMWARE_ZIP_NAME}" ]] && {
		wget -nv -O "${CACHE_DIR}/${RRF_FIRMWARE_ZIP_NAME}" "${RRF_FIRMWARE_URL}" || { echo "Failed to download ${RRF_FIRMWARE_URL}"; exit 1; }
	}

	[[ ! -f "${CACHE_DIR}/${DWC_DST_NAME}" ]] && {
		wget -nv -O "${CACHE_DIR}/${DWC_DST_NAME}" "${DWC_URL}" || { echo "Failed to download ${DWC_URL}"; exit 1; }

	}

	[[ ! -f "${CACHE_DIR}/${MOS_DST_NAME}" ]] && {
		wget -nv -O "${CACHE_DIR}/${MOS_DST_NAME}" "${MOS_URL}" || { echo "Failed to download ${MOS_URL}"; exit 1; }

	}

	# Unzip RRF firmware to cache dir
	unzip -o -q "${CACHE_DIR}/${RRF_FIRMWARE_ZIP_NAME}" -d "${CACHE_DIR}/"

	# Copy RRF firmware to both filenames.
	cp "${CACHE_DIR}/${RRF_FIRMWARE_SRC_NAME}" "${TMP_DIR}/${RRF_FIRMWARE_DST_NAME}"
	cp "${CACHE_DIR}/${RRF_FIRMWARE_SRC_NAME}" "${TMP_DIR}/${FIRMWARE_DIR}"

	# Copy WiFi firmware to correct location
	cp "${CACHE_DIR}/${WIFI_FIRMWARE_SRC_NAME}" "${TMP_DIR}/${FIRMWARE_DIR}/${WIFI_FIRMWARE_DST_NAME}"

	# Replace WiFi firmware type variable.
	sed -si -e "s/%%WIFI_FIRMWARE_TYPE%%/${WIFI_FIRMWARE_DST_NAME}/g" ${TMP_DIR}/${SYS_DIR}/*.g

	# Extract DWC files to correct location
	unzip -o -q "${CACHE_DIR}/${DWC_DST_NAME}" -d "${TMP_DIR}/${WWW_DIR}"

	# Add release notes to release zip
	TEMP_NOTES_PATH="${CACHE_DIR}/notes.md"
	[[ ! -z "${ENABLE_RNOTES}" ]] && {
		cat <<-EOF > "${TEMP_NOTES_PATH}"
		### ${MACHINE_ID^^}

		#### Notes

		${BOARD_NOTES}

		#### Contains

		| Component                   | Source File(s)                           | Version            |
		| --------------------------- | ---------------------------------------- | ------------------ |
		| RepRapFirmware              | \`${RRF_FIRMWARE_SRC_NAME}\`             | ${TG_RELEASE}      |
		| DuetWiFiServer              | \`${WIFI_FIRMWARE_SRC_NAME}\`            | ${TG_RELEASE}      |
		| DuetWebControl              | \`${DWC_SRC_NAME}\`                      | ${DUET_RELEASE}    |
		| Configuration               | \`${COMMON_DIR}\` and \`${MACHINE_DIR}\` | ${COMMIT_ID}       |
		---

		EOF
	}

	# Append notes to the release notes path and create the new output file
	rm "${RNOTES_PATH}"
	[[ ! -z "${ENABLE_RNOTES}" ]] && {
		cat "${CACHE_DIR}/header.md" "${TEMP_NOTES_PATH}" > "${RNOTES_PATH}"
	}

	# Create release zip with default files
	cd "${TMP_DIR}"
	zip -qr "${ZIP_PATH}.zip" *
	cd "${WD}"

	####### MOS RELEASE #######

	# Remove existing release notes
	[[ ! -z "${ENABLE_RNOTES}" ]] && rm ${RNOTES_PATH}

	# Add MOS files to release zip
	unzip -o -q "${CACHE_DIR}/${MOS_DST_NAME}" -d "${TMP_DIR}/"

	# Add release notes to release zip
	TEMP_NOTES_PATH="${CACHE_DIR}/notes.md"
	[[ ! -z "${ENABLE_RNOTES}" ]] && {
		cat <<-EOF > "${TEMP_NOTES_PATH}"
		### ${MACHINE_ID^^}

		#### Notes

		${BOARD_NOTES}

		#### Contains

		| Component                   | Source File(s)                           | Version            |
		| --------------------------- | ---------------------------------------- | ------------------ |
		| RepRapFirmware              | \`${RRF_FIRMWARE_SRC_NAME}\`             | ${TG_RELEASE}      |
		| DuetWiFiServer              | \`${WIFI_FIRMWARE_SRC_NAME}\`            | ${TG_RELEASE}      |
		| DuetWebControl              | \`${DWC_MOS_UI_SRC_NAME}\`               | ${DUET_RELEASE}    |
		| Configuration               | \`${COMMON_DIR}\` and \`${MACHINE_DIR}\` | ${COMMIT_ID}       |
		| MillenniumOS                | \`${MOS_SRC_NAME}\`                      | ${MOS_RELEASE}     |
		---

		EOF
	}

	# Append notes to the release notes path and create the new output file
	rm "${RNOTES_PATH}"
	[[ ! -z "${ENABLE_RNOTES}" ]] && {
		cat "${CACHE_DIR}/header.md" "${TEMP_NOTES_PATH}" > "${RNOTES_PATH}"
	}

	cd "${TMP_DIR}"
	zip -qr "${ZIP_PATH}-with-mos.zip" *
	cd "${WD}"

	rm -rf "${TMP_DIR}"
}
