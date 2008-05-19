set :cookbook, {
  :application => 'my_app',
  :repository  => 'git@github.com:user/my-app.git',
  :base_dir    => '/var/www/apps',
  
  :mongrel_port => 3000,
  :ssh_port     => 22,
  
  :production => {
    :domain   => 'myapp.com',
    :mongrels => 2            # ports 3000-3001
  },
  
  :staging => {
    :domain    => 'staging.myapp.com',
    :mongrels  => 1,          # port 3002
    :auth_user => 'staging',  # nginx HTTP authorization
    :auth_pass => 'password'
  }
}

# See vendor/plugins/cookbook/deploy.rb for more cookbook options
require 'vendor/plugins/cookbook/deploy'