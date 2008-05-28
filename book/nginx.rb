Capistrano::Configuration.instance(:must_exist).load do

  namespace :nginx do
    namespace :config do
      desc "Copy vhost configs and generate htpasswd for staging"
      task :default, :roles => :app do
        nginx.config.htpasswd
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
      
      namespace :php do
        desc "Create new PHP vhost"
        task :vhost, :roles => :app do
          php_domain = ask "Set up a PHP vhost for what domain?"
          unless php_domain.empty?
            upload_from_erb "#{nginx_dir}/vhosts/#{php_domain}.conf", binding, :folder => 'nginx', :name => 'php.vhost'
          end
        end
        
        desc "Create new PHP vhost"
        task :vhost, :roles => :app do
          php_domain = ask "Set up a PHP vhost for what domain?"
          unless php_domain.empty?
            upload_from_erb "#{nginx_dir}/vhosts/#{application}_#{stage}.conf", binding, :folder => 'mongrel', :name => 'nginx.vhost'
          end
        end
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