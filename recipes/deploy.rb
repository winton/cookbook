Capistrano::Configuration.instance(:must_exist).load do
  
  namespace :deploy do
    desc "Restart mongrel cluster"
    task :restart, :roles => :app, :except => { :no_release => true } do
      mongrel.restart if platform == :rails
    end

    desc "Start mongrel cluster"
    task :start, :roles => :app do
      mongrel.start if platform == :rails
    end

    desc "Stop mongrel cluster"
    task :stop, :roles => :app do
      mongrel.stop if platform == :rails
    end
  
    desc "Deploy a fresh app"
    task :create, :roles => :app do
      mysql.create.db
      sudo_each [
        "mkdir -p #{base_dir}",
        "chown -R #{user}:#{user} #{base_dir}"
      ]
      deploy.setup
      if platform == :rails
        mongrel.config.default
        nginx.config.default
        rails.config.default
        deploy.cold
      elsif platform == :php
        php.config.default
        deploy.default
      end
      nginx.restart
    end
  
    desc "Stop servers and destroy all files"
    task :destroy, :roles => :app do
      deploy.stop
      mongrel.config.destroy if platform == :rails
      sudo "rm -Rf #{deploy_to}"
      nginx.config.destroy
      nginx.restart
      mysql.destroy.db
    end
  end
  
end