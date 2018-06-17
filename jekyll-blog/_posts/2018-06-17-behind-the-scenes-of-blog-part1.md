---
layout: post
title:  "Behind the scenes of blog - part 1"
date:   2018-06-17 12:00:00 +0100
categories: behind_the_scenes
---

Welcome to the first of many post in series *Behind the scenes of blog*! As this is not just my first blog post here, but a whole first blog ever, I've decided to share my learning process about various technologies I've used while creating this site. From most of them I've just heard the cool name of the product, stickers of logos on every single laptop (of course I also have stickers on mine) and read about the hype around Docker, Vagrant, Jenkins, Terraform, Kubernetes and how they are so *amazing* and that they make life so much easier...

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

I am a big fan of [Ansible](https://www.ansible.com). As a network engineer I've always looked at Linux guys how they can keep the state of machine using Puppet agents on servers and just by changing configuration on master node, everything obeyed the master. Then I've looked at my Cisco switch with IOS and sigh that there is no way I would get the agent there. But then Ansible and it's agent-less approach came and finally I could try out some automation on good old switches, routers. It's not perfect, but with every new version, networking support gets better and better. My exposure to Ansible was then the choice of configuration management I would use on this blog.

### Dev / Test / Production environments

This was actually my first goal that came to my mind. With the help of configuration management I can spin up very similar environments for trying out the scripts and output of the work. [Vagrant](https://www.vagrantup.com/) helped me to quickly create base CentOS VM in VirtualBox and then I've build Ansible playbooks which feed the Vagrant provisioning. After debugging the errors it was very satisfying to see that the playbook did what it was supposed to and my blog was online in my VM. So after having this in my VM, build purely from Ansible playbook, I just need to change the Ansible inventory to the production droplet in Digital Ocean cloud and I have the same thing right? And surprisingly, it almost worked at the first try! Of course I haven't realized at first that I forgot about `iptables` configuration, but I've created basic iptables ruleset in Ansible, provisioned the dev environment, checked that configuration looks like I've indented and then just running the same playbook on different inventory set and production had the firewall ready. 

### Containers

Everybody is talking about containers and as I want to learn more about them, all services I use are inside Docker containers. The concept that each Docker container is responsible for one thing is appealing to me. I like that they create and abstraction layer on base OS, which helps with portability. Right now I have one VM which serves me as Docker host and I am looking forward to see how much workload I can put on the host before I notice performance degradation. After that I will try to scale the application horizontally, adding more small droplets and play with clustering options and I believe that very soon I will need some container orchestration such as Kubernetes or Docker Swarm. 

## Part 2 - how did I work?

With the goals set for the project, time to get the actual work done. In this post, I describe the initial, first attempt for creating a site, so trust me, it's **far** from perfect. From the point of architecture all through best practices, there is certainly a room for improvement. The main point of this part is to say it's fine to start and create something tangible that you can improve on and learn on mistakes / false assumptions. 

### Getting to know Jekyll
When I've chosen the Jekyll as my generator of blog, I know that I don't want to fill up my laptop with unnecessary Ruby dependencies that the Jekyll need. So I've use [Docker container of Jekyll](https://github.com/envygeeks/jekyll-docker) to test the waters, see how does the Minima theme look like on development server. I didn't really changed or customized my Dockerfile as I haven't see it as it being necessary for such a simple use case. Having `jekyll serve` to run inside container and mapping the ports to host ports I saw the simple template posts. Well that was easy and very quick start. As I was happy with Minima layout I moved to more interesting part for me and that is creating a server to run the Jekyll generated content. 

### From laptop to...Vagrant?

To satisfy my goal of having similar but separated dev / production environments I needed to get used to working on dedicated machine right from the start. As you can see in [history of repo](https://github.com/phandox/blog/commit/2ee3def6a340f3ce99d616bc874cf783bc872a79) I though that at first I will learn how to install nginx right into OS and then I will try the container stuff. However I've abandoned this idea for going straight into container word as doing nginx in container doesn't strip me from managing my configuration files. I still have to get an understanding of web server stuff even though it's in container. So the lesson taken from that shift is that even though spinning up new service in Docker container is easy (just look at the few instructions in README files of all Dockerfiles), it doesn't hide the fact that you still have to go beyond default settings, as they are usually fit for development purposes.

For the base box in Vagrant I've chosen CentOS 7. The reason behind CentOS is that it is still a traditional full Linux, ready for production and more importantly it's by default ready to enforce SELinux. I remember that few years ago, there were tons of Linux tutorials starting with *Make sure you turn off SELinux before continuing*. During my search now in 2018 I found very good introduction resources about SELinux, why is it important and not this annoying thing that makes your life miserable. So I am definitely not a guy who would just ignore SELinux and for Docker host I feel that it is especially important to have. Docker process is quite powerful and having this extra safety net if things go south so your container doesn't take over control of all other container contents is pretty mandatory in my opinion. 

In future I will definitely look into distributions that has been built for container environment, for example CoreOS. There is also a possibility, that I will find out that OS doesn't really matter, only thing that matters is container orchestration platform such as Kubernetes. But from the start that would be too deep into rabbit hole and I've wanted the firm grasp on fundamentals.

## Stop SSH into your servers

Typical scenario after having my CentOS box up is to SSH into the machine using `vagrant ssh` and start the configuration by hand. From the beginning I knew I don't want that and that I will purely use Ansible to configure anything on the box. Reasons are pretty straightforward:

1. Having the Ansible do the work for me, I already have script which can be used on other servers
2. The playbook gives me a documentation on what exactly was done on the server. I don't have to guess when I SSH into machine and start looking around what have I done six months ago (assuming no one SSH into server during these six months)

When I started writing playbooks few weeks ago, it came with a lot of tuning, reading the errors why have the Ansible failed. From the start I've leveraged the simplicity of command `vagrant provision` with Ansible as provisioner. This was easy to execute, however for debugging I wanted some find tuning as even with verbosity specified in Vagrantfile, the output wasn't really readable. Sometime I've preferred to launch the playbook by hand. The first problem came with inventory file but with a little bit of exploration of `.vagrant` directory, you can find Vagrant-generated inventory which will look something like this:
```
# Generated by Vagrant

docker_single_host ansible_host=127.0.0.1 ansible_port=2222 ansible_user='vagrant' ansible_ssh_private_key_file='/home/lukas/blog/.vagrant/machines/docker_single_host/virtualbox/private_key'
```

As you can see, inventory file is quite standard and nothing prevents you from using it like this: `ansible-playbok -i .vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory <your-playbook>`

So what exactly does my Ansible playbook for provisioning do? It consists of two roles `docker` and `firewall_policy`. Names are pretty self-explanatory but in short, docker role install the Docker and docker-py (required for Ansible to control Docker containers via playbooks) on CentOS, creates a user account which is part of docker group, copies SSH key for him. Then the firewall is set up, where I've chosen the `iptables` instead of `firewalld` which is there by default on CentOS. The reason for this is that for some reason there is no `firewalld` on Digital Ocean's CentOS 7 image and I figured out that I am already familiar with iptables and the knowledge is easier transferable to other distributions. I've divided the tasks to files `firewall_policy/tasks/inbound_rules.yml` and `firewall_policy/tasks/outbound_rules.yml`. 

I've consider changing outbound policy to `DROP` as I would explicitly define which communication can be established from server to Internet but at the second though and debugging I found it to be more of a hassle than really a security feature. Infected host will most probably use some well-known protocol with C&C server like HTTPS and without application visibility and reputation databases it would be like finding a needle in a hay. More importantly it could bring a feeling of false security that I am fully that all my outgoing traffic is under my control and might miss malicious communication via HTTPS. So my approach would be to watch logs of iptables first and later implement IPS with Suricata. All of the logs will be transfer to centralized logging using ELK stack or something similar.


## OS is ready, time for containers

I have my Vagrant box provisioned, `docker run hello-world` works flawlessly, time to set up more useful containers.
For a web server, which will host blog site I've chosen `nginx`. Because I've already used Ansible for provisioning, I wrote Ansible playbook for deploying the Jekyll blog on the server.

As I've read through Docker documentation about [volumes](https://docs.docker.com/storage/volumes/), I've learned that named volumes are now preferred way to mount and handle external data from host to container. It caused me a small clash with README instructions of [nginx image](https://hub.docker.com/_/nginx/), where you use bind mount for attaching the data. So my blog content and `nginx.conf` file are mounted as named volumes inside container. I've encountered error when I've tried to mount the `nginx.conf` file to `/etc/nginx/nginx.conf` inside container and the reason is that you can't mount the named volume to a file, it has to be a directory. I could have just bake `nginx.conf` file inside container but I like the fact that I can just change `nginx.conf` file with volume to different configuration and the container doesn't drag additional data, although the creation of directory and launching nginx with non-default configuration might be over-complicated.

Right now, the workflow of deployment isn't perfect. I always remove the generated Jekyll `_site` to have the most up to date version synced inside container. It takes few seconds to create but I loose the idempotency. I've also used `synchronize` module instead of `copy` in Ansible as it is much faster for many small file because of the nature of rsync behind the scenes. The flag `delete` is enabled, which mirrors the directory with synchronize - if I delete the post in my repository, it will also be deleted from blog. This helps me to keep a Git repository as single source of truth. 

When the content of blog is ready and on the machine, I use Ansible `template` module to generate and send main `nginx.conf` file destination of named docker volume. They are created in previous steps of playbook, so the variable is defined. 

All the files are ready and Ansible moves to actually run the container. Right now it's just single container of nginx with mounted volumes and exposed port. The port which is exposed is defined in `group_vars` of inventory which allows me to just reference variable inside Ansible task and in inventory I can change the port depends if the deployments is happening in Vagrant or in the production environment. After this is done, I make a new rule in iptables to make sure that exposed port from Docker is accessible from outside and I am greeted by my blog on my localhost on the forwarded Vagrant port.

## Blog lives inside laptop, time to show the world

In dev environment I have created blog site, which shows me the result, everything looks good, time to replicate this to something else than Vagrant box. As I've already made the Ansible playbooks for provisioning the machines and deploying the blog, moving to other server shouldn't be a problem right? Well there are few things to solve and it is actually creating the server. As I wanted to continue in the same fashion to replicate the environment via code, I've made a simple list that would be good for the first hosting provider:

- **Relatively cheap** - I don't need super sized VPS with tons of RAM, right now I think that even the cheapest plan of any provider would be an overkill for site. 
- **REST API support** - I want to spin up the server via API and configure the resources simply by calling an API. I don't want to click in Web UI.
- **Extra features** - firewalls, load balancers, monitoring - this would be all nice to have, given the fact that they can be controlled by an API
- **Hourly billing** - I plan to spin up testing environments and tearing them down all the time - being billed purely on time I've spent is an advantage for me
- **Terraform provider** will be a plus to kick start the architecture without writing pure Python scripts.

I've chosen Digital Ocean. They have an API, Terraform provider and reasonable pricing. It's not the typical cloud from the big 3 - AWS, Azure or Google Cloud. Digital Ocean doesn't really feel like *cloud* I think about it as more of a modern VPS provider. Using the tools that the cloud provides will be essentially a vendor lock-in and as I've heard on one of [Prague Containers Meetups](https://prgcont.cz/): *"Never go with vendor lock-in. Tools provided by AWS can be useful when you want to quick start and get to market but after that you will always built something for yourself."* Later I will definitely try out AWS, maybe even for hosting this site or other projects.

### Deploy infrastructure with Terraform
Because Digital Ocean has a provider for Terraform ready, I though to myself that spinning up Droplet would be very easy. However there are few pain points with Terraform and Digital Ocean:

- Sometimes the tfstate file doesn't refresh and I have to deploy infrastructure again
- No support for Ansible as a provisioner out of box
- When managing DNS records with Terraform, it will also affect the whole domain not just the records

Support of Ansible in Terraform would definitely by nice to have, but workaround for this can be achieve by usage of  [dynamic inventory for Terraform](https://github.com/adammck/terraform-inventory) made by Adam Mckaig, which require just the Terraform state file. It has worked for my provisioning playbook and deployment playbook without issue. So to deploy completely new infrastructure I use these commands:
```
$ terraform plan
$ terraform apply
$ ansible-playbook -i terraform-inventory <playbook for provisioning>
$ ansible-playbook -i terraform-inventory <playbook for deployment>
``` 

There are some constrains, as you have to be in directory of your `tfstate` file or set up environment variable `TF_STATE` for path to `tfstate` file as stated in the [README of the terraform-inventory project](https://github.com/adammck/terraform-inventory#more-usage).

I've already moved my domain `luknagy.com` to be managed by Digital Ocean, as they provide the service. I've successfully changed NS records and the domain lives in my Digital Ocean account. When the blog will be deployed, I want Terraform to create a CNAME `blog.luknagy.com` on A record pointing to droplet. However to manage domain resource, `ip_address` is a *required argument* to be used with `digitalocean_domain` resource. That means, you can't just create a domain with Terraform and have no droplets assigned to this domain. From one perspective, this makes sense, because what would you do with the domain if there are no Droplets using it? I could think of having MX records to direct your emails which arrive at `@luknagy.com` as a one example, but this assume you have already a Droplet which serves as mail server and it will have a A record assigned. But when you do `terraform destroy` (although not really used for production), to remove your droplets, it will also take the whole domain with it. So after issuing that command your Digital Ocean account is empty of any resources. However recovery is easy, you just deploy your infrastructure again, with `terraform apply` and the domain with records will be created together with IP address of a new Droplet. The state is satisfied and you don't end up with half destroyed infrastructure, so I guess this works as intended but I know this surprised me on the first try I issued `terraform destroy` and saw what does the Terraform want to remove. Also keep in mind that IP address you get for new droplet is different so you might come to SSH issues with warnings of MITM attack - you should update your `known_hosts` file accordingly.

## Blog is running, finish line crossed right? Not so fast...

And now I get to the last part of this blog post. Terraform creates a Droplet for me, Ansible provision new machine and deploy the blog content on new droplet and you are able to read this post. Seems like the work is done and now I just create more article right? Fortunately, no. This is just the beginning, let's call it a first prototype. Much work will be done to make the site better and correct the mistakes and obstacles I've made for myself.

I want to add HTTPS support, reverse proxy in front of the containers, monitoring the health of the containers and get alerts if something goes wrong (or better, try to auto-heal), centralized logging for docker host and from containers itself using log management stack such as ELK and high availability of containers, clustering them on multiple nodes across the regions and after that, orchestration is necessary...

So as you can see **a lot** of work awaits. I am sure as I will learn along the path that I will find more resources on how to do architecture better, what tools does exist, the advantages and disadvantages of different cloud providers and more. I'll happily write another posts about my new findings and how I would apply them on the site. 

This was a really long post for an introduction and I will definitely make the subsequent posts shorter, to get them more digestible. If you got all the way to the end, you have my respect and thank you for reading this post. 
