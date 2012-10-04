if Rails.env == "production" 
   #S3_CREDENTIALS = { :access_key_id => ENV['S3_KEY'], :secret_access_key => ENV['S3_SECRET'], :bucket => ENV['S3_BUCKET_NAME']} 
 	 S3_CREDENTIALS = { :access_key_id => ENV['AWS_ACCESS_KEY_ID'], :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'], :bucket => "hoosin-production"} 
 else 
   S3_CREDENTIALS = Rails.root.join("config/s3.yml")
end