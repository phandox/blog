---
layout: post
title:  "Behind the scenes of blog - part 1"
date:   2018-06-07 06:00:00 +0100
categories: behind_the_scenes
---

Welcome to the first of many post in series *Behind the scenes of blog*! As this is not just my first blog post here but a whole first blog ever, I've decided to share my learning process about various technologies I've used while creating this site. From most of them I've just heard the cool name of the product, stickers of logos on every single laptop (of course I also have stickers on mine) and read about the hype around Docker, Vagrant, Jenkins, Terraform, Kubernetes and how they are so *amazing* and that they make life so much easier...

And I've said to myself; *"Well this is all great, the talks are super interesting but how does it work and is it hard to start? Finishing quick start of Docker tutorial is one thing but using this on some real site must be different game right?"* So the best thing to learn, or better word, *to expose* myself to this all new trendy technologies is to get hands dirty and try build something. Blog is probably just the stepping stone, as it provides me the space to tell you about all the hiccups and small victories I've encountered when trying to build something simple and small. 

I hope that someone will find this a little bit useful, maybe it will encourage you in similar position as I am, that building something and *sharing* your thoughts is not this big scary monster as it looks like. Enough of intro, let's get down to business!

## Part 1 - Goals of the blog and technology behind it

Before starting a new project I like to make a short list of goals to be clear what am I trying to achieve and why am I doing a particular project. You already know why, so here are the main pillars of blog:

- Simple
- Versioning-friendly
- Automation ready
- Dev / Test / Production environments
- Containers

### Simple 
The content delivery should be very simple. My preferred workflow is to work with text files so by having fully featured CMS such as Wordpress would not be my goal. I've peaked into the world of static-site generators and I found [Jekyll](https://jekyllrb.com) to really fit my needs. Being able to create website just from Markdown text? You sold me right there. By design this also checks my other goal and that is...

### Versioning-friendly

Having everything in a text file and not use some sort of VCS? That would just kill the purpose of having a text files in the first place. Being able to rollback to older version of blog by just using Git is very helpful. I've decided to have everything in one repository and using branches as my workflow to work on different areas of blog is sufficient for me. Want to include a new container into infrastructure in dev? Just switch the branch and code way. 

### Automation ready

I am a big fan of [Ansible](https://www.ansible.com). As a network engineer I've always looked at Linux guys how they can keep the state of machine using Puppet agents on servers and just by changing configuration on master node, everything obeyed the master. Then I've looked at my Cisco switch with IOS and sigh that there is no way I would get the agent there. But then Ansible and it's agent-less approach came and finally I could try out some automation on good old switches, routers. It's not perfect, but still better than nothing. My exposure to Ansible was then the choice of configuration management I would use on this blog.

### Dev / Test / Production environments

This was actually my first goal that came to my mind. With the help of configuration management I can spin up very similar environments for trying out the scripts and output of the work. [Vagrant](https://www.vagrantup.com/) helped me to quickly create base CentOS in VirtualBox and then I've build Ansible playbooks which feed the Vagrant provisioning. After debugging the errors it was very satisfying to see that the playbook did what it was supposed to and my blog was online in my VM. So after having this in my VM, build purely from Ansible playbook, I just need to change the Ansible inventory to the production droplet in Digital Ocean cloud and I have the same thing right? And surprisingly, it almost worked at the first try! Of course I haven't realized at first that I forgot about `iptables` configuration, but I've created basic iptables ruleset in Ansible, provisioned the dev environment, checked that configuration looks like I've indented and then just running the same playbook on different inventory set and production had the firewall ready. 

### Containers

Everybody is talking about containers and as I want to learn more about them, all services I use are inside Docker containers. I like the concept that each Docker container is responsible for one thing (similar to Unix way **insert link here**). I like that they create and abstraction layer on base OS, which helps with portability. Right now I have one VM which serves me as Docker host and I am looking forward to see how much workload I can put on the host before I notice performance degradation. After that I will try to scale the application horizontally, adding more small droplets and play with clustering options and I believe that very soon I will need some container orchestration such as Kubernetes or Docker Swarm. 

## Part 2 - how did I work?

### Getting to know Jekyll
- Started with Jekyll - followed the quick start to run on my local machine. I didn't want to fill my computer with Ruby dependencies so I used Docker container with internal server and got a general look on how would the posts look like.

### From local OS to ... Vagrant?
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
