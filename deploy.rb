# Require helpers and recipes

require File.expand_path('helpers.rb', File.dirname(__FILE__))
Dir[    File.expand_path('book/*.rb',  File.dirname(__FILE__))].each do |f|
  require f
end


Capistrano::Configuration.instance(:must_exist).load do
  
  # See cookbook hash in config/deploy.rb
  
  cookbook[:port] = cookbook[:ssh_port]   # Port is too ambiguous for me
  cookbook.each do |key, value|           # Merge cookbook with capistrano
    value.respond_to?(:keys) ? value.each { |k, v| set "#{key}_#{k}".intern, v } : set(key, value)
  end
  
  # Default values
  
  set :port,                fetch(:port,                22)
  set :user,                fetch(:user,                'mongrel')
  set :stage,               fetch(:stage,               :production)
  set :db_user,             fetch(:db_user,             'rails')
  set :db_pass,             fetch(:db_pass,             '')
  set :use_sudo,            fetch(:use_sudo,            false)
  set :auth_user,           fetch(:auth_user,           false)
  set :nginx_dir,           fetch(:nginx_dir,           '/usr/local/nginx/conf')
  set :mysql_dir,           fetch(:mysql_dir,           '/etc/mysql')
  set :staging_mongrels,    fetch(:staging_mongrels,    1)
  set :production_mongrels, fetch(:production_mongrels, 2)
  
  # Git by default
  
  set :scm,                 fetch(:scm,                 :git)
  set :deploy_via,          fetch(:deploy_via,          :remote_cache)
  set :repository_cache,    fetch(:repository_cache,    'git_cache')
  
  ssh_options[:paranoid] = false

  # Events

  on :before, 'setup_stage',  :except => [ :setup_stage, :staging, :testing ] # Executed before every task
  after 'deploy:update_code', 'config:to_app' # Copy shared config to app
  
end