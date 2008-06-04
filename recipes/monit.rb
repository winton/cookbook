Capistrano::Configuration.instance(:must_exist).load do
 
  namespace :monit do
    [ :stop, :start, :restart ].each do |t|
      desc "#{t.to_s.capitalize} Monit"
      task t, :roles => :app do
        sudo "/etc/init.d/monit #{t.to_s}"
      end
    end
    
    namespace :config do
      desc "Add mongrels to monitrc"
      task :mongrel, :roles => :app do
        upload_from_erb '/etc/monit/mongrel', binding, :chown => 'root', :chmod => '0644', :folder => 'monit'
        sudo 'cd /etc/monit; cat mongrel >> monitrc; rm -f mongrel'
      end
    end
  end
  
end