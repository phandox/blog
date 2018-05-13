# Adding nginx repo to CentOS 
````
/etc/yum.repos.d/nginx.repo

[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/{rhel|centos}/{6|7}/$basearch/
gpgcheck=0 # TODO why this?
enabled=1
````

https://nginx.org/keys/nginx_signing.key - GPG key for nginx
Add GPG keys to Centos
`curl -s https://nginx.org/keys/nginx_signing.key > nginx_key.sig && sudo rpm --import nginx_key.sig && rm nginx_key.sig`
Install nginx
`yum install nginx`
Configure Virtual Servers in nginx
````
http {
    server {
        listen  80 default_server;
        server_name www.luknagy.com; luknagy.com; blog.luknagy.com;
    }

}
````
Should include local host resolution when vagrant is used - in production, real IP addresses
This should be done by ansible I guess? Or some vagrant plugins.
Directory structure in conf.d should be: `http/<virtual_server>.conf` There will be `default.conf`
So far, nginx server just as http server, no proxy is defined (will be in the future just to test it).

Create `/www/blog` folder for storing Jekyll content - maybe skript in Vagrantfile for provision? 

Create a test environemnt for generating pages - Jekyll will directly output there. After validation it might be moved to production (gree/blue deployment?)
Run nginx after booting up

Deal with SELinux - might do some research on this topic in general
Enforce httpd type on www destination
Good article on SELinux is here https://www.techrepublic.com/blog/linux-and-open-source/practical-selinux-for-the-beginner-contexts-and-labels/ - just and introduction to get productive

set local time zone - CET (`timedatectl set-timezone CET)

Prepare provisioning script (before separating dev/production):
libselinux-python is required for Ansible to work with this
- Build site with Jekyll (local laptop - Docker)
- Move generated site to correct folder in Vagrant machine (shell script, vagrant provision or new mounted volume? Might use Ansible...)
- Set up SELinux type on files (looks like a work for local script on server - or Ansible playbook)
- Reload nginx server configuration (Ansible Playbook should do this, ran from local machine)


Ansible modules used for deployment:
There are multiple phases:
1. Prepare Operation system with web server installation, updates and all required instalation (vagrant provision) 
2. Add virtual server to server configuration
3. Add content to virtual web server

Each phase can be represented as Ansible Role. There should be a way to reproduce this roles on inventories of various kind (be it static, dynamic...)

Create group for web server content + add permissions to write for vagrant
Create nginx test blog site