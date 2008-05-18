namespace :db do  
  namespace :create do    
    desc "Create database"
    task :default, :roles => :app do
      invoke_command "echo \"CREATE DATABASE #{db_table}\" | #{mysql_call}", :via => run_method
    end
    
    desc "Create database and user"
    task :all, :roles => :app do
      db.create.default
      db.create.user.default
    end
    
    namespace :user do      
      desc "Create database user"
      task :default, :roles => :app do
        invoke_command "echo \"CREATE USER '#{db_user}'@'localhost' IDENTIFIED BY '#{db_pass}'\" | #{mysql_call}", :via => run_method
        db.create.user.permissions
      end

      desc "Create database user permissions"
      task :permissions, :roles => :app do
        invoke_command "echo \"GRANT ALL PRIVILEGES ON *.* TO '#{db_user}'@'localhost'\" | #{mysql_call}", :via => run_method
      end
    end
  end
  
  namespace :destroy do
    desc "Destroy database"
    task :default, :roles => :app do
      invoke_command "echo \"DROP DATABASE #{db_table}\" | #{mysql_call}", :via => run_method
    end
    
    desc "Destroy database and user"
    task :all, :roles => :app do
      db.destroy.default
      db.destroy.user.default
    end
    
    namespace :user do      
      desc "Destroy database user"
      task :default, :roles => :app do
        db.destroy.user.permissions
        invoke_command "echo \"DROP USER '#{db_user}'@'localhost'\" | #{mysql_call}", :via => run_method
      end

      desc "Destroy database user permissions"
      task :permissions, :roles => :app do
        invoke_command "echo \"revoke all privileges, grant option from '#{db_user}'@'localhost';\" | #{mysql_call}", :via => run_method
      end
    end
  end
  
  def mysql_call
    @mysql_root_password = @mysql_root_password || Capistrano::CLI.password_prompt("Password for mysql root: ")
    "mysql -u root --password=#{@mysql_root_password}"
  end
end