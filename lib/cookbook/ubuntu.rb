Capistrano::Configuration.instance(:must_exist).load do
  
  namespace :ubuntu do
    desc "Configure and install a fresh Ubuntu server"
    task :default do
      msg :about_templates
      if yes("Have you already created the user defined in deploy.rb?")
        ubuntu.aptitude.default
        ubuntu.config.default
        ubuntu.install.default
      else
        msg :visudo
      end
    end
    
    namespace :aptitude do
      desc 'Run all tasks'
      task :default do
        if yes("Do you want me to run aptitude update, upgrade, and install build-essential?")
          aptitude.update
          aptitude.upgrade
          aptitude.essential
        else
          msg :aptitude_default
        end
      end
      
      desc 'Aptitude update'
      task :update do
        sudo_puts 'aptitude update -q -y'
      end
      
      desc 'Aptitude upgrade'
      task :upgrade do
        sudo_puts 'aptitude upgrade -q -y'
      end
      
      desc 'Aptitude install build-essential'
      task :essential do
        sudo_puts 'aptitude install build-essential -q -y'
      end
    end
    
    namespace :config do
      desc 'Run all tasks'
      task :default do
        ubuntu.config.sshd_config
        ubuntu.config.iptables
      end

      desc "Updates server iptables"
      task :iptables do
        if yes(msg(:iptables))
          upload_from_erb '/etc/iptables.rules', binding, :folder => 'ubuntu'
          sudo_each [
            'iptables-restore < /etc/iptables.rules',
            'rm /etc/iptables.rules'
          ]
        end
      end
      
      desc "Updates sshd_config"
      task :sshd_config do
        if yes(msg(:sshd_config))
          set :port, 22   # Comment out for testing
          change_line '/etc/ssh/sshd_config', 'Port 22',              "Port #{ssh_port}"
          change_line '/etc/ssh/sshd_config', 'PermitRootLogin yes',  'PermitRootLogin no'
          change_line '/etc/ssh/sshd_config', 'X11Forwarding yes',    'X11Forwarding no'
          change_line '/etc/ssh/sshd_config', 'UsePAM yes',           'UsePAM no'
          remove_line '/etc/ssh/sshd_config', 'UseDNS .*'
          add_line    '/etc/ssh/sshd_config', 'UseDNS no'
          sudo '/etc/init.d/ssh reload'
          set :port, ssh_port
        end
      end
    end
    
    namespace :install do
      desc 'Run all tasks'
      task :default do
        ubuntu.install.git
        ubuntu.install.mysql
        ubuntu.install.ruby
        ubuntu.install.rubygems
        ubuntu.install.sphinx
      end
      
      desc "Install Git"
      task :git, :roles => :app do
        install_source(:git) do |path|
          sudo_puts [
            "apt-get build-dep git -q -y",
            make_install(path)
          ]
        end
      end
      
      desc 'Install MySQL'
      task :mysql, :roles => :db do
        sudo_puts 'aptitude install mysql-server mysql-client libmysqlclient15-dev -q -y'
        ROOT.mysql.config
        ROOT.mysql.create.user
        puts msg(:secure_mysql)
      end
      
      desc 'Install Ruby'
      task :ruby, :roles => :app do
        install_source(:ruby) do |path|
          sudo_puts make_install(path)
        end
      end
      
      desc 'Install RubyGems'
      task :rubygems, :roles => :app do
        install_source(:rubygems) do |path|
          run_puts "cd #{path} && sudo ruby setup.rb"
        end
        gems.update
        gems.install
      end
      
      desc 'Install Sphinx'
      task :sphinx, :roles => :app do
        install_source(:sphinx) do |path|
          sudo_puts make_install(path)
        end
      end
    end
  end

end