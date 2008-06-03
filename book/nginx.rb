Capistrano::Configuration.instance(:must_exist).load do

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
    
    namespace :config do
      desc "Copy vhost configs and generate htpasswd for staging"
      task :default, :roles => :app do
        question = [
          "This task updates your server's nginx.conf with the one in config/cookbook and creates the htpasswd file if auth_user is set.",
          "OK?"
        ]
        if yes(question)
          if auth_user
            sudo_each [
              "mkdir -p #{nginx_dir}/htpasswd",
              "htpasswd -bc #{nginx_dir}/htpasswd/#{application}_#{stage} #{auth_user} #{auth_pass}"
            ]
          end
          sudo_each [
            "mkdir -p #{nginx_dir}/vhosts",
            "chmod 0755 #{nginx_dir}/vhosts"
          ]
          upload_from_erb "#{nginx_dir}/nginx.conf", binding, :chown => 'root', :chmod => '0644', :folder => 'nginx'
        end
      end
      
      desc "Generate mongrel vhost"
      task :mongrel, :roles => :app do
        upload_from_erb "#{nginx_dir}/vhosts/#{application}_#{stage}.conf", binding, :folder => 'mongrel', :name => 'nginx.vhost'
      end
      
      desc "Create PHP vhost"
      task :php, :roles => :app do
        upload_from_erb "#{nginx_dir}/vhosts/#{application}_#{stage}.conf", binding, :folder => 'php', :name => 'nginx.vhost'
      end
      
      desc "Destroy all files created by config"
      task :destroy, :roles => :app do
        sudo_each [
          "rm -f #{nginx_dir}/vhosts/#{application}_#{stage}.conf",
          "rm -f #{nginx_dir}/htpasswd/#{application}_#{stage}",
        ]
      end
    end
  end

end