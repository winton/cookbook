Capistrano::Configuration.instance(:must_exist).load do
 
  namespace :log do
    namespace :tail do
      desc "Tail the Rails production log for this environment"
      task :production, :roles => :app do
        run_puts "tail -500 #{shared_path}/log/production.log"
      end
      
      desc "Tail the Mongrel logs this environment"
      task :mongrel, :roles => :app do
        run_puts "tail -500 #{shared_path}/log/mongrel*.log"
      end
    end
  end
  
end