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
    set :base_dir,  "#{cookbook[:base_dir]}/#{stage}"
    set :deploy_to, "#{base_dir}/#{application}"
  
    set :branch,    cookbook[stage][:branch] || 'master'
    set :db_table,  application + (stage == :staging ? "_#{stage}" : '')    
    set :domain,    [ cookbook[stage][:domain] ].flatten
    set :host,      cookbook[stage][:host]

    role :app, host, :primary => true
    role :web, host
    role :db,  host
  end
  
end