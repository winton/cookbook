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

    desc "Custom restart task for mongrel cluster"
    task :restart, :roles => :app, :except => { :no_release => true } do
      deploy.mongrel.restart
    end

    desc "Custom start task for mongrel cluster"
    task :start, :roles => :app do
      deploy.mongrel.start
    end

    desc "Custom stop task for mongrel cluster"
    task :stop, :roles => :app do
      deploy.mongrel.stop
    end
  
    desc "Make apps folder and own it, deploy:setup, config:create, :deploy:cold"
    task :create, :roles => :app do
      sudo_each [
        "mkdir -p #{base_dir}",
        "chown -R mongrel:mongrel #{base_dir}"
      ]
      deploy.setup
      config.create.default
      deploy.cold
    end
  
    desc "Stop servers and destroy all files"
    task :destroy, :roles => :app do
      deploy.stop
      config.destroy
      sudo "rm -Rf #{deploy_to}"
    end
  end
  
end