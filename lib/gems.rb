Capistrano::Configuration.instance(:must_exist).load do
  
  namespace :gems do  
    desc "List gems on remote server"
    task :list do
      stream "gem list"
    end
  
    desc "Update gems on remote server"
    task :update do
      sudo "gem update"
    end
  
    desc "Install a gem on the remote server"
    task :install do
      gem_name = Capistrano::CLI.ui.ask 'Enter the name of the gem to install: '
      sudo "gem install #{gem_name}"
    end
  
    desc "Uninstall a gem from the remote server"
    task :remove do
      gem_name = Capistrano::CLI.ui.ask 'Enter the name of the gem to remove: '
      sudo "gem install #{gem_name}"
    end
  end

end