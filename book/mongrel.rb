Capistrano::Configuration.instance(:must_exist).load do

  namespace :mongrel do
    namespace :config do
      ETC_FOLDER = '/usr/local/etc/mongrel_cluster'
      GEM_FOLDER = '/usr/local/lib/ruby/gems/1.8/gems/mongrel_cluster-1.0.5'
      
      desc "Copy mongrel config and make the cluster restart-proof"
      task :default, :roles => :app do
        mongrel.config.cluster
        mongrel.config.nginx
        mongrel.config.survive_reboot
      end

      desc "Render mongrel.yml.erb and copy to etc"
      task :cluster, :roles => :app do
        sudo "mkdir -p #{ETC_FOLDER}"
        upload_from_erb "#{ETC_FOLDER}/#{application}_#{stage}.yml", binding, :folder => 'mongrel', :name => 'mongrel.yml'
      end
      
      desc "Copy Nginx vhost"
      task :nginx, :roles => :app do
        upload_from_erb "#{nginx_dir}/vhosts/#{application}_#{stage}.conf", binding, :folder => 'mongrel', :name => 'nginx.vhost'
      end
      
      desc "Make our mongrel cluster restart-proof"
      task :survive_reboot, :roles => :app do
        sudo_each [
          "cp -Rf #{GEM_FOLDER}/resources/mongrel_cluster /etc/init.d/",
          "chmod +x /etc/init.d/mongrel_cluster",
          "/usr/sbin/update-rc.d -f mongrel_cluster defaults"
        ]
      end
      
      desc "Destroy all files created by config:create"
      task :destroy, :roles => :app do
        sudo "rm -f #{ETC}/#{application}_#{stage}.yml"
      end
    end
  end

end