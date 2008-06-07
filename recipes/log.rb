Capistrano::Configuration.instance(:must_exist).load do
 
  namespace :log do
    namespace :tail do
      desc "Tail all remote logs"
      task :default, :roles => :app do
        log.tail.nginx
        puts '='*100
        log.tail.mongrel
        puts '='*100
        log.tail.production
      end
      
      desc "Tail the remote Nginx log"
      task :nginx, :roles => :app do
        run_puts "tail -100 #{shared_path}/log/nginx.log"
      end
      
      desc "Tail the remote Mongrel log"
      task :mongrel, :roles => :app do
        run_puts "tail -100 #{shared_path}/log/mongrel*.log"
      end
      
      desc "Tail the remote Rails production log"
      task :production, :roles => :app do
        run_puts "tail -100 #{shared_path}/log/production.log"
      end
    end
  end
  
end