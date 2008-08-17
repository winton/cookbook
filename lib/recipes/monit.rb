Capistrano::Configuration.instance(:must_exist).load do
 
  namespace :monit do
    [ :stop, :start, :restart ].each do |t|
      desc "#{t.to_s.capitalize} Monit"
      task t, :roles => :app do
        sudo "/etc/init.d/monit #{t.to_s}"
      end
    end
    
    namespace :config do
      desc "Generate remote Monit config files"
      task :default, :roles => :app do
        upload_from_erb [
          '/etc/monit/monitrc',
          '/etc/default/monit'
        ], binding, :chown => 'root', :chmod => '0644', :folder => 'monit'
        monit.config.nginx
      end
      
      desc "Add mongrel cluster to monitrc"
      task :mongrel, :roles => :app do
        upload_from_erb '/etc/monit/mongrel', binding, :folder => 'monit'
        sudo_each [
          'cp -f /etc/monit/monitrc /etc/monit/monitrc2',
          'chmod 777 /etc/monit/monitrc2',
          'cat /etc/monit/mongrel >> /etc/monit/monitrc2',
          'cp -f /etc/monit/monitrc2 /etc/monit/monitrc',
          'rm -f /etc/monit/mongrel',
          'rm -f /etc/monit/monitrc2'
        ]
      end
      
      desc "Generate remote Nginx vhost"
      task :nginx, :roles => :app do
        if monit_auth_user
          sudo_each [
            "mkdir -p #{nginx_dir}/htpasswd",
            "htpasswd -bc #{nginx_dir}/htpasswd/monit #{monit_auth_user} #{monit_auth_pass}"
          ]
        end
        upload_from_erb "#{nginx_dir}/vhosts/monit.conf", binding, :folder => 'monit', :name => 'nginx.vhost'
      end
    end
  end
  
end