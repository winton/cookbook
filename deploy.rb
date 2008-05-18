Capistrano::Configuration.instance(:must_exist).load do

  set :application,         cookbook[:application]
  set :repository,          cookbook[:repository]
  set :staging_mongrels,    cookbook[:staging][:mongrels]
  set :production_mongrels, cookbook[:production][:mongrels]
  set :port,                cookbook[:ssh_port]

  task :stage_specific_vars, :roles => :app do
    set :base_dir,       "/var/www/apps/#{stage}"
    set :deploy_to,      "#{base_dir}/#{application}"
    set :mongrel_config, "#{current_path}/config/mongrel.yml"
    
    set :db_table,       application + (stage == 'staging' ? '_' + stage : '')
    set :mongrel_port,   cookbook[:mongrel_port] + production_mongrels if stage == :staging
    
    set :branch,         cookbook[stage][:branch] || 'master'
    set :mongrels,       cookbook[stage][:mongrels]
    set :domain,         cookbook[stage][:domain]
    set :auth_user,      cookbook[stage][:auth_user]
    set :auth_pass,      cookbook[stage][:auth_pass]
  
    role :app, domain
    role :web, domain
    role :db,  domain, :primary => true
  end

  set :scm,              :git
  set :deploy_via,       :remote_cache
  set :repository_cache, 'git_cache'
  set :user,             'mongrel'
  set :runner,           'mongrel'
  set :db_user,          'rails'
  set :db_pass,          ''
  set :nginx_config,     '/etc/nginx'
  set :use_sudo,         false
  set :auth_user,        false        # default auth
  set :stage,            :production  # default stage

  ssh_options[:paranoid] = false


  ## Events
  on :before, :stage_specific_vars, :except => :staging  # executed before every task
  after 'deploy:update_code', 'config:to_app'
  
end

## Include recipes
Dir[File.expand_path(File.dirname(__FILE__)) + '/lib/*.rb'].each { |f| require f }