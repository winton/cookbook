require 'erb'

Capistrano::Configuration.instance(:must_exist).load do

  # Install

  def gem_install(name, options='')
    sudo_puts "gem install #{name} #{options} --no-rdoc --no-ri -q"
  end
  
  def install_source(source)
    path = unpack_source source
    yield path
    sudo "rm -Rf #{path}"
  end
  
  def make_install(path)
    ";cd #{path} && ./configure && make && sudo make install"
  end

  def unpack_source(source)
    url  = eval "sources_#{source}"  # see cookbook[:sources]
    name = File.basename url
    src  = "/home/#{user}/sources"
    base = nil
    [ 'tar.gz', 'tgz' ].each do |ext|
      base = name[0..((ext.length + 2) * -1)] if name.include?(ext)
    end
    run_each [
      "mkdir -p #{src}",
      "cd #{src} && wget --quiet #{url}",
      "tar -xzvf #{src}/#{name} -C #{src}"
    ]
    "#{src}/#{base}"
  end


  # Files
  
  def add_line(file, to)
    change_line file '$', to
  end
  
  def change_line(file, from, to)
    sudo "sed 's/#{from}/#{to}/' #{file}"
  end
  
  def remove_line(file, from)
    change_line file, from, ''
  end

  def get_ssh_keys
    keys = Dir[File.expand_path('~/.ssh/*.pub')].collect do |f|
      File.open(f).collect { |line| line.strip.empty? ? nil : line.strip }.compact
    end
    keys.flatten.join("\n").strip
  end

  def upload_from_erb(destination, bind=nil, options={})
    # options[ :chown  => owner of file (default: deploy user),
    #          :chmod  => 0644 etc
    #          :folder => 'postfix' etc,
    #          :name   => name of template if differs from destination ]
    if destination.respond_to?(:uniq)
      destination.each { |d| upload_from_erb d, bind, options }
    else
      template = File.basename destination
      template = template[1..-1] if template[0..0] == '.'
      folder   = options[:folder] ? options[:folder] + '/' : ''
      template = File.expand_path("templates/#{folder}#{options[:name]||template}.erb", File.dirname(__FILE__))
      template = File.read template
      sudo "touch #{destination}"
      sudo "chown #{user} #{destination}"
      put ERB.new(template).result(bind || binding), destination
      sudo("chown #{options[:chown]} #{destination}") if options[:chown]
      sudo("chmod #{options[:chmod]} #{destination}") if options[:chmod]
    end
  end


  # MySQL

  def mysql_run(sql)
    if sql.respond_to?(:uniq)
      sql.each { |s| mysql_run s }
    else
      run "echo \"#{sql}\" | #{mysql_call}"
    end
  end

  def mysql_call
    @mysql_root_password = @mysql_root_password || ask("Password for mysql root:")
    "mysql -u root --password=#{@mysql_root_password}"
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

  def run_each(*args, &block)
    cmd  = args[0]
    sudo = args[1]
    if cmd.respond_to?(:uniq)
      cmd.each  { |c| run_each c, sudo, &block }
    elsif sudo
      sudo(cmd) { |ch, st, data| block.call(data) if block }
    else
      run(cmd)  { |ch, st, data| block.call(data) if block }
    end
  end

  def sudo_each(cmds, &block)
    run_each cmds, true, &block
  end

  def run_puts(cmds, &block)
    run_each(cmds) { |data| puts data }
  end

  def sudo_puts(cmds, &block)
    sudo_each(cmds) { |data| puts data }
  end


  # Messages

  def msg(type)
    case type
    when :about_templates
      <<-eos
You will often see URLs to templates I am using to set up your server.

To use your own templates:
  Create a directory called "cookbook" in the same directory as deploy.rb.
  I will use your copy if you have a template file with the same name.
eos

    when :visudo
      <<-eos
Please run the following commands:
  ssh root@#{host}:#{port}
  adduser #{user}
  visudo

Add this line to the bottom:
  #{user} ALL=NOPASSWD: ALL
eos

    when :aptitude_default
      <<-eos
Please run these manually:
  sudo aptitude update
  sudo aptitude upgrade
  sudo aptitude build-essential
eos

    when :iptables
      <<-eos
This task updates your server's iptables, limiting access to SSH, HTTP, HTTPS, and ping only.
See http://github.com/winton/cookbook/tree/master/templates/ubuntu/iptables.rules.erb
OK?
eos

    when :sshd_config
      <<-eos
This task updates your server's sshd_config with the following settings:
  Port #{ssh_port}
  PermitRootLogin no
  X11Forwarding no
  UsePAM no
  UseDNS no
OK?
eos

    when :secure_mysql
      <<-eos
It is highly recommended you run mysql_secure_installation manually.
See http://dev.mysql.com/doc/refman/5.1/en/mysql-secure-installation.html
eos
    end
  end
  
end