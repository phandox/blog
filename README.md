# Personal blog project

Goal of this project is to create a personal blog site which is deployed in automated matter.
This project serve as learning experience for:
* Git
* Docker
* Automatic deployment
* Creating replicable environments for development
* Dev / Production parity
* Running application in cloud
* Continuous integration / Continuous deployment
* ...and of course blogging!

I will try to get exposure to Infrastructure as Code principles and will try to blog about this whole journey from building infrastructure using open source tools I tend to hear a lot about. Hopefully I will have an web application, which is cloud-ready, automatically deployed when all the tests pipeline are successful and easily replicable on other machines to deploy in test environemnt.

# How is this repository organized

Repository is organized into 3 main directories

* `jekyll-blog`
* `deploy`
* `provisioning`

`jekyll-blog` is directory where the web content, Jekyll blog is stored. All files for Jekyll are here. Note that generated site is also places here, however it is part of `.gitignore`. Developer can also cache Gems for Jekyll Docker container, as they are stored inside `jekyll-blog/vendor`. This directory is also part of `.gitignore` and shouldn't be in repository. 

`deploy` folder contains scripts for deploying blog content to servers, be it dev or production environment. It contains small Ansible playbook, which generates new version of blog on localhost and then pushes the files onto the server. Docker container running nginx is then updated with new content.

`provisioning` contains another Ansible playbook, which prepares the dev environment (using Vagrant) or production environment (*in progress*) by installing Docker on OS and creating a user for operating Docker. It also contains hardening of OS via Ansible by using framework from [dev-sec.io](https://dev-sec.io/). (*TODO in future*). Provisioning in local environment is run when you first time execute `vagrat up` or later you can use `vagrant provision`


# How to create development environment

Here are brief instruction how to get this environment to your local computer and start working on provisioning / deployment scripts or writing blog posts.
1. Clone repository with `git clone https://github.com/phandox/blog.git`
2. Run `vagrant up` in cloned repository and enter Vault password
3. Run `ansible-playbook -i deploy/dev/inventory.ini deploy/start_blog.yml`
4. Nginx server with Jekyll blog should be available on `http://localhost:8080`