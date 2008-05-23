require 'erb'

Capistrano::Configuration.instance(:must_exist).load do
  
  # See cookbook hash in config/deploy.rb
  
  cookbook[:port] = cookbook[:ssh_port]   # Port is too ambiguous for me
  cookbook.each do |key, value|           # Merge cookbook with capistrano
    value.respond_to?(:keys) ? value.each { |k, v| set "#{key}_#{k}".intern, v } : set(key, value)
  end
  
  # Default values
  
  set :port,                fetch(:port,                22)
  set :user,                fetch(:user,                'mongrel')
  set :stage,               fetch(:stage,               :production)
  set :db_user,             fetch(:db_user,             'rails')
  set :db_pass,             fetch(:db_pass,             '')
  set :use_sudo,            fetch(:use_sudo,            false)
  set :auth_user,           fetch(:auth_user,           false)
  set :nginx_dir,           fetch(:nginx_dir,           '/etc/nginx')
  set :staging_mongrels,    fetch(:staging_mongrels,    1)
  set :production_mongrels, fetch(:production_mongrels, 2)
  
  # Git by default
  
  set :scm,                 fetch(:scm,                 :git)
  set :deploy_via,          fetch(:deploy_via,          :remote_cache)
  set :repository_cache,    fetch(:repository_cache,    'git_cache')
  
  ssh_options[:paranoid] = false

  # Events

  on :before, 'setup_stage', :except => [ :staging, :testing ]  # Executed before every task
  after 'deploy:update_code', 'config:to_app'                   # Copy shared config to app
  
end


# Helpers

def ask(question)
  question = "\n" + question.join("\n") if question.respond_to?(:uniq)
  Capistrano::CLI.ui.ask(question).strip
end

def yes(question)
  question = "\n" + question.join("\n") if question.respond_to?(:uniq)
  question += ' (y/n)'
  ask(question).downcase.include? 'y'
end

def run_and_return(cmd, sudo=false)
  output = []
  if sudo
    sudo(cmd) { |ch, st, data| output << data }
  else
    run(cmd)  { |ch, st, data| output << data }
  end
  output.join("\n")
end

def sudo_and_return(cmd)
  run_and_return cmd, true
end

def sudo_each(cmds)
  cmds.each { |cmd| sudo cmd }
end

def run_each(cmds)
  cmds.each { |cmd| run cmd }
end

def get_ssh_keys
  keys = Dir[File.expand_path('~/.ssh/*.pub')].collect do |f|
    File.open(f).collect { |line| line.strip.empty? ? nil : line.strip }.compact
  end
  keys.flatten.join("\n").strip
end

# options={}
#   :chown => user that should own destination (if different from cap user)
#   :chmod => 0644 etc

def upload_from_erb(template, destination, bind, options={})
  rendered = File.read File.expand_path("../../../config/cookbook/#{template}.erb", File.dirname(__FILE__))
  sudo "touch #{destination}"
  sudo "chown #{user} #{destination}"
  put ERB.new(rendered).result(bind || binding), destination
  sudo("chown #{options[:chown]} #{destination}") if options[:chown]
  sudo("chmod #{options[:chmod]} #{destination}") if options[:chmod]
end


# Require recipes

Dir[File.expand_path('lib/*.rb', File.dirname(__FILE__))].each { |f| require f }