desc 'Set the target stage to staging'
task :staging do
  set :stage, :staging
end

desc 'Set the target stage to test'
task :testing do
  set :stage, :test
end