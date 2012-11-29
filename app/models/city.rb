class City < ActiveRecord::Base
  attr_accessible :name, :timezone, :icon

  has_many :users
  has_many :events
  
  has_attached_file :icon, :styles => { :original => '380x520',
                                        :icon => '50x50#'},
                             :storage => :s3,
                             :s3_credentials => S3_CREDENTIALS,
                             :path => "city/:attachment/:style/:id.:extension"
                             #:default_url => "https://s3.amazonaws.com/hoosin-production/event/icon/medium/default_promo_img.png"

  validates :icon,   # :attachment_presence => true,
                     :attachment_content_type => { :content_type => [ 'image/png', 'image/jpg', 'image/gif', 'image/jpeg' ] }
                     # :attachment_size => { :in => 0..500.kilobytes }

  # add paperclip attachment from CLI
  # http://stackoverflow.com/questions/1397461/how-to-set-file-programmatically-using-paperclip
  # my_model_instance = MyModel.new
	# my_model_instance.attachment = File.open(file_path)
	# my_model_instance.save!
end
