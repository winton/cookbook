Capistrano::Configuration.instance(:must_exist).load do
  
  namespace :gems do  
    desc "List gems on remote server"
    task :list do
      run_puts "gem list"
    end
    
    desc "Update gems on remote server"
    task :update do
      sudo_each [
        "gem update --system",
        "gem update"
      ]
    end
    
    namespace :install do
      desc "Install a gem on the remote server"
      task :default do
        gem_install ask('Enter the name of the gem to install:')
      end
      
      desc 'Install Rails, HAML, and Mongrel'
      task :all do
        gems.install.haml
        gems.install.hpricot
        gems.install.chronic
        gems.install.mime_types
        gems.install.mongrel
        gems.install.rails
      end
      
      desc 'Install Chronic'
      task :rails do
        gem_install :chronic
      end
      
      desc 'Install HAML'
      task :haml do
        gem_install :haml, '--no-ri'
      end
      
      desc 'Install Hpricot'
      task :hpricot do
        gem_install :hpricot
      end
      
      desc 'Install Mime-types'
      task :mime_types do
        gem_install :mime_types
      end
      
      desc 'Install Mongrel'
      task :mongrel do
        gem_install :mongrel
        gem_install :mongrel_cluster
        mongrel.config.survive_reboot
      end
      
      desc 'Install Rails'
      task :rails do
        gem_install :rails
      end
    end
  
    desc "Uninstall a gem from the remote server"
    task :remove do
      gem_name = ask 'Enter the name of the gem to remove:'
      sudo "gem uninstall #{gem_name}"
    end
  end

end