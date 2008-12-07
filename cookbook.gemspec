Gem::Specification.new do |s|
  s.name    = 'cookbook'
  s.version = '2.0.0'
  s.date    = '2008-12-07'
  
  s.summary     = "Provision a Debian/God/Apache/Passenger/Rails stack using Capistrano"
  s.description = "Provision a Debian/God/Apache/Passenger/Rails stack using Capistrano"
  
  s.author   = 'Winton Welsh'
  s.email    = 'mail@wintoni.us'
  s.homepage = 'http://github.com/winton/cookbook'
  
  s.has_rdoc = false
  
  # = MANIFEST =
  s.files = %w[
  MIT-LICENSE
  README.markdown
  cookbook.gemspec
  deploy.rb.example
  lib/cookbook.rb
  lib/cookbook_helpers.rb
  lib/recipes/debian.rb
  lib/recipes/deploy.rb
  lib/recipes/gems.rb
  lib/recipes/log.rb
  lib/recipes/mongrel.rb
  lib/recipes/monit.rb
  lib/recipes/mysql.rb
  lib/recipes/nginx.rb
  lib/recipes/php.rb
  lib/recipes/rails.rb
  lib/recipes/ssh.rb
  lib/recipes/stage.rb
  lib/templates/debian/bash_profile.erb
  lib/templates/debian/iptables.rules.erb
  lib/templates/debian/locale.gen.erb
  lib/templates/debian/sshd_config.erb
  lib/templates/log/rotate.conf.erb
  lib/templates/mongrel/mongrel.yml.erb
  lib/templates/mongrel/nginx.vhost.erb
  lib/templates/monit/mongrel.erb
  lib/templates/monit/monit.erb
  lib/templates/monit/monitrc.erb
  lib/templates/monit/nginx.vhost.erb
  lib/templates/mysql/my.cnf.erb
  lib/templates/nginx/nginx.conf.erb
  lib/templates/nginx/nginx.erb
  lib/templates/php/init-fastcgi.erb
  lib/templates/php/nginx.vhost.erb
  lib/templates/php/php-fastcgi.erb
  lib/templates/rails/database.yml.erb
 ]
  # = MANIFEST =
end