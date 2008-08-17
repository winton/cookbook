Capistrano::Configuration.instance(:must_exist).load do

  namespace :mongrel do
    [ :stop, :start, :restart ].each do |t|
      desc "#{t.to_s.capitalize} the mongrel appserver"
      task t, :roles => :app do
        run "mongrel_rails cluster::#{t.to_s} -C #{mongrel_etc_dir}/#{application}_#{stage}.yml"
      end
    end
    
    namespace :config do      
      desc "Generate remote application config"
      task :default, :roles => :app do
        mongrel.config.cluster
        mongrel.config.nginx
      end

      desc "Generate remote remote mongrel_cluster config"
      task :cluster, :roles => :app do
        sudo "mkdir -p #{mongrel_etc_dir}"
        upload_from_erb "#{mongrel_etc_dir}/#{application}_#{stage}.yml", binding, :folder => 'mongrel', :name => 'mongrel.yml'
      end
      
      desc "Generate remote Nginx vhost"
      task :nginx, :roles => :app do
        upload_from_erb "#{nginx_dir}/vhosts/#{application}_#{stage}.conf", binding, :folder => 'mongrel', :name => 'nginx.vhost'
      end
      
      desc "Make our mongrel cluster restart-proof"
      task :survive_reboot, :roles => :app do
        sudo_each [
          "cp -Rf #{mongrel_gem_dir}/resources/mongrel_cluster /etc/init.d/",
          "chmod +x /etc/init.d/mongrel_cluster",
          "/usr/sbin/update-rc.d -f mongrel_cluster defaults"
        ]
      end
      
      desc "Destroy all files created by config:create"
      task :destroy, :roles => :app do
        sudo_each [
          "rm -f #{mongrel_etc_dir}/#{application}_#{stage}.yml",
          "rm -f #{nginx_dir}/vhosts/#{application}_#{stage}.conf"
        ]
      end
    end
  end

end