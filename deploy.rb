Capistrano::Configuration.instance(:must_exist).load do
  
  # config/deploy.rb sets cookbook hash
  #
  # Required keys:
  #   application, repository, base_dir (see lib/stage.rb)
  
  set :application, cookbook[:application]
  set :repository,  cookbook[:repository]
  
  # Optional keys:
  #   nginx_dir, user, runner, db_user, db_pass, staging_mongrels, production_mongrels, ssh_port
  
  set :nginx_config,        cookbook[:nginx_dir]             || '/etc/nginx'  # Default values
  set :user,                cookbook[:user]                  || 'mongrel'
  set :runner,              cookbook[:runner]                || 'mongrel'
  set :db_user,             cookbook[:db_user]               || 'rails'
  set :db_pass,             cookbook[:db_pass]               || ''
  set :staging_mongrels,    cookbook[:staging][:mongrels]    || 1
  set :production_mongrels, cookbook[:production][:mongrels] || 2
  set :port,                cookbook[:ssh_port]              || 22
  
  # By default Cookbook uses git
  
  set :scm,              :git
  set :deploy_via,       :remote_cache
  set :repository_cache, 'git_cache'
  
  set :stage,     :production  # default stage
  set :auth_user, false        # default http auth
  set :use_sudo,  false        # this happens anyway when user == runner

  ssh_options[:paranoid] = false

  # Events

  on :before, 'stage:setup', :except => [ :staging, :testing ]  # executed before every task
  after 'deploy:update_code', 'config:to_app'
  
end

# Require recipes

Dir[File.expand_path(File.dirname(__FILE__)) + '/lib/*.rb'].each { |f| require f }