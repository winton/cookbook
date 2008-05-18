namespace :cookbook do
  desc 'Sets up cookbook deploy files'
  task :setup => [ :generate_deploy, :generate_shared ]
  
  desc 'Generates config/deploy.rb for use with cookbook'
  task :generate_deploy do
    if File.file? 'config/deploy.rb'
      puts '=> Backing up old deploy.rb...'
      system 'mv config/deploy.rb config/deploy.rb.old'
    end
    puts '=> Creating config/deploy.rb...'
    system "cp #{File.dirname(__FILE__)}/../templates/deploy.rb #{RAILS_ROOT}/config/deploy.rb"
  end
  
  desc 'Generates config/cookbook containing deploy config files'
  task :generate_shared do
    if File.directory? 'config/cookbook'
      puts '=> Backing up old config/cookbook...'
      system 'mv config/cookbook config/cookbook_old'
    end
    puts '=> Creating config/cookbook...'
    system "cp -R #{File.dirname(__FILE__)}/../templates/shared #{RAILS_ROOT}/config/cookbook"
  end
end