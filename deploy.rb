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
  set :mongrel_etc_dir,     fetch(:mongrel_etc_dir,     '/usr/local/etc/mongrel_cluster')
  set :mongrel_gem_dir,     fetch(:mongrel_gem_dir,     '/usr/local/lib/ruby/gems/1.8/gems/mongrel_cluster-1.0.5')
  set :staging_mongrels,    fetch(:staging_mongrels,    1)
  set :production_mongrels, fetch(:production_mongrels, 2)
  
  # Git by default
  
  set :scm,                 :git
  set :deploy_via,          :remote_cache
  set :repository_cache,    'git_cache'
  
  ssh_options[:paranoid] = false

  # Events

  on :before, 'setup_stage',  :except => [ :setup_stage, :staging, :testing ] # Executed before every task
  after 'deploy:update_code', 'rails:config:to_app' # Copy shared config to app
  
end