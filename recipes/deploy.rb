Capistrano::Configuration.instance(:must_exist).load do
  
  namespace :deploy do
    desc "Restart mongrel cluster"
    task :restart, :roles => :app, :except => { :no_release => true } do
      mongrel.restart if platform == :mongrel
    end

    desc "Start mongrel cluster"
    task :start, :roles => :app do
      mongrel.start if platform == :mongrel
    end

    desc "Stop mongrel cluster"
    task :stop, :roles => :app do
      mongrel.stop if platform == :mongrel
    end
  
    desc "Deploy a fresh app"
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
        deploy.cold
      elsif platform == :php
        nginx.config.php
        deploy.default
      end
      nginx.start
    end
  
    desc "Stop servers and destroy all files"
    task :destroy, :roles => :app do
      deploy.stop
      mongrel.config.destroy if platform == :mongrel
      sudo "rm -Rf #{deploy_to}"
      nginx.config.destroy
      nginx.restart
    end
  end
  
end