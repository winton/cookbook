Capistrano::Configuration.instance(:must_exist).load do
  
  namespace :deploy do
    desc "Restart mongrel cluster"
    task :restart, :roles => :app, :except => { :no_release => true } do
      mongrel.restart
    end

    desc "Start mongrel cluster"
    task :start, :roles => :app do
      mongrel.start
    end

    desc "Stop mongrel cluster"
    task :stop, :roles => :app do
      mongrel.stop
    end
  
    desc "Make apps folder and own it, deploy:setup, deploy:config, :deploy:cold"
    task :create, :roles => :app do
      sudo_each [
        "mkdir -p #{base_dir}",
        "chown -R mongrel:mongrel #{base_dir}"
      ]
      deploy.setup
      if platform == :mongrel
        rails.config.default
        mongrel.config.default
        nginx.config.mongrel
      elsif platform == :php
        nginx.config.php
      end
      deploy.cold
    end
  
    desc "Stop servers and destroy all files"
    task :destroy, :roles => :app do
      deploy.stop
      if platform == :mongrel
        mongrel.config.destroy
      end
      nginx.config.destroy
      sudo "rm -Rf #{deploy_to}"
    end
  end
  
end