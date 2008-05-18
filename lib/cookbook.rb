set :application,         cookbook[:application]
set :repository,          cookbook[:repository]
set :staging_mongrels,    cookbook[:staging][:mongrels]
set :production_mongrels, cookbook[:production][:mongrels]
set :port,                cookbook[:ssh_port]

task :stage_specific_vars, :roles => :app do
  set :domain,         cookbook[stage][:domain]
  set :branch,         cookbook[stage][:branch] || 'master'
  set :base_dir,       cookbook[:base_dir]
  set :deploy_to,      "#{base_dir}/#{application}"
  set :mongrels,       cookbook[stage][:mongrels]
  set :mongrel_port,   cookbook[:mongrel_port] + (stage == :staging ? production_mongrels : 0)
  set :mongrel_config, "#{current_path}/config/mongrel.yml"
  set :db_table,       application + (stage == 'staging' ? '_' + stage : '')
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
set :stage,            :production  # default stage

ssh_options[:paranoid] = false


## Events
on :before, :stage_specific_vars, :except => :staging  # executed before every task
after 'deploy:update_code', 'config:to_app'


## Include recipes
Dir[File.expand_path(File.dirname(__FILE__)) + '/recipes/*.rb'].each { |f| require 'recipes/' + File.basename(f, '.rb') }