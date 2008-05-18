namespace :cookbook do
  desc 'Sets up cookbook deploy files'
  task :setup => :environment do
    cookbook.generate_deploy
    cookbook.generate_shared
  end
  
  desc 'Generates config/deploy.rb for use with cookbook'
  task :generate_deploy => :environment do
    if File.file? 'config/deploy.rb'
      puts '=> Backing up old deploy.rb...'
      FileUtils.copy 'config/deploy.rb', 'config/deploy.rb.old'
    end
    puts '=> Creating config/deploy.rb...'
    exec "cp #{File.dirname(__FILE__)}/../templates/deploy.rb #{RAILS_ROOT}/config/deploy.rb"
  end
  
  desc 'Generates config/cookbook containing deploy config files'
  task :generate_shared => :environment do
    if File.directory? 'config/cookbook'
      puts '=> Backing up old config/cookbook...'
      FileUtils.copy 'config/cookbook', 'config/cookbook.old'
    end
    puts '=> Creating config/cookbook...'
    exec "cp #{File.dirname(__FILE__)}/../templates/shared #{RAILS_ROOT}/config/cookbook"
  end
end