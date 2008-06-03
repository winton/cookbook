Capistrano::Configuration.instance(:must_exist).load do
  
  namespace :ssh do
    desc 'Generate ssh keys and upload to server'
    task :setup do
      ssh.create_keys
      ssh.upload_keys
    end
    
    desc "Creates an rsa ssh key pair in your ~/.ssh folder"
    task :create_keys do
      question = [
        "This task generates a rsa ssh key pair in your ~/.ssh folder.",
        "OK?"
      ]
      system('ssh-keygen -t rsa') if yes(question)
    end
    
    desc "Creates an rsa ssh key pair in the server's ~/.ssh folder"
    task :create_server_keys do
      question = [
        "This task generates a rsa ssh key pair in the server's ~/.ssh folder and displays the public key.",
        "OK?"
      ]
      if yes(question)
        usr  = ask "Create ssh keys for which user? (default: #{user})", user
        pass = ask "Enter a password for this key:"
        
        sudo_each [
          "ssh-keygen -t rsa -N '#{pass}' -q -f /home/#{usr}/.ssh/id_rsa",
          "chmod 0700 /home/#{usr}/.ssh",
          "chown -R #{usr} /home/#{usr}/.ssh"
        ]
        sudo_puts "tail -1 /home/#{usr}/.ssh/id_rsa.pub"
      end
    end
    
    desc "Copies contents of ssh public keys into authorized_keys file"
    task :upload_keys do
      question = [
        "This task copies all of your public keys in ~/.ssh to the server's authorized_keys.",
        "OK?"
      ]
      if yes(question)
        usr  = ask "Upload ssh public keys to which user? (default: #{user})", user
        keys = ask "Press enter to copy all public keys (~/.ssh/*.pub), or paste a key: ", get_ssh_keys
      
        if k.empty?
          ssh.setup if yes("No keys found. Generate ssh keys now?")
        else
          sudo_each [
            "mkdir /home/#{usr}/.ssh",
            "touch /home/#{usr}/.ssh/authorized_keys",
            "echo \"#{keys}\" >> /home/#{usr}/.ssh/authorized_keys",
            "chmod 0700 /home/#{usr}/.ssh",
            "chmod 0600 /home/#{usr}/.ssh/authorized_keys",
            "chown -R #{usr} /home/#{usr}/.ssh",
          ]
        end
      end
    end
  end

end