Capistrano::Configuration.instance(:must_exist).load do
  
  namespace :debian do
    desc "Configure and install a fresh Debian server"
    task :default do
      if yes("Have you created the user defined in config/deploy.rb? (See vendor/plugins/cookbook/README)")
        debian.aptitude.default
        debian.config.default
        debian.install.default
      end
    end
    
    namespace :aptitude do
      desc 'Run all tasks'
      task :default do
        aptitude.update
        aptitude.upgrade
        aptitude.essential
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
        debian.config.sshd_config
        debian.config.iptables
        debian.config.locales
        debian.config.bash_profile
      end
      
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
      desc 'Run all tasks'
      task :default do
        debian.install.git
        debian.install.lighttpd
        debian.install.mysecureshell
        debian.install.mysql
        debian.install.nginx
        debian.install.php
        debian.install.ruby
        debian.install.rubygems
        debian.install.sphinx
        debian.install.monit
      end
      
      desc "Install Git"
      task :git, :roles => :app do
        install_source(:git) do |path|
          sudo_puts [
            "aptitude install tcl8.4 tk8.4 gettext -q -y",
            ";cd #{path} && ./configure && make && sudo make install"
          ]
        end
      end
      
      desc "Install Lighttpd" # Lighttpd install is purely for spawn-fcgi
      task :lighttpd, :roles => :app do
        sudo_puts 'aptitude install libpcre3-dev libbz2-dev -q -y'
        install_source(:lighttpd) do |path|
          sudo_puts ";cd #{path} && ./configure && make && sudo make install"
        end
      end
      
      desc 'Install Monit'
      task :monit, :roles => :db do
        sudo_puts 'aptitude install monit -q -y'
        ROOT.monit.config.default
      end
      
      desc "Install MySecureShell"
      task :mysecureshell, :roles => :app do
        # http://www.howtoforge.com/mysecureshell_sftp_debian_etch
        sudo_puts 'aptitude install libssl0.9.7 ssh openssh-server -q -y'
        install_source(:mysecureshell) do |path|
          sudo_puts ";cd mysecureshell* && ./configure && make && sudo make install"
        end
      end
      
      desc 'Install MySQL'
      task :mysql, :roles => :db do
        sudo_puts 'aptitude install mysql-server mysql-client libmysqlclient15-dev libmysql-ruby -q -y'
        ROOT.mysql.config
        ROOT.mysql.create.user
        puts [
          '',
          "It is highly recommended you run mysql_secure_installation manually.",
          "See http://dev.mysql.com/doc/refman/5.1/en/mysql-secure-installation.html",
          ''
        ].join("\n")
      end
      
      desc 'Install Nginx'
      task :nginx, :roles => :app do
        # apache2-utils for htpasswd, rest for nginx build
        sudo_puts 'aptitude install apache2-utils libpcre3 libpcre3-dev libpcrecpp0 libssl-dev zlib1g-dev -q -y'
        install_source(:nginx) do |path|
          sudo_puts ";cd #{path} && ./configure --sbin-path=/usr/local/sbin --with-http_ssl_module && make && sudo make install"
        end
        upload_from_erb '/etc/init.d/nginx', binding, :chown => 'root', :chmod => '+x', :folder => 'nginx'
        sudo '/usr/sbin/update-rc.d -f nginx defaults'
        ROOT.nginx.config.run_once.default
      end
      
      desc "Install PHP"
      task :php, :roles => :app do
        sudo_puts 'aptitude install php5-cli php5-cgi php5-mysql php5-xcache php-pear php-mail php-net-smtp -q -y'
        upload_from_erb [
          '/usr/local/bin/php-fastcgi',
          '/etc/init.d/init-fastcgi'
        ], binding, :chown => 'root', :chmod => '+x', :folder => 'php'
        sudo '/usr/sbin/update-rc.d -f init-fastcgi defaults'
      end
      
      desc 'Install Ruby'
      task :ruby, :roles => :app do
        install_source(:ruby) do |path|
          sudo_puts ";cd #{path} && ./configure && make && sudo make install"
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
          sudo_puts ";cd #{path} && ./configure && make && sudo make install"
        end
      end
    end
  end

end