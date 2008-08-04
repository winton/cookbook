Cookbook
========

Cookbook takes you from a fresh Debian/Ubuntu server to a complete Nginx/Rails/PHP stack using purely Capistrano. It also takes care of app deployment and pretty much writes your **config/deploy.rb** file for you.


The stack
---------

- Git
- Nginx
- Monit
- MySQL
- PHP (spawn-fcgi)
- Rails
- Ruby
- RubyGems


Install
-------

(Goto **Set up a PHP app** if deploying a PHP project)

### Capify your project

	capify .

### Add cookbook as a Git submodule

	git submodule add git@github.com:winton/cookbook.git config/cookbook

### Copy deploy.rb

Copy **config/cookbook/deploy.rb.example** to **config/deploy.rb**
	
Edit **deploy.rb** to your liking. Run `cap -T` to check out your new tasks.


Create the deploy user
----------------------

### Log in remotely as root

If you can't log in as root directly, but have the password (ServerBeach):

	su

### Change root's password

	passwd

### Add a deploy user

	adduser deploy

### Edit /etc/sudoers

	visudo

Add this line to the end of the file. This gives the deploy user "sudo without password" privileges:

	deploy ALL=NOPASSWD: ALL


Set up your fresh Debian server
-------------------------------

### On your machine

	cap debian:setup
	
### On the server

Its probably a good idea to restart the server after all that:

	sudo shutdown -r now
	

Deploy your app
---------------

### First deploy

	cap mysql:create:user
	cap mysql:create:db
	cap deploy:create
	
### Subsequent deploys

	cap deploy


Set up a PHP app
----------------

### Create directories

	config/
	public/

Move your site contents into the public directory. Follow instructions in the *Install* section.

Uncomment this line in deploy.rb:

	#:platform => :php,


##### Copyright (c) 2008 Winton Welsh, released under the MIT license