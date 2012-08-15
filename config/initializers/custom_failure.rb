class CustomFailure < Devise::FailureApp     
  def respond
    unless request.format.to_sym == :html
  		http_auth
    else
  		super
		end
  end
end