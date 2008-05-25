set :cookbook, {
  :application => 'my_app',
  :repository  => 'git@github.com:user/my-app.git',
  :base_dir    => '/var/www/apps',
  
  :mongrel_port => 3000,
  :ssh_port     => 22,        # Or any unused port above 1024 (best practice)
  
  :production => {
    :domain   => 'myapp.com',
    :mongrels => 2            # Ports 3000-3001
  },
  
  :staging => {
    :domain    => 'staging.myapp.com',
    :mongrels  => 1,          # Port 3002
    :auth_user => 'staging',  # Nginx HTTP authorization
    :auth_pass => 'password'
  },
  
  :sources => {
    :ruby     => 'ftp://ftp.ruby-lang.org/pub/ruby/1.8/ruby-1.8.6-p114.tar.gz',
    :rubygems => 'http://rubyforge.org/frs/download.php/35283/rubygems-1.1.1.tgz'
  }
}

# See vendor/plugins/cookbook/deploy.rb for more cookbook options
require 'vendor/plugins/cookbook/deploy'