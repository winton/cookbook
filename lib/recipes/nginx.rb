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
      desc "Generate remote application config"
      task :default, :roles => :app do
        if auth_user
          sudo_each [
            "mkdir -p #{nginx_dir}/htpasswd",
            "htpasswd -bc #{nginx_dir}/htpasswd/#{application}_#{stage} #{auth_user} #{auth_pass}"
          ]
        end
      end
      
      desc "Destroy all files created by config"
      task :destroy, :roles => :app do
        sudo_each "rm -f #{nginx_dir}/htpasswd/#{application}_#{stage}"
      end
      
      namespace :run_once do
        desc "Generate remote system config (run once)"
        task :default, :roles => :app do
          question = [
            "This task updates your server's nginx.conf with the one in config/cookbook.",
            "OK?"
          ]
          if yes(question)
            sudo_each [
              "mkdir -p #{nginx_dir}/vhosts",
              "chmod 0755 #{nginx_dir}/vhosts"
            ]
            upload_from_erb "#{nginx_dir}/nginx.conf", binding, :chown => 'root', :chmod => '0644', :folder => 'nginx'
          end
        end
        
        desc "Destroy remote system config"
        task :destroy, :roles => :app do
          sudo_each "rm -f #{nginx_dir}/nginx.conf"
        end
      end
      
      namespace :ssl do
        desc "Generate SSL key"
        task :default, :roles => :app do
          # http://www.geotrust.com/quickssl/csr
          question = [
            "This task creates cert/key and cert/csr. Press enter for all optional SSL questions.",
            "Use these files when buying an SSL cert.",
            '',
            "Place the purchased cert in cert/cert. Set :ssl_cert => true in deploy.rb.",
            "OK?"
          ]
          if yes(question)
            system 'mkdir -p cert'
            system 'openssl genrsa -out cert/key 1024'
            system 'openssl req -new -key cert/key -out cert/csr'
          end
        end
      end
    end
  end

end