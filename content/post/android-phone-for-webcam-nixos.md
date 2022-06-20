---
title: "Using an Android Phone as a webcam in NixOS"
date: 2024-03-10T08:47:08+05:30
draft: false
tags:
- Workflow
- Meta
- NixOS
- Android
---

I recently had to attend an online meeting for a software development event.
While my PC did have a decent microphone, the built-in camera has been damaged to the extent that the best it can capture is this:

![A blurry image taken from my scuffed camera](/pc-camera.avif)

No, it's not a close-up of the moon, it's the refraction caused by the scuffs to the lens plus other sciency stuff I'm not qualified enough to explain to you.

I was aware that one can use ADB to use an Android phone's camera as a makeshift webcam. Since I would need this ability for any future meetings as well, it was worth having the functionality packaged into a one click tool.

Enter NixOS. I have praised NixOS before and I'll do it again because of the sheer ease with which it allows me to create desktop entries for small scripts.
This is going to be relevant later but I'm going to assume that you're running NixOS with home-manager enabled if you're following along. First we have to [enable developer mode and USB debugging on our phone](https://developer.android.com/studio/debug/dev-options#enable).

To interact with our phone, we will need `adb` and `scrcpy` as dependencies.
If you have enabled flakes run the following:

```sh
nix shell nixpkgs#scrcpy nixpkgs#android-tools
```

If you don't have flakes enabled, run the following:

```sh
nix-shell -p scrcpy android-tools
```

Next, we connect our phone to our PC with a cable (or through ADB TCP/IP) and list all the cameras by running the following: 

```sh
scrcpy --list-cameras
```

You must allow any prompt on your phone requesting access to it from the
computer, after which, you should see an output like the following:

```
[server] INFO: List of cameras:
    --camera-id=0    (back, 4608x3456, fps=[10, 15, 24, 30])
    --camera-id=1    (front, 2304x1728, fps=[15, 24, 30])
    --camera-id=2    (back, 3264x2448, fps=[15, 24, 30])
    --camera-id=3    (back, 1600x1200, fps=[15, 24, 30])
    --camera-id=4    (back, 1600x1200, fps=[15, 24, 30])
    --camera-id=5    (back, 4608x3456, fps=[10, 15, 24, 30])
    --camera-id=6    (back, 4608x3456, fps=[10, 15, 24, 30])
    --camera-id=7    (back, 4608x3456, fps=[10, 15, 24, 30])
```

Note down the number associated with the camera you want to use. Alternatively, you can also note whether the camera you wish to use is the front or the back camera.

Add the following to your `configuration.nix`:

```nix
boot = {
  kernelModules = [ "v4l2loopback" ];
  extraModulePackages = [ pkgs.linuxPackages.v4l2loopback ];
  extraModprobeConfig = ''
    options v4l2loopback exclusive_caps=1 card_label="Virtual Webcam"
  '';
};
```

This enables the `v4l2loopback` kernel module to create a dummy video interface which allows us to route any video to this virtual camera.
In the extra options for this module, we have to add `exclusive_caps=1` to make sure that the virtual camera exclusively announces itself as an output device.
This is important for compatibility with services like Zoom and Google Meet.

In the home-manager config for your user add the following:

```nix
home.xdg.desktopEntries.andcam = {
  name = "Android Virtual Camera";
  exec = "${pkgs.writeScript "andcam" ''
    ${pkgs.android-tools}/bin/adb start-server
    ${pkgs.scrcpy}/bin/scrcpy --camera-facing=back --video-source=camera --no-audio --v4l2-sink=/dev/video0 -m1024
  ''}";
};
```

This creates a desktop entry with the name _"Android Virtual Camera"_ and runs
the script in the `exec` field.

Here's a breakdown of the script:

- The first line starts an ADB server required for `scrcpy` to pick up our device.
- The second line runs `scrcpy` to pass the phone's camera to the dummy virtual camera spawned by the `v4l2loopback` kernel module.

We can use a named camera with the `--camera-facing` flag as I did here for
the back camera using `--camera-facing=back`. If you noted a camera ID eariler,
you can replace the `--camera-facing=back` with `--camera-id=` followed by the
identifying number.

For example, if you were to use the camera with the ID 0, you would add the following instead:

```nix
home.xdg.desktopEntries.andcam = {
  name = "Android Virtual Camera";
  exec = "${pkgs.writeScript "andcam" ''
    ${pkgs.android-tools}/bin/adb start-server
    ${pkgs.scrcpy}/bin/scrcpy --camera-id=0 --video-source=camera --no-audio --v4l2-sink=/dev/video0 -m1024
  ''}";
};
```

Now rebuild your system and reboot.

That's it! Connect your phone to your PC and run on the _"Android Virtual Camera"_ menu entry.

I was impressed that this has been possible on Linux since 2018 while
[Microsoft is introducing this feature now to Windows 11](https://blogs.windows.com/windows-insider/2024/02/29/ability-to-use-a-mobile-devices-camera-as-a-webcam-on-your-pc-begins-rolling-out-to-windows-insiders/).

Remember kids, what Windows can be tomorrow, Linux is today. That's all for now,
see you around!
