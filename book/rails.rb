Capistrano::Configuration.instance(:must_exist).load do

  namespace :rails do
    namespace :config do
      desc "Copies all files in cookbook/rails to shared config"
      task :default, :roles => :app do
        run "mkdir -p #{shared_path}/config"
        Dir[File.expand_path('../../../../config/cookbook/rails/*', File.dirname(__FILE__))].each do |f|
          upload_from_erb "#{shared_path}/config/#{File.basename f}", :folder => 'rails'
        end
      end
      
      desc "Copies yml files in the shared config folder into our app config"
      task :to_app, :roles => :app do
        run "cp -Rf #{shared_path}/config/* #{release_path}/config"
      end
    end
  end

end