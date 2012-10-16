class Vendor < User
	has_many :suggestions

	#validates presence of credit card data

  has_attached_file :avatar, :styles => { :original => "150x150#",
                                        :raster => "50x50#" },
                           :convert_options => { :raster => '-quality 40' },
                           :storage => :s3,
                           :s3_credentials => S3_CREDENTIALS,
                           :path => "vendor/:attachment/:style/:id.:extension",
                           :default_url => "https://s3.amazonaws.com/hoosin-production/user/avatars/original/default_profile_pic.png"

end