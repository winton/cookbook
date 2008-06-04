Capistrano::Configuration.instance(:must_exist).load do
  
  namespace :mysql do 
    namespace :create do
      desc "Create database and user"
      task :default, :roles => :db do
        mysql.create.db
        mysql.create.user
      end
      
      desc "Create database"
      task :db, :roles => :db do
        mysql_run "CREATE DATABASE #{db_table}"
      end
    
      desc "Create database user"
      task :user, :roles => :db do
        mysql_run [
          "CREATE USER '#{db_user}'@'localhost' IDENTIFIED BY '#{db_pass}'",
          "GRANT ALL PRIVILEGES ON *.* TO '#{db_user}'@'localhost'"
        ]
      end
    end
    
    namespace :update do
      desc 'Update mysql root password'
      task :root_password, :roles => :db do
        old_pass = ask "Current root password? (default: none)"
        new_pass = ask "New root password? (default: none)"
        sudo "mysqladmin -u root #{old_pass.empty? ? '' : "--password=#{old_pass} "}password #{new_pass}"
      end
    end
  
    namespace :destroy do
      desc "Destroy database and user"
      task :default, :roles => :db do
        mysql.destroy.db
        mysql.destroy.user
      end
      
      desc "Destroy database"
      task :db, :roles => :db do
        mysql_run "DROP DATABASE #{db_table}"
      end
      
      desc "Destroy database user"
      task :user, :roles => :db do
        mysql_run [
          "REVOKE ALL PRIVILEGES, GRANT OPTION FROM '#{db_user}'@'localhost'",
          "DROP USER '#{db_user}'@'localhost'"
        ]
      end
    end
    
    desc "Updates my.cnf from the file in config/cookbook"
    task :config do
      question = [
        "This task updates your server's my.cnf (MySQL config) with the one in config/cookbook.",
        "OK?"
      ]
      if yes(question)
        upload_from_erb "#{mysql_dir}/my.cnf", binding, :chown => 'root', :chmod => '0644', :folder => 'mysql'
        sudo "/etc/init.d/mysql restart"
      end
    end
  end

end