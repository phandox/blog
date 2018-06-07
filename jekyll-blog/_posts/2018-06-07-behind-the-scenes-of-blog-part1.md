---
layout: post
title:  "Behind the scenes of blog - part 1"
date:   2018-06-07 06:00:00 +0100
categories: behind_the_scenes
---

# Introduction - what is this series?

Welcome to the first of many post in series *Behind the scenes of blog*! As this is not just my first blog post here but a whole first blog ever, I've decided to share my learning process about various technologies I've used while creating this site. From most of them I've just heard the cool name of the product, stickers of logos on every single laptop (of course I also have stickers on mine) and read about the hype around Docker, Vagrant, Jenkins, Terraform, Kubernetes and how they are so *amazing* and that they make life so much easier...

And I've said to myself; *"Well this is all great, the talks are super interesting but how does it work and is it hard to start? Finishing quick start of Docker tutorial is one thing but using this on some real site must be different game right?"* So the best thing to learn, or better word, *to expose* myself to this all new trendy technologies is to get hands dirty and try build something. Blog is probably just the stepping stone, as it provides me the space to tell you about all the hiccups and small victories I've encountered when trying to build something simple and small. 

I hope that someone will find this a little bit useful, maybe it will encourage you in similar position as I am, that building something and *sharing* your thoughts is not this big scary monster as it looks like. Enough of intro, let's get down to business!

# Why blog? Ideas behind it

- platform for sharing thoughts and not dependent on other platforms
- encouragement and inspiration from Packet Pushers 
- to learn what it takes to maintain a public facing site

# Part 1 - Goals of the blog and technology behind it

- Simple - Markdown and directory structure is much better for me than full CMS of Wordpress. Jekyll has been chosen.
- Versioning - Everything is a text so it's easy to version in one repository, hosted on GitHub.
- Automation - don't use SSH to manually go inside VM and do the configuration changes. Ansible helps me to achieve this.
- Dev / Production - make it simple to make changes on local machine before going live, the configuration should be done the same way on production and Dev. Vagrant helps me with local environment and VMs are provisioned with Ansible.
- Containers - use small containers, easy to replace, decoupling the dependencies, the communication between containers is via network on host

# Part 2 - how did I work?

## Getting to know Jekyll
- Started with Jekyll - followed the quick start to run on my local machine. I didn't want to fill my computer with Ruby dependencies so I used Docker container with internal server and got a general look on how would the posts look like.

## From local OS to ... Vagrant?
- Build the local development environment.
- having it in docker container abstract me from underlying OS I would use in VM provider. I had to start from scratch
- I've chosen CentOS 7 
    - I have the feeling that is mature for production
    - I won't be spoiled by latest versions of all the goodies
    - SELinux out of box which I feel is very important for Docker host

## Stop using vagrant ssh - Ansible it's your turn
- create playbooks from the start, troubleshoot if something doesn't work via SSH
- vagrant provision with Ansible used to kick start the OS - install Docker, create user, copy SSH keys, set up firewall

## OS is ready, time for containers
- NGINX as web server for hosting my blog
- Blog is generated locally on my laptop with Docker
- Files are moved into named volumes on OS
- mounted to NGINX together with configuration
- everything is obviously done by Ansible
- some flaws
    - Blog is regenerated even though no changes were made
    - Sync is mirror - if I deleted post on my laptop, it is deleted from site too - this is maybe by design - I want to repository be the single source of truth

## We are up and running in local VM, time to show the world
- Where to host? 
    - requirements
        - relatively cheap
        - REST API support
        - extra goodies like firewalls, load balancers
        - hourly billing - easy to spin up VMs and destroy them after test
        - Terraform support is a plus
- the winner so far? Digital Ocean.
- cons?
    - not your typical "cloud". You don't have this vast number of tools which are in AWS or Azure
    - you have simple VPS however, able to be created by REST API

## Deploy the infamous "Infrastructure as Code"
- Digital Ocean has Terraform provider
- yay! Easy then, no need to write Python scripts to spin up my servers
- however!
    - there are few pain points I have with Terraform
        - sometimes the state refresh just fails
        - DNS domain is dependent on Droplet - you destroy the Droplet, domain is also destroyed - not just records as CNAME but the whole domain
            - not a big deal, Terraform will create the domain again right? However I haven't tried what happens with two Droplets being on the same domain. 
        - Support of DigitalOcean is not that vast in Terraform - same thing with vSphere
        - no out of box support of Ansible as provider
            - as configuration is dependent on Ansible, there is no provisioner in Terraform for Ansible.
            - used local-exec but I wasn't able to get dynamic Terraform inventory because the state file didn't exist during Terraform deployment :(
        - Terraform clearly focus on public cloud such as AWS, Azure.
    - I will eventually write Python scripts for deploying the infrastructure to Digital ocean - REST API and direct call of Ansible inside Python
    - will return to Terraform when I will be hosting in true public cloud

## Blog is running, finish line crossed right? Not so fast...
- This is just the beginning
- I am happy I made the first prototype but there is much work to be done
- First struggle was with HTTPS - I want to use Let's Encrypt with certbot, but looks like the architecture is not the best
    - web server with blog content is directly hooked to Internet - need to deploy reverse proxy to forward certbot required traffic to correct container
- Missing features
    - Logging - I need another container where my logs will be centralized - I will probably use ELK (huge overkill I know, but fun learning experience right?)
    - Reverse proxy (HAProxy or nginx? I shall see...)
    - HTTPS support - Let's Encrypt, obviously as said earlier in post.
    - Monitoring - need to do research - traditional or more container centric such as Prometheus?
    - Docker Cluster - new Droplet, higher availability with Docker Swarm, maybe even Kubernetes? (again, overkill but as intro learning experience I would prefer Kubernetes).
