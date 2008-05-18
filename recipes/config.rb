require 'erb'

Capistrano::Configuration.instance(:must_exist).load do

  namespace :config do
    namespace :create do
      desc "Create shared folder, render and copy all config files"
      task :default, :roles => :app do
        config.create.folder
        config.create.database
        config.create.mongrel
        config.create.nginx
        config.create.vhost
        config.create.htpasswd
        config.create.survive_reboot
      end
    
      desc "Create shared config folder"
      task :folder, :roles => :app do
        invoke_command "mkdir -p #{shared_path}/config", :via => run_method
      end
    
      desc "Render database.yml.erb and copy to shared config"
      task :database, :roles => :app do
        database_yml = File.read(File.join(File.dirname(__FILE__), 'shared', 'database.yml.erb'))
        put ERB.new(database_yml).result(binding), "#{shared_path}/config/database.yml"
      end

      desc "Render mongrel.yml.erb and copy to shared config"
      task :mongrel, :roles => :app do
        mongrel_yml = File.read(File.join(File.dirname(__FILE__), 'shared', 'mongrel.yml.erb'))
        put ERB.new(mongrel_yml).result(binding),  "#{shared_path}/config/mongrel.yml"
      end

      desc "Render nginx.conf.erb and copy to shared config"
      task :nginx, :roles => :app do
        nginx_conf = File.read(File.join(File.dirname(__FILE__), 'shared', 'nginx.conf.erb'))
        put ERB.new(nginx_conf).result(binding), "#{shared_path}/config/nginx.conf"
        sudo "cp -Rf #{shared_path}/config/nginx.conf #{nginx_config}/nginx.conf"
      end

      desc "Render vhost.conf.erb and copy to shared config"
      task :vhost, :roles => :app do
        vhost_config = File.read(File.join(File.dirname(__FILE__), 'shared', 'vhost.conf.erb'))
        put ERB.new(vhost_config).result(binding), "#{shared_path}/config/vhost.conf"
        sudo "mkdir -p #{nginx_config}/vhosts"
        sudo "cp -Rf #{shared_path}/config/vhost.conf #{nginx_config}/vhosts/#{application}_#{stage}.conf"
      end
    
      desc "Generate htpasswd file if auth_user"
      task :htpasswd, :roles => :app do
        if auth_user
          sudo "mkdir -p #{nginx_config}/htpasswd"
          sudo "htpasswd -bc #{nginx_config}/htpasswd/#{application}_#{stage} #{auth_user} #{auth_pass}"
        end
      end
    
      desc "Make our mongrel cluster restart proof"
      task :survive_reboot, :roles => :app do
        sudo "mkdir -p /etc/mongrel_cluster"
        sudo "rm -f /etc/mongrel_cluster/#{application}_#{stage}.yml"
        sudo "ln -s #{mongrel_config} /etc/mongrel_cluster/#{application}_#{stage}.yml"
        sudo "cp -Rf /usr/lib/ruby/gems/1.8/gems/mongrel_cluster-1.0.5/resources/mongrel_cluster /etc/init.d/"
        sudo "chmod +x /etc/init.d/mongrel_cluster"
        sudo "/usr/sbin/update-rc.d -f mongrel_cluster defaults"
      end
    end
  
    desc "Destroy all files created by config:create"
    task :destroy, :roles => :app do
      sudo "rm -f #{nginx_config}/vhosts/#{application}_#{stage}.conf"
      sudo "rm -f #{nginx_config}/htpasswd/#{application}_#{stage}"
      sudo "rm -f /etc/mongrel_cluster/#{application}_#{stage}.yml"
      invoke_command "rm -Rf #{shared_path}/config", :via => run_method
    end
  
    desc "Copies yml files in the shared config folder into our app config"
    task :to_app, :roles => :app do
      invoke_command "cp -Rf #{shared_path}/config/*.yml #{release_path}/config/", :via => run_method
    end
  end

end