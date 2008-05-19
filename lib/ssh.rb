Capistrano::Configuration.instance(:must_exist).load do
  
  namespace :ssh do
    desc 'Generate ssh keys and upload to server'
    task :setup do
      ssh.create_keys
      ssh.upload_keys
    end
    
    desc 'Creates an rsa ssh key pair in ~/.ssh'
    task :create_keys do
      system 'ssh-keygen -t rsa'
    end
    
    desc 'Copies contents of ssh public keys into authorized_keys file'
    task :upload_keys do
      keys = Capistrano::CLI.ui.ask 'Press enter to copy all public keys (~/.ssh/*.pub), or paste a key: '
      keys = get_ssh_keys if keys.strip.empty?
      if keys.strip.empty?
        answer = Capistrano::CLI.ui.ask 'No keys found. Generate ssh keys now? (y/n): '
        ssh.setup if answer.downcase.include?('y')
      else
        sudo 'test -d ~/.ssh || mkdir ~/.ssh'
        sudo 'chmod 0700 ~/.ssh'
        sudo 'touch ~/.ssh/authorized_keys'
        sudo 'chmod 0600 ~/.ssh/authorized_keys'
        sudo "echo \"#{keys}\" >> ~/.ssh/authorized_keys"
      end
    end
    
    def get_ssh_keys
      keys = Dir[File.expand_path('~/.ssh/*.pub')].collect do |f|
        File.open(f).collect { |line| line.strip.empty? ? nil : line.strip }.compact
      end
      keys.flatten.join "\n"
    end
  end

end