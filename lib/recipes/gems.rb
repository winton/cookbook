Capistrano::Configuration.instance(:must_exist).load do
  
  namespace :gems do  
    desc "List gems on remote server"
    task :list, :roles => :app do
      run_puts "gem list"
    end
    
    desc "Update gems on remote server"
    task :update, :roles => :app do
      sudo_each [
        "gem update --system",
        "gem update"
      ]
    end
    
    namespace :install do
      desc 'Install all standard gems'
      task :default, :roles => :app do
        gems.install.haml
        gems.install.hpricot
        gems.install.mime_types
        gems.install.mongrel
        gems.install.rails
        gems.install.redcloth
      end
      
      desc 'Install Chronic'
      task :chronic, :roles => :app do
        gem_install :chronic
      end
      
      desc 'Install gchart'
      task :gchart, :roles => :app do
        gem_install :googlecharts
      end
      
      desc 'Install HAML'
      task :haml, :roles => :app do
        gem_install :haml, '--no-ri'
      end
      
      desc 'Install Hpricot'
      task :hpricot, :roles => :app do
        gem_install :hpricot
      end
      
      desc 'Install Json'
      task :json, :roles => :app do
        gem_install :json
      end
      
      desc 'Install Mime-types'
      task :mime_types, :roles => :app do
        gem_install 'mime-types'
      end
      
      desc 'Install Mongrel'
      task :mongrel, :roles => :app do
        gem_install :mongrel
        gem_install :mongrel_cluster
        ROOT.mongrel.config.survive_reboot
      end
      
      desc 'Install Rails'
      task :rails, :roles => :app do
        gem_install :rails
      end
      
      desc 'Install RedCloth'
      task :redcloth, :roles => :app do
        gem_install 'RedCloth'
      end
    end
  
    desc "Uninstall a remote gem"
    task :uninstall, :roles => :app do
      gem_name = ask 'Enter the name of the gem to remove:'
      sudo "gem uninstall #{gem_name}"
    end
  end

end