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
        u = ask "Create ssh keys for which user? (default: #{user})", user
        p = ask "Enter a password for this key:"
        
        sudo_each [
          "ssh-keygen -t rsa -N '#{p}' -q -f /home/#{u}/.ssh/id_rsa",
          "chmod 0700 /home/#{u}/.ssh",
          "chown -R #{u} /home/#{u}/.ssh"
        ]
        sudo_and_puts "tail -1 /home/#{u}/.ssh/id_rsa.pub"
      end
    end
    
    desc "Copies contents of ssh public keys into authorized_keys file"
    task :upload_keys do
      question = [
        "This task copies all of your public keys in ~/.ssh to the server's authorized_keys.",
        "OK?"
      ]
      if yes(question)
        u = ask "Upload ssh public keys to which user? (default: #{user})", user
        k = ask "Press enter to copy all public keys (~/.ssh/*.pub), or paste a key: ", get_ssh_keys
      
        if k.empty?
          ssh.setup if yes("No keys found. Generate ssh keys now?")
        else
          sudo_each [
            "test -d /home/#{u}/.ssh || mkdir /home/#{u}/.ssh",
            "touch /home/#{u}/.ssh/authorized_keys",
            "echo \"#{k}\" >> /home/#{u}/.ssh/authorized_keys",
            "chmod 0700 /home/#{u}/.ssh",
            "chmod 0600 /home/#{u}/.ssh/authorized_keys",
            "chown -R #{u} /home/#{u}/.ssh",
          ]
        end
      end
    end
  end

end