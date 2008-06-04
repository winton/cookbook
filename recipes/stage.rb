Capistrano::Configuration.instance(:must_exist).load do

  desc 'Set the target stage to staging'
  task :staging do
    set :stage, :staging
  end

  desc 'Set the target stage to test'
  task :testing do
    set :stage, :test
  end
  
  # None of this works in a namespace
  desc 'Set up stage-dependent properties'
  task :setup_stage do
    set :base_dir,       "#{cookbook[:base_dir]}/#{stage}"
    set :deploy_to,      "#{base_dir}/#{application}"
  
    set :db_table,       application + (stage == :staging ? "_#{stage}" : '')
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
  
end