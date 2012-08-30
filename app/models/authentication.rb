class Authentication < ActiveRecord::Base
  belongs_to :user
  attr_accessible :useremail, :username, :provider, :uid, :token, :secret, :link, :name

  validates_uniqueness_of :uid
end
