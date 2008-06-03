Capistrano::Configuration.instance(:must_exist).load do
  
  namespace :deploy do
    namespace :mongrel do
      [ :stop, :start, :restart ].each do |t|
        desc "#{t.to_s.capitalize} the mongrel appserver"
        task t, :roles => :app do
          run "mongrel_rails cluster::#{t.to_s} -C #{mongrel_config}"
        end
      end
    end
  
    namespace :nginx do
      desc "Restart nginx"
      task :restart, :roles => :app do
        deploy.nginx.stop
        deploy.nginx.start
      end

      desc "Start nginx"
      task :start, :roles => :app do
        sudo "/etc/init.d/nginx start"
      end

      desc "Stop nginx"
      task :stop, :roles => :app do
        sudo "/etc/init.d/nginx stop"
      end
    end

    desc "Restart mongrel cluster"
    task :restart, :roles => :app, :except => { :no_release => true } do
      deploy.mongrel.restart
    end

    desc "Start mongrel cluster"
    task :start, :roles => :app do
      deploy.mongrel.start
    end

    desc "Stop mongrel cluster"
    task :stop, :roles => :app do
      deploy.mongrel.stop
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