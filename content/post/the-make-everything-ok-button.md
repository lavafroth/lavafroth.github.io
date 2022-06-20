---
title: "The Make Everything Ok Button"
date: 2022-10-09T09:20:30+05:30
tags:
- Containers
- CUDA
- Deepfacelab
- Docker
- Tensorflow
draft: false
---

# Disclaimer

Before I begin, I must warn you that DeepFaceLab is just a tool, neither good nor evil.
Neither Deepfacelab nor the docker image is meant for generating illicit or obscene imagery.
You shall be solely liable for anything you do with these tools.


# You know the drill

Everytime I have to install DeepFaceLab on any of my systems, it comes with a lot of hassle
mostly due to incompatibilities between the GPU libraries and Python versions. Consequently,
I have to go through the process of trial and error, witnessing my setups cough up blood in
the process. This becomes further unbearable due to the loads of artifacts left on the host
if I even get it working.

Here's a meme I stole from the official DeepFaceLab's GitHub page.

![DeepFaceLab is working meme](https://raw.githubusercontent.com/iperov/DeepFaceLab/master/doc/meme1.jpg)

The `DeepFaceLab_Linux` repository mentioned on the project's page uses conda to create a
separate python environment with `cudatoolkit` and `cudnn`. I find setting up a project with
conda troublesome. You cannot move the conda installation around, even if you get a project
working, you aren't guaranteed reproducibility.

I prefer such tools containerized, residing elsewhere like `/var/lib/docker`.
It should be relatively easy to package the application with the appropriate
dependencies into a container without sacrificing GPU horsepower thanks to the recent upsurge
in the popularity of `nvidia-container-toolkit`.

# Enter deepfacelab-docker

[This repository](https://github.com/xychelsea/deepfacelab-docker) provides an NVIDIA GPU enabled
container with DeepFaceLab pre-installed on an Anaconda and TensorFlow container.

> _Wait what? Anaconda inside a Docker container? Just why?_

If we take into account the overhead costs of installing Anaconda (or Miniconda for that matter)
on the base system for managing python versions, there is no point in using Docker except to
glue everything together into this abomination.

# Enter deepfacelab-docker (again?)

Sick and tired of these roundabout solutions, I decided to come up with my own.
I created a `Dockerfile` and a `docker-compose.yml`
[here](https://github.com/lavafroth/deepfacelab-docker) loosely based on the architecture of the
`DeepFaceLab_Linux` build. This meant I had to use the `nvidia/cuda` base image with CUDA 10.1
and CUDNN 7. The build sets up `python3.7` and installs the corresponding version of `pip`. Next,
it installs _sane_ requirements, ones that the application can work with, are compatible with the
current python version and doesn't leak memory. [These two invaluable comments](https://github.com/nagadit/DeepFaceLab_Linux/issues/20#issuecomment-738114713)
significantly eased the process of figuring the correct requirements. Lastly, it set up the
environment variables and the workspace.

# How do I use it?

It's simple, make sure you have `nvidia-container-toolkit`, `docker` and `docker-compose` installed.
Clone my repository and run the docker compose commands:

```bash
git clone https://github.com/lavafroth/deepfacelab-docker.git
docker-compose run app
```

Place the `data_src` and `data_dst` videos in the `workspace` directory and inside the container,
run the scripts in the `scripts` directory. 

Although this is far from the definitive version of the _"Make everything OK"_ button, I hope that
this image somewhat reduces the overhead of setting up DeepFaceLab, making it quicker to get the tool up and running.
