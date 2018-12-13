# Docker image with esp-open-rtos and esp-open-sdk build tools

## Usage

I use this image with my devices repository:
https://github.com/slawekkolodziej/esp-homekit-devices

Using docker image for building device images has some advantages, especially on MacOS:
- Works on latest macos without any issue
- Saves you from preparing toolchain on your own
- You don't have to create case-sensitive volume

In my project I use a single Makefile that abstracts building images with docker, flashing process and even connecting to the serial monitor.

With my makefile I can use the following commands:

- `make build dev=myDevice` - build devices/myDevice
- `make clean dev=myDevice` - clean devices/myDevice
- `make flash dev=myDevice` - flash device using image stored in devices/myDevice
- `make flash-clean` - flash clean image to the device connected to ESPPORT
- `make serial` - connect to ESPPORT using screen

Below you can find my Makefile

```
ESPPORT=/dev/tty.wchusbserial1410
BAUD=115200

build:
  @docker run --rm -it \
    -e "ESPBAUD=$(BAUD)" \
    -v $(PWD):/home/esp/workspace:delegated \
    slawekkolodziej/esp-open-sdk \
    make -C devices/$(dev) all

clean:
  @docker run --rm -it \
    -e "ESPBAUD=$(BAUD)" \
    -v $(PWD):/home/esp/workspace:delegated \
    slawekkolodziej/esp-open-sdk \
    make -C devices/$(dev) clean

flash-clean:
  @esptool.py \
    -p $(ESPPORT) \
    --baud $(BAUD) write_flash \
    -fs 1MB \
    -fm dout \
    -ff 40m \
    0x0 ./sdk/esp-open-rtos/bootloader/firmware_prebuilt/rboot.bin \
    0x1000 ./sdk/esp-open-rtos/bootloader/firmware_prebuilt/blank_config.bin \
    0x2000 ./sdk/otaboot.bin

flash:
  @esptool.py \
    -p $(ESPPORT) \
    --baud $(BAUD) write_flash \
    -fs 1MB \
    -fm dout \
    -ff 40m \
    0x0 ./sdk/esp-open-rtos/bootloader/firmware_prebuilt/rboot.bin \
    0x1000 ./sdk/esp-open-rtos/bootloader/firmware_prebuilt/blank_config.bin \
    0x2000 ./devices/$(dev)/firmware/main.bin

serial:
  @screen -L $(ESPPORT) $(BAUD) –L
```

