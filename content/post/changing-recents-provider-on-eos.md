---
title: "Guide: Changing Recents Provider on /e/OS"
date: 2025-08-20T09:55:43+05:30
tags:
  - Android
  - Custom ROM
  - /e/OS
  - QuickSwitch
  - QuickStep
---

# Overview

Over the past month I have been daily driving my new phone, the Nothing CMF 1 flashed with /e/OS after I unlocked its bootloader. It's a very pleasant experience except for the default Bliss launcher (home app).

Reasons I do not prefer it:

- iOS like feel
- Icons can't be rearranged
- Pull down from top opens search instead of notification shade
- Consumes a lot of RAM

I started using Lawnchair as my default launcher but this did not change the recents provider (quickstep) from BlissLauncher to Lawnchair.

Two problems with this:

- Bliss has to keep running in the background to act as the recents provider.
- When the screen is horizontally oriented and gesture navigation is used to go to the home screen, Bliss keeps crashing.

> Note for Bliss devs: This behavior only occurs when using a different launcher as default.

I read a post on the forums about replacing Bliss completely but there was no step by step guide. Here, I document the steps I took to get Lawnchair as my default launcher *and* recents provider.

# Guide

This guide assumes you have a basic understanding of `adb` and `fastboot`. Ensure that USB debugging is enabled and your device is visible in the output of `adb devices`.

## Apatch

### Extracting `boot.img`

Assuming you have the image used to flash /e/OS on your phone, extract the `boot.img` from it. This can be done with the `7zip` command

``` sh
7z e IMG-e-3.0.4-a14-20250708507308-official-tetris.zip -o. boot.img
```

Here `IMG-e-3.0.4-a14-20250708507308-official-tetris.zip` is the image for my phone. Replace this with the appropriate image name.This extract the `boot.img` to the current directory.

Push this image to your device with

```
adb push boot.img /storage/emulated/0/Download/
```

> NOTE: You could also push the image over MTP (file transfer) but it may corrupt files and is hence discouraged.

### Installing APatch

These instructions are also available in the [APatch Docs](https://apatch.dev/install.html#install-requirements).

1.  Download the latest version of APatch Manager from [GitHub](https://github.com/bmax121/APatch/releases).
2.  Click on the patch button at the top right corner, and click `Select a boot image to patch`.
3.  Select the `boot.img` we pushed to the `Download` directory.
4.  Set a SuperKey at "SuperKey" card. The SuperKey should be **8-63 characters long and include numbers and letters, but no special characters.** It will be used later to unlock root privileges.
5.  Click on "Start" and wait for a minute. After the patch is successful, the patched `boot.img` path will be displayed. For example: `/storage/emulated/0/Download/apatch_version_version_randomletter.img`.

### Flashing

1.  Pull the patched `boot.img` with the command. Replace `apatch_version_version_randomletter.img` with the appropriate filename.

``` sh
adb pull /storage/emulated/0/Download/apatch_version_version_randomletter.img
```

2.  Reboot into fastboot mode.

``` sh
adb reboot bootloader
```

3.  Flash the patched `boot.img`.

``` sh
fastboot flash boot apatch_version_version_randomletter.img
```

4.  Reboot the device

``` sh
fastboot reboot
```

## QuickSwitch

### Installation

1.  Download the latest `zip` of QuickSwitch-fork to your phone from [GitHub](https://github.com/j7b3y/QuickSwitch/releases/latest).
2.  Open the APatch app.
3.  Authenticate with the SuperKey you had set earlier.
4.  Enable `APModule`.
5.  Under the `APModule` tab click on the install button in the bottom right corner.
6.  Select the `QuickSwitch-fork.zip` you downloaded.
7.  Reboot your device for the changes to take effect.

### Switching the Recents Provider

In this step I am assuming you are using a launcher that supports QuickStep, as in, it can act as a recents provider.

I have tested this on Lawnchair 14.3 beta. DO NOT USE Lawnchair 15.1 beta, it's QuickStep provider is a bit buggy.

Get a shell on the phone with

``` sh
adb shell
```

### Inside `adb shell`

1.  Change the recents provider. Replace `app.lawnchair` with your launcher's package name.

``` sh
su -c /data/adb/modules/quickswitch/quickswitch --ch=app.lawnchair
```

2.  (Optional) Remove Bliss launcher.

``` sh
for pkg in $(pm list packages | grep bliss | cut -d: -f 2); do pm uninstall --user 0 $pkg; done
```

3.  Reboot the device.

``` sh
reboot
```

## Profit!

That's all there is to it. Now you should see you preferred app as the recents provider. Goodbye!
