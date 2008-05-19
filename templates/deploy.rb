set :cookbook, {
  :application => 'my_app',
  :repository  => 'git@github.com:user/my-app.git',
  
  :mongrel_port => 3000,
  :ssh_port     => 22,
  
  :production => {
    :domain   => 'myapp.com',
    :mongrels => 2  # ports 3000-3001
  },
  
  :staging => {
    :domain    => 'staging.myapp.com',
    :mongrels  => 1,          # port 3002
    :auth_user => 'staging',  # nginx HTTP authorization
    :auth_pass => 'password'
  }
}

require 'vendor/plugins/cookbook/deploy'