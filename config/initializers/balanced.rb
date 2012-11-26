require 'balanced'

if Rails.env == "production" 
   Balanced.configure( ENV['BALANCE_KEY'], :connection_timeout => 30, :read_timeout => 30 )
 else 
   Balanced.configure('2141737c2ddd11e2afa1026ba7cac9da', :connection_timeout => 30, :read_timeout => 30) 
end