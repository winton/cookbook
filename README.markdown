Cookbook
========

**This plugin is deprecated and has been replaced by [Ubistrano](http://github.com/winton/ubistrano).**

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

### Install gem

	gem install winton-cookbook

### Capify your project

	capify .

### Copy deploy.rb

Copy **[deploy.rb.example](http://github.com/winton/cookbook/tree/master%2Fdeploy.rb.example?raw=true)** to **config/deploy.rb**
	
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

You may want to run the commands in **[debian:aptitude](http://github.com/winton/cookbook/tree/master/lib/recipes/debian.rb)** from the remote shell if it is your first time doing so.
	
	cap debian:aptitude
	cap debian:config
	cap debian:install
	
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