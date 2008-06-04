Capistrano::Configuration.instance(:must_exist).load do
  
  namespace :debian do
    desc "Configure and install a fresh Debian server"
    task :deploy do
      if yes("Have you created the user defined in config/deploy.rb? (See vendor/plugins/cookbook/README)")
        debian.config.sshd_config
        debian.config.iptables
        debian.config.locales
        debian.config.bash_profile      
        debian.aptitude.update
        debian.aptitude.upgrade
        debian.aptitude.essential
        debian.install.git
        debian.install.lighttpd
        debian.install.mysql
        debian.install.nginx
        debian.install.php
        debian.install.ruby
        debian.install.rubygems
        debian.install.gems
      end
    end
    
    namespace :aptitude do
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
      desc "Uploads the bash_profile file in config/cookbook"
      task :bash_profile do
        question = [
          "This task uploads the bash_profile file in config/cookbook.",
          "OK?"
        ]
        if yes(question)
          usr = ask "Update bash_profile for which user? (default: #{user})", user
          upload_from_erb "/home/#{usr}/.bash_profile", binding, :chown => usr, :folder => 'debian'
        end
      end

      desc "Updates server iptables from the file in config/cookbook"
      task :iptables do
        question = [
          "This task updates your server's iptables with the file in config/cookbook.",
          "OK?"
        ]
        if yes(question)
          upload_from_erb '/etc/iptables.rules', binding, :folder => 'debian'
          sudo_each [
            'iptables-restore < /etc/iptables.rules',
            'rm /etc/iptables.rules'
          ]
        end
      end

      desc "Updates server locales from the file in config/cookbook"
      task :locales do
        question = [
          "This task updates the server's locales from the file in config/cookbook.",
          "OK?"
        ]
        if yes(question)
          upload_from_erb '/etc/locale.gen', binding, :chown => 'root', :chmod => '0644', :folder => 'debian'
          sudo '/usr/sbin/locale-gen'
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
          upload_from_erb '/etc/ssh/sshd_config', binding, :chown => 'root', :chmod => '0644', :folder => 'debian'
          sudo '/etc/init.d/ssh reload'
          set :port, ssh_port
        end
      end
    end
    
    namespace :install do
      desc "Install Git"
      task :git, :roles => :app do
        install_source(:git) do |path|
          sudo_puts [
            "aptitude install tcl8.4 tk8.4 gettext -q -y",
            "cd #{path} && ./configure && make && sudo make install"
          ]
        end
      end
      
      desc "Install Lighttpd"
      task :lighttpd, :roles => :app do
        sudo_puts 'aptitude install libpcre3-dev libbz2-dev -q -y'
        install_source(:lighttpd) do |path|
          sudo_puts "cd #{path} && ./configure && make && sudo make install"
        end
      end
      
      desc 'Install MySQL'
      task :mysql, :roles => :db do
        sudo_puts 'aptitude install mysql-server mysql-client libmysqlclient15-dev libmysql-ruby -q -y'
        ROOT.mysql.config
        puts [
          "\nIt is highly recommended you run mysql_secure_installation manually.",
          "See http://dev.mysql.com/doc/refman/5.1/en/mysql-secure-installation.html\n"
        ].join("\n")
      end
      
      desc 'Install Nginx'
      task :nginx, :roles => :app do
        sudo_puts 'aptitude install libpcre3 libpcre3-dev libpcrecpp0 libssl-dev zlib1g-dev -q -y'
        install_source(:nginx) do |path|
          sudo_puts "cd #{path} && ./configure --sbin-path=/usr/local/sbin --with-http_ssl_module && make && sudo make install"
        end
        upload_from_erb '/etc/init.d/nginx', binding, :chown => 'root', :chmod => '+x', :folder => 'nginx'
        sudo '/usr/sbin/update-rc.d -f nginx defaults'
        ROOT.nginx.config.default
      end
      
      desc "Install PHP"
      task :php, :roles => :app do
        sudo_puts 'aptitude install php5-cli php5-cgi php5-mysql php5-xcache -q -y'
        upload_from_erb [
          '/usr/local/bin/php-fastcgi',
          '/etc/init.d/init-fastcgi'
        ], binding, :chown => 'root', :chmod => '+x', :folder => 'debian'
        sudo '/usr/sbin/update-rc.d -f init-fastcgi defaults'
      end
      
      desc 'Install Ruby'
      task :ruby, :roles => :app do
        install_source(:ruby) do |path|
          sudo_puts "cd #{path} && ./configure && make && sudo make install"
        end
      end
      
      desc 'Install RubyGems'
      task :rubygems, :roles => :app do
        install_source(:rubygems) do |path|
          sudo_puts "cd #{path} && ruby setup.rb"
        end
        gems.update
        gems.install.all
      end
      
      desc 'Install Sphinx'
      task :sphinx, :roles => :app do
        install_source(:sphinx) do |path|
          sudo_puts "cd #{path} && ./configure && make && sudo make install"
        end
      end
    end
  end

end