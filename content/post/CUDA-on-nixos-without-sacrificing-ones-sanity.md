---
title: "CUDA on NixOS Without Sacrificing One's Sanity"
date: 2024-08-10T08:18:30+05:30
tags:
  - Nix
  - NixOS
  - Machine Learning
  - Python
  - Workflow
  - NVIDIA
  - CUDA
  - Rant
draft: false
---

# What is CUDA?

CUDA, also known as Compute Unified Device Architecture
> is a proprietary parallel computing platform and application programming interface that allows software to use certain types of graphics processing units for accelerated general-purpose processing, an approach called general-purpose computing on GPUs.

according to Wikipedia.

According to me, it is a proprietary vendor lock-in for machine learning folks and the bane of my existence.
There's no other API out there that competes with CUDA as of writing. I know that ZLUDA exists but it is not
production ready and OpenAI's triton is mostly meh. Training ML models is incredibly fast with CUDA as compared to CPUs due to the parallel
processing. So if you're doing something serious, you have no other choice besides CUDA.

# NixOS vs your average distro

Your average Linux distro will store its binaries in the `/usr/bin` path, libraries (shared objects)
in `/usr/lib` and `/usr/lib64`, and header files in `/usr/include`.

NixOS, built around the Nix package manager, stores all of these in `/nix/store`.
This allows Nix to have more portable packages while completely sidestepping dependency
collision. Imagine you need `ffmpeg` version 6.0.0 for one project and version 6.1.1 for another.
We'll you can have both of them on your system simultaneously without any conficts. Each
of these packages is stored in a different directory in the nix store. For example version 6.1.1
would live in `/nix/store/35pinrj9082c83s2jiw2nrkz5171qhwx-ffmpeg-full-6.1.1-bin/bin/ffmpeg`
while the other version might live in `/nix/store/someOtherHashIMadeUp-ffmpeg-full-6.0.0-bin/bin/ffmpeg`.

# How NVIDIA ruins the day

CUDA, being proprietary junk, does not allow you to redistribute binaries that are linked with its blobs.
Thus, to enable CUDA and use it with something like PyTorch, we would have to [allow unfree packages as well as
enable CUDA support](https://discourse.nixos.org/t/pytorch-and-cuda-torch-not-compiled-with-cuda-enabled/11272/2).

```nix
import sources.nixpkgs {
  config = {
    allowUnfree = true;
    cudaSupport = true;
  };
}
```

Adding this to our `flake.nix` allows us the include the `linuxPackages.nvidia_x11`, `cudatoolkit` and `cudnn` packages in the package list.

This provides two ways to install PyTorch:
- Adding `python311Packages.pytorch` to build PyTorch from source with CUDA support. This will take time longer than the heat death of the universe and more likely freeze low end PCs.
Refer to [this hackernews post](https://news.ycombinator.com/item?id=32931486).
- Adding `python311Packages.pytorch-bin` which some people claim to have slightly faster builds since it just
fetches the PyTorch binary from the official website and patches it with the CUDA from `/nix/store`.
Refer to  [this reddit post](https://www.reddit.com/r/NixOS/comments/195pzdb/speeding_up_python311packagestorchwithcuda_build/).

Both of these approaches are extremely slow, you might have to leave your PC overnight to actually get it to work.

# Bending the rules

To avoid all of the pain, we can build a lightweight sandbox that follows the normal Filesystem Hierarchy Standard with directories like `/usr/bin`, `/usr/lib`, etc.
Nix allows you to create such isolated root filesystems using the `pkgs.buildFHSEnv` function. See more about it [here](https://ryantm.github.io/nixpkgs/builders/special/fhs-environments/).

It accepts a `name` for the environment, which I have set to a famous
Linus Torvalds quote. We then define a list of `targetPkgs` with the things we'd need for basic NVIDIA support.

Along with all the packages, you'll notice `micromamba` which will do most of the legwork when setting up PyTorch.
I've also included the `fish` shell because that's what I daily drive. You can remove that and the `runScript` attribute
to use the default bash.

```nix
    {
      description = "Python 3.11 development environment";
      outputs = { self, nixpkgs }:
      let
        system = "x86_64-linux";
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in {
        devShells.${system}.default = (pkgs.buildFHSUserEnv {
          name = "nvidia-fuck-you";
          targetPkgs = pkgs: (with pkgs; [
            linuxPackages.nvidia_x11
            libGLU libGL
            xorg.libXi xorg.libXmu freeglut
            xorg.libXext xorg.libX11 xorg.libXv xorg.libXrandr zlib 
            ncurses5 stdenv.cc binutils
            ffmpeg

            # I daily drive the fish shell
            # you can remove this, the default is bash
            fish

            # Micromamba does the real legwork
            micromamba
          ]);

          profile = ''
              export LD_LIBRARY_PATH="${pkgs.linuxPackages.nvidia_x11}/lib"
              export CUDA_PATH="${pkgs.cudatoolkit}"
              export EXTRA_LDFLAGS="-L/lib -L${pkgs.linuxPackages.nvidia_x11}/lib"
              export EXTRA_CCFLAGS="-I/usr/include"
          '';

          # again, you can remove this if you like bash
          runScript = "fish";
        }).env;
      };
    }
```

Note that this is _NOT_ the same as containers. The most obvious way to tell is because
you can access your NVIDIA GPU as is, without any passthrough shenanigans.

Enter this flake development environment using `nix develop`.
Now that we have the scaffolding, we can use `micromamba` to install CUDA for our ML tooling.

```sh
micromamba env create \
    -n my-environment \
    anaconda::cudatoolkit \
    anaconda::cudnn \
    "anaconda::pytorch=*=*cuda*"
```

Here I'm creating an environment called `my-environment` with `cudatoolkit`, `cudnn` and PyTorch. While installing PyTorch, make sure to
pick a version whose name contains "cuda" like I did here, otherwise, it defaults to the CPU version.

You can also define a `micromamba` environment with a config file. Read more about it [here](https://conda.io/projects/conda/en/latest/user-guide/manage-environments.html).

Once the env gets created, use `micromamba activate my-environment` to hop right in. Profit!

# Conclusion

Although this is not the Nix way of doing things with micromamba able to be used imeperatively, this is probably the quickest
and most hassle free experience to start ML stuff on NixOS. I've seen quite a lot of people on both the internet and in real life
giving up on NixOS because of how annoying closed source libraries like CUDA can be.

Share this article around if you found this hacky approach to have improved your developer experience. I'm banking on open source alternatives like triton to pick up steam
so that hopefully this article becomes irrelevant in the future.

Bye now.
