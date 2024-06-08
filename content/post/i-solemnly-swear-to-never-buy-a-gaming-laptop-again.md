---
title: "I Solemnly Swear to Never Buy a Gaming Laptop Again"
date: 2024-06-07T17:01:01+05:30
draft: false
tags:
- Workflow
- Rant
- Linux
- Laptops
- Kernel Modules
---

Around half a decade ago, I bought an Asus gaming laptop, one I'm currently using to write this article.
Although it came preinstalled with Windows, I never let it even boot and instead opted for linux. Bill Gates can cry a river.

Despite switching distros multiple times, one sporadical issue my setup suffered from
was the wireless card dying after a few minutes of booting the box. The only solution to this was to reboot my computer, classic!

![A dramatic re-enactment of the WiFi card dying](/cry.gif)

The wireless card in question was a Realtek card (of course it has to be those clowns) handled by the `rtw88_8822ce` kernel module
under the `rtw88_pci` namespace. Scouring through online forums, I discovered that these clowns were so clever, they
engineered their WiFi cards to enter low power or sleep mode when it thinks the card is not in use. Some forums stated that this behavior
could be disabled by changing the kernel parameters. To do this, I needed to look for available kernel parameters using the
`modinfo` command. Finding the name of the kernel module in question can be a hit or miss. I found reading the description of the modules
from the `lsmod` command to be reliable.

After finding out the module, `rtw88_pci` in my case, you can run `modinfo` to learn the details of the kernel parameters.

```sh
modinfo rtw88_pci
```

```
filename:       /run/booted-system/kernel-modules/lib/modules/6.6.32/kernel/drivers/net/wireless/realtek/rtw88/rtw88_pci.ko.xz
license:        Dual BSD/GPL
description:    Realtek PCI 802.11ac wireless driver
author:         Realtek Corporation
depends:        rtw88_core,mac80211
retpoline:      Y
intree:         Y
name:           rtw88_pci
vermagic:       6.6.32 SMP preempt mod_unload 
parm:           disable_msi:Set Y to disable MSI interrupt support (bool)
parm:           disable_aspm:Set Y to disable PCI ASPM support (bool)
```

Here, the `disable_msi` parameter can be used to disable [MSI](https://learn.microsoft.com/en-us/windows-hardware/drivers/kernel/introduction-to-message-signaled-interrupts), which is a PCI message signaled interrupt system alternative to line
based interrupts. The `disable_aspm` similarly disables ASPM (Active State Power Management) which _"saves power"_ when my system is _"idle"_.
Gee thanks, I hate it.

The network card deaths became more sporadic after setting `disable_aspm` to `Y` but they were not completely eliminated. Another bonus is my
computer straight up lagging when these devices die. Why? Because this:

> While ASPM brings a reduction in power consumption, it can also result in increased latency as the serial bus needs to be 'woken up' from low-power mode, possibly reconfigured and the host-to-device link re-established. This is known as ASPM exit latency and takes up valuable time which can be annoying to the end user if it is too obvious when it occurs.
>
> \- Wikipedia

How could I confirm this? Take a look at the output of the `dmesg` command:

```
[  392.656276] rtw_8822ce 0000:04:00.0: failed to poll offset=0x5 mask=0x2 value=0x0
[  392.656312] rtw_8822ce 0000:04:00.0: mac power on failed
[  392.656317] rtw_8822ce 0000:04:00.0: failed to power on mac
[  394.755267] rtw_8822ce 0000:04:00.0: failed to poll offset=0x5 mask=0x2 value=0x0
[  394.755330] rtw_8822ce 0000:04:00.0: mac power on failed
[  394.755348] rtw_8822ce 0000:04:00.0: failed to power on mac
```

The driver is `rtw88_8822ce` and the logs say that there was a failure in
powering the card on. In the end, I just bought an external USB 2.0 network card
and blacklisted the kernel modules for the builtin card in my NixOS config.

```nix
boot.blacklistedKernelModules = [ "rtw88_8822ce" ];
```

Another related problem was the WiFi strength itself. With the honking GTX 1650
of a GPU shoehorned into a small form factor, the electromagnetic induction
caused by the GPU also deteriorated the signal strength. I mean, what was I
thinking back when I bought this? I knew I was going to use Linux because I
distinctly remember my previous Arch + i3wm. The reason behind a gaming laptop
was not to play games, Linux did not have great tooling for gaming then. No, I
needed the beefy GPU to crack password hashes for capture the flag challenges
😉. In retrospect, social engineering and educated guesses turned out to be a
way less resource intensive means to, ahem, crack password hashes.

Speaking of the GPU, I severly underestimated how heavy it would make the box. If not for the shape of the laptop, I could easily use
it for weights during workouts.

Lastly, the battery life for gaming laptops suck in general. This is why I'm sticking to lightweight environments for now: window managers like i3 and sway or desktop environments like
XFCE, Cosmic Epoch and KDE. KDE by far is the least resource intensive for the features it provides out of the box. I use it with the vanilla settings apart from the left sidebar.
It is quite the bang for the buck, considering most of you will donate to the devs anyways.

![A screenshot of my current KDE setup](/kde-setup.png)

In conclusion, I don't recommend gaming laptops to developers and leet haxxors. You don't need that GPU horsepower.
The clowns at Realtek produce such hot garbage that I wish their stocks plummet.
Instead, try out the newer ARM devices. They are power efficient and performant. If I have to migrate to a different setup, I'd
probably choose laptops from Framework or System76. Both of these companies make their hardware repairable,
respect user freedom and support Linux out of the box. I'm looking for a setup that would last another decade, [ship of Theseus](https://en.wikipedia.org/wiki/Ship_of_Theseus) style.
**This is not a sponsored article**, all stated opinions are mine and mine alone. I did not get paid to endorse Framework
or System76. I just like what they are doing and I recommend saving up a bit to buy one of their builds.
