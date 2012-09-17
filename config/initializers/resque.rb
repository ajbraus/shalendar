require 'resque'

heroku_environments = ["staging", "production"]
rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'

unless heroku_environments.include?(rails_env)
  resque_config = YAML.load_file(rails_root + '/config/resque.yml')
  Resque.redis = resque_config[rails_env]
else
  uri = URI.parse(ENV["REDISTOGO_URL"] || "redis://localhost:6379/")
  Resque.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end