Capistrano::Configuration.instance(:must_exist).load do
  
  namespace :php do
    namespace :config do
      desc "Generate remote application config"
      task :default, :roles => :app do
        php.config.nginx
      end
      
      desc "Generate remote Nginx vhost"
      task :nginx, :roles => :app do
        upload_from_erb "#{nginx_dir}/vhosts/#{application}_#{stage}.conf", binding, :folder => 'php', :name => 'nginx.vhost'
      end
    end
  end
  
end