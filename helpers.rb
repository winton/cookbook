require 'erb'


# Files

def get_ssh_keys
  keys = Dir[File.expand_path('~/.ssh/*.pub')].collect do |f|
    File.open(f).collect { |line| line.strip.empty? ? nil : line.strip }.compact
  end
  keys.flatten.join("\n").strip
end

def upload_from_erb(destination, bind, options={}) # options[ :chown => owner of file (default: deploy user),
  template = File.basename destination             #          :chmod => 0644 etc]
  template = File.expand_path("../../../config/cookbook/#{destination}.erb", File.dirname(__FILE__))
  template = File.read template
  sudo "touch #{destination}"
  sudo "chown #{user} #{destination}"
  put ERB.new(template).result(bind || binding), destination
  sudo("chown #{options[:chown]} #{destination}") if options[:chown]
  sudo("chmod #{options[:chmod]} #{destination}") if options[:chmod]
end


# Questions

def ask(question, default='')
  question = "\n" + question.join("\n") if question.respond_to?(:uniq)
  answer = Capistrano::CLI.ui.ask(question).strip
  answer.empty? ? default : answer
end

def yes(question)
  question = "\n" + question.join("\n") if question.respond_to?(:uniq)
  question += ' (y/n)'
  ask(question).downcase.include? 'y'
end


# Runners

def run_and_return(cmd, sudo=false)
  output = []
  if cmd.respond_to?(:uniq)
    output = cmd.collect { |c| run_and_return c, sudo }
  elsif sudo
    sudo(cmd) { |ch, st, data| output << data }
  else
    run(cmd)  { |ch, st, data| output << data }
  end
  output.join("\n")
end

def sudo_and_return(cmd)
  run_and_return cmd, true
end

def run_and_puts(cmd, sudo=false)
  puts "\n" + run_and_return(cmd, sudo) + "\n"
end

def sudo_and_puts(cmd)
  run_and_puts cmd, true
end

def sudo_each(cmds)
  cmds.each { |cmd| sudo cmd }
end

def run_each(cmds)
  cmds.each { |cmd| run cmd }
end