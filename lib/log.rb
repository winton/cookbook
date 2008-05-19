Capistrano::Configuration.instance(:must_exist).load do
 
  namespace :log do
    namespace :tail do
      desc "Tail the Rails production log for this environment"
      task :production, :roles => :app do
        run "tail -f #{shared_path}/log/#{stage}.log" do |channel, stream, data|
          puts # for an extra line break before the host name
          puts "#{channel[:server]} -> #{data}"
          break if stream == :err
        end
      end
      
      desc "Tail the Mongrel logs this environment"
      task :mongrel, :roles => :app do
        run "tail -f #{shared_path}/log/mongrel*.log" do |channel, stream, data|
          puts # for an extra line break before the host name
          puts "#{channel[:server]} -> #{data}"
          break if stream == :err
        end
      end
    end
  end
  
end