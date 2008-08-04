Cookbook
========

Cookbook takes you from a fresh Debian/Ubuntu server to a complete Nginx/Rails/PHP stack using purely Capistrano. It also takes care of app deployment and pretty much writes your **config/deploy.rb** file for you.


The stack
---------

* Git
* Nginx
* Mongrel cluster
* Monit
* MySQL
* PHP (Nginx w/ spawn-fcgi)
* Rails
* Ruby
* RubyGems
* Sphinx


Install
-------

(Goto **Set up a PHP app** if deploying a PHP project)

### Capify your project

	capify .

### Add cookbook as a Git submodule

	git submodule add git@github.com:winton/cookbook.git config/cookbook

### Copy deploy.rb

Copy **config/cookbook/deploy.rb.example** to **config/deploy.rb**
	
Edit **config/deploy.rb** to your liking. Run `cap -T` to check out your new tasks.


Create the deploy user
----------------------

### Log in remotely as root

If you can't log in as root directly, but have the password (ServerBeach):

	su

### Change root's password if you already haven't

	passwd

### Add a deploy user

	adduser deploy

### Edit /etc/sudoers

	visudo

Add this line to the end of the file. This gives the deploy user "sudo without password" privileges:

	deploy ALL=NOPASSWD: ALL

### Upload your SSH keys

	cap ssh:setup
	
(Just answer no to the first question if you already have local keys generated.)


Set up your fresh Debian server
-------------------------------

### On your machine

	cap debian:setup
	
(See **config/cookbook/recipes/debian.rb**. You might want to run the tasks individually to know what's going on.)
	
### On the server

Its probably a good idea to restart the server after all that:

	sudo shutdown -r now
	

Deploy your app
---------------

### First deploy

	cap deploy:create

(See **config/cookbook/recipes/deploy.rb** to know what's going on here.)
	
Optionally set up log rotation and a monit entry for your mongrels:

	cap log:rotate
	cap monit:config:mongrel
	
### Subsequent deploys

	cap deploy


Deploy staging
--------------

See *Deploy your app*, but replace `cap` with `cap staging`.

Example:

	cap staging deploy:create


Set up a PHP app
----------------

### Create directories

	config/
	public/

Move your site contents into the public directory. Follow instructions in the *Install* section.

Uncomment this line in deploy.rb:

	#:platform => :php,


##### Copyright (c) 2008 Winton Welsh, released under the MIT license