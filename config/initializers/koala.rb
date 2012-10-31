# Monkey-patch in Facebook config so Koala knows to 
# automatically use Facebook settings from here if none are given

module Facebook
  CONFIG = YAML.load_file(Rails.root.join("config/facebook.yml"))[Rails.env]
  APP_ID = CONFIG['app_id']
  SECRET = CONFIG['secret_key']
end

Koala::Facebook::OAuth.class_eval do
  def initialize_with_default_settings(*args)
    case args.size
      when 0, 1
        raise "application id and/or secret are not specified in the config" unless Facebook::APP_ID && Facebook::SECRET
        initialize_without_default_settings(Facebook::APP_ID.to_s, Facebook::SECRET.to_s, args.first)
      when 2, 3
        initialize_without_default_settings(*args) 
    end
  end 

  alias_method_chain :initialize, :default_settings 
end

Koala::Facebook::API::GraphCollection.module_eval do
  class << self
    def parse_page_url_with_unescaped_url(url)
      parse_page_url_without_unescaped_url(url.gsub('|', URI.escape('|')))
    end
    alias_method_chain :parse_page_url, :unescaped_url
  end
end