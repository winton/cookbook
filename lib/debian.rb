Capistrano::Configuration.instance(:must_exist).load do
  
  namespace :debian do
    namespace :create do
      task :default do
        debian.sshd_config
        debian.iptables
        debian.locales
        debian.bash_profile      
        debian.aptitude.update
        debian.aptitude.upgrade
        debian.aptitude.essential
      end
    
      desc "Uploads the bash_profile file in config/cookbook"
      task :bash_profile do
        question = [
          "This task uploads the bash_profile file in config/cookbook.",
          "OK?"
        ]
        if yes(question)
          u = ask "Update bash_profile for which user? (default: #{user})", user
          upload_from_erb "/home/#{u}/.bash_profile", binding, :chown => u
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
  end

end