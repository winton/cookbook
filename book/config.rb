Capistrano::Configuration.instance(:must_exist).load do

  namespace :config do
    namespace :create do
      desc "Create shared folder, render and copy all config files"
      task :default, :roles => :app do
        config.create.folder
        config.create.database
        config.create.mongrel
        config.create.vhost
        config.create.htpasswd
        config.create.survive_reboot
      end
    
      desc "Create shared config folder"
      task :folder, :roles => :app do
        run "mkdir -p #{shared_path}/config"
      end
    
      desc "Render database.yml.erb and copy to shared config"
      task :database, :roles => :app do
        upload_from_erb "#{shared_path}/config/database.yml"
      end

      desc "Render mongrel.yml.erb and copy to shared config"
      task :mongrel, :roles => :app do
        upload_from_erb "#{shared_path}/config/mongrel.yml"
      end

      desc "Render vhost.conf.erb and copy to shared config"
      task :vhost, :roles => :app do
        upload_from_erb "#{shared_path}/config/vhost.conf", binding, :folder => 'nginx'
        sudo_each [
          "mkdir -p #{nginx_dir}/vhosts",
          "cp -Rf #{shared_path}/config/vhost.conf #{nginx_dir}/vhosts/#{application}_#{stage}.conf"
        ]
      end
    
      desc "Generate htpasswd file if auth_user"
      task :htpasswd, :roles => :app do
        if auth_user
          sudo_each [
            "mkdir -p #{nginx_dir}/htpasswd",
            "htpasswd -bc #{nginx_dir}/htpasswd/#{application}_#{stage} #{auth_user} #{auth_pass}"
          ]
        end
      end
    
      desc "Make our mongrel cluster restart proof"
      task :survive_reboot, :roles => :app do
        sudo_each [
          "mkdir -p /etc/mongrel_cluster",
          "rm -f /etc/mongrel_cluster/#{application}_#{stage}.yml",
          "ln -s #{mongrel_config} /etc/mongrel_cluster/#{application}_#{stage}.yml",
          "cp -Rf /usr/lib/ruby/gems/1.8/gems/mongrel_cluster-1.0.5/resources/mongrel_cluster /etc/init.d/",
          "chmod +x /etc/init.d/mongrel_cluster",
          "/usr/sbin/update-rc.d -f mongrel_cluster defaults"
        ]
      end
    end
  
    desc "Destroy all files created by config:create"
    task :destroy, :roles => :app do
      sudo_each [
        "rm -f #{nginx_dir}/vhosts/#{application}_#{stage}.conf",
        "rm -f #{nginx_dir}/htpasswd/#{application}_#{stage}",
        "rm -f /etc/mongrel_cluster/#{application}_#{stage}.yml",
        "rm -Rf #{shared_path}/config"
      ]
    end
  
    desc "Copies yml files in the shared config folder into our app config"
    task :to_app, :roles => :app do
      run "cp -Rf #{shared_path}/config/*.yml #{release_path}/config/"
    end
  end

end