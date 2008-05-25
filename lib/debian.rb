Capistrano::Configuration.instance(:must_exist).load do
  
  namespace :debian do
    desc "Configure and install a fresh Debian server"
    task :deploy do
      if yes("Have you created the user defined in config/deploy.rb? (See README)")
        debian.create.sshd_config
        debian.create.iptables
        debian.create.locales
        debian.create.bash_profile      
        debian.aptitude.update
        debian.aptitude.upgrade
        debian.aptitude.essential
        debian.install.mysql
        debian.install.ruby
        debian.install.rubygems
      end
    end
    
    namespace :create do
      desc "Uploads the bash_profile file in config/cookbook"
      task :bash_profile do
        question = [
          "This task uploads the bash_profile file in config/cookbook.",
          "OK?"
        ]
        if yes(question)
          usr = ask "Update bash_profile for which user? (default: #{user})", user
          upload_from_erb "/home/#{usr}/.bash_profile", binding, :chown => usr
        end
      end
    
      desc "Updates server locales from the file in config/cookbook"
      task :locales do
        question = [
          "This task updates the server's locales from the file in config/cookbook.",
          "OK?"
        ]
        if yes(question)
          upload_from_erb '/etc/locale.gen', binding, :chown => 'root', :chmod => '0644'
          sudo '/usr/sbin/locale-gen'
        end
      end
    
      desc "Updates server iptables from the file in config/cookbook"
      task :iptables do
        question = [
          "This task updates your server's iptables with the file in config/cookbook.",
          "OK?"
        ]
        if yes(question)
          upload_from_erb '/etc/iptables.rules', binding
          sudo 'iptables-restore < /etc/iptables.rules'
          sudo 'rm /etc/iptables.rules'
        end
      end
    
      desc "Updates sshd_config from the file in config/cookbook"
      task :sshd_config do
        question = [
          "This task updates your server's sshd_config with the file in config/cookbook.",
          "This task assumes your server's current ssh port is 22.",
          "This task will change your ssh port to the one in config/deploy.rb.",
          "OK?"
        ]
        if yes(question)
          set :port, 22   # Comment out for testing
          upload_from_erb '/etc/ssh/sshd_config', binding, :chown => 'root', :chmod => '0644'
          sudo '/etc/init.d/ssh reload'
          set :port, ssh_port
        end
      end
    end
    
    namespace :aptitude do
      desc 'Aptitude update'
      task :update do
        sudo_and_puts 'aptitude update -q -y'
      end
      
      desc 'Aptitude upgrade'
      task :upgrade do
        sudo_and_puts 'aptitude upgrade -q -y'
      end
      
      desc 'Aptitude install build-essential'
      task :essential do
        sudo_and_puts 'aptitude install build-essential -q -y'
      end
    end
    
    namespace :install do
      desc 'Install MySQL'
      task :mysql, :roles => :db do
        sudo_and_puts 'aptitude install mysql-server mysql-client libmysqlclient15-dev libmysql-ruby -q -y'
        upload_from_erb '/etc/mysql/my.cnf', binding, :chown => 'root', :chmod => '0644'
        sudo '/etc/init.d/mysql restart'
        puts [
          "\nIt is highly recommended you run mysql_secure_installation manually.",
          "See http://dev.mysql.com/doc/refman/5.1/en/mysql-secure-installation.html\n"
        ].join("\n")
      end
      
      desc 'Install Ruby'
      task :ruby do
        install_source(:ruby) do |path|
          sudo "cd #{path} && ./configure && make && sudo make install"
        end
      end
      
      desc 'Install RubyGems'
      task :rubygems do
        install_source(:rubygems) do |path|
          sudo_each [
            "cd #{path} && ruby setup.rb",
            "ln -s /usr/bin/gem1.8 /usr/bin/gem"
          ]
        end
        gems.update
      end
    end
  end

end