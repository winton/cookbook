Gem::Specification.new do |s|
  s.name = 'cookbook'
  s.version = '1.0.0'
  s.date = '2008-08-16'
  
  s.summary     = "Turns a fresh Debian server into an autonomous Nginx/Rails/PHP stack using purely Capistrano"
  s.description = "Turns a fresh Debian server into an autonomous Nginx/Rails/PHP stack using purely Capistrano"
  
  s.author = 'Winton Welsh'
  s.email = 'mail@wintoni.us'
  s.homepage = 'http://github.com/winton/cookbook'
  
  s.has_rdoc = false
  
  s.files = %w(
    config/**/*
    cookbook.rb
    cookbook_helpers.rb
    deploy.rb.example
    MIT-LICENSE
    README.markdown
    recipes/*)
end