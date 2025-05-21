---
title: "Painlessly setting up ML tooling on NixOS"
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

> Note: Use the following method only if you wish to have the latest version of CUDA that is
not yet available in the nix-community cache, otherwise follow [this](https://nix-community.org/cache).

> *TL;DR:* Save [this flake](#the-flake), run `nix develop` and [setup PyTorch as described](#setting-up-pytorch)

[CUDA](https://en.wikipedia.org/wiki/CUDA) is a proprietary vendor lock-in for machine learning folks.
Training ML models is incredibly fast with CUDA as compared to CPUs due to the parallel
processing. So if you're doing something serious, you have no other choice besides CUDA as of writing.
Although, OpenAI's Triton and ZLUDA are worth keeping an eye on.

Unlike your average distro, Nix will prevents conflicts between installed packages by storing its [derivations](@ "packages and libraries") in the [Nix store](https://zero-to-nix.com/concepts/nix-store) instead of
locations like `/usr/bin`, `/usr/lib` and `/usr/lib64`.

# How not to add CUDA

CUDA, being proprietary junk, does not allow you to redistribute
binaries that are linked with its blobs. Thus, for CUDA enabled PyTorch, we would have to [allow unfree
packages and enable CUDA support](https://discourse.nixos.org/t/pytorch-and-cuda-torch-not-compiled-with-cuda-enabled/11272/2).

```nix
import sources.nixpkgs {
  config = {
    allowUnfree = true;
    cudaSupport = true;
  };
}
```

Adding this to our `flake.nix` allows us the include these packages:
- `linuxPackages.nvidia_x11`
- `cudatoolkit`
- `cudnn`

Now we can install PyTorch by either adding
- `python311Packages.pytorch` to build PyTorch from source with CUDA support. This will take time longer than the heat death of the universe and more likely freeze low end PCs.
Refer to [this hackernews post](https://news.ycombinator.com/item?id=32931486).
- `python311Packages.pytorch-bin` which some people claim to have slightly faster builds at it
fetches the PyTorch binary from pytorch.org and patches it with the CUDA from `/nix/store`.
Refer to  [this reddit post](https://www.reddit.com/r/NixOS/comments/195pzdb/speeding_up_python311packagestorchwithcuda_build/).

Both of these approaches are extremely slow, you might have to leave your PC overnight to actually get it to work.

# Bending the rules

To avoid all of the pain, we can build a lightweight sandbox that follows the normal Filesystem Hierarchy Standard with directories like `/usr/bin`, `/usr/lib`, etc.
Nix allows you to create such isolated root filesystems using the [`pkgs.buildFHSEnv`](https://ryantm.github.io/nixpkgs/builders/special/fhs-environments/) function.

It accepts a `name` for the environment and a list of `targetPkgs` with the things we'd need for basic NVIDIA support.
Note the inclusion of `micromamba` which will do most of the legwork when setting up PyTorch.
I've also included the `fish` shell because that's what I daily drive. You can remove that and the `runScript` attribute
to use the default bash.

## The flake

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
        devShells.${system}.default = (pkgs.buildFHSEnv {
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

> *Note:* This is _NOT_ the same as containers. The most obvious way to tell is because
you can access your NVIDIA GPU as is, without any passthrough shenanigans.

Enter this flake development environment using `nix develop`.

# Setting up PyTorch

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

Although this is not the Nix way of doing things, with micromamba being imeperative, this is probably the quickest
and most hassle free experience to start ML stuff on NixOS. I've seen quite a lot of friends giving up on NixOS because of how annoying closed source libraries like CUDA can be.

Share this article around if you found this hacky approach to have improved your developer experience. I'm banking on open source alternatives to pick up steam
so that hopefully this article becomes irrelevant in the future.

Bye now.
