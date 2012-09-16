require 'resque/plugins/resque_heroku_autoscaler'

Resque::Plugins::HerokuAutoscaler.config do |c|
  c.heroku_user = 'msfenchel@gmail.com'
  c.heroku_pass = ENV['HEROKU_PASSWORD']
  c.heroku_app  = ENV['HEROKU_APP']

  if Rails.env.production?
    c.new_worker_count do |pending|
      (pending/5).ceil.to_i
    end
  end

  if Rails.env.development?
    c.scaling_disabled = true
  end
end