# Release v19.10.24-stable-5-g41b3cd8-dirty

## Upgrading

* You can upload any of these release zip files from Duet Web Control (DWC), via the "Files -> System" link in the menu.
* **NOTE**: If you upload the file via DWC and click 'Yes' to upgrade, the WiFi module will be flashed twice. There is currently no way around this, we need to do this to support extracting the file directly to the SD card for initial installations.
* The first time your machine reboots after installing the new release, it will switch back into Access Point mode and will _not_ connect to your WiFi network if it was configured to do so - this is because WiFi network details might be wiped when the WiFi module is updated, and bringing the board back up in AP mode allows recovery without having to connect over USB.
* You can connect to the access point using the password in the [documentation](https://millenniummachines.github.io/docs/milo/manual/chapters/90_install_rrf/#accessing-duet-web-control), and check if your WiFi network details need to be re-added using [M587](https://millenniummachines.github.io/docs/milo/manual/chapters/90_install_rrf/#configure-your-wifi-network).
* You may then reboot, and the machine will revert to the existing configuration in `network-default.g` or `network.g` (if you have one).
* Please see below for details of what is included in each release.

## Milo V1.5

### MILOJFK-SKR3-EZ-H743-5160

#### Notes

For miloJFK using the SKR3-EZ (h743) with esp32 WiFi, external BTT 5160 drivers and 3A/phase or higher NEMA23 motors. **WARNING**: Do not use with other 5160 drivers unless they have the same sense resistor value of 0.022Ω!

#### Contains

| Component                   | Source File(s)                           | Version            |
| --------------------------- | ---------------------------------------- | ------------------ |
| RepRapFirmware              | `firmware_skr3ez_h743.bin`             | 3.5.3      |
| DuetWiFiServer              | `WiFiModule_esp32.bin`            | 3.5.3      |
| DuetWebControl              | `DuetWebControl-SD-v3.5.3-with-mosUI.zip`               | 3.5.3    |
| Configuration               | `milo-v1.5/common` and `milo-v1.5/milojfk-skr3-ez-h743-5160` | v19.10.24-stable-5-g41b3cd8-dirty       |
| MillenniumOS                | `mos-release-v0.4.1.zip`                      | 0.4.1     |
| MillenniumOS_UI             | `DuetWebControl-SD-v3.5.3-with-mosUI.zip`               | 0.0.3  |
---

