class AuthenticationsController < ApplicationController
  # GET /authentications
  # GET /authentications.json
def index
  # get all authentication authentications assigned to the current user
  @authentications = current_user.authentications.all
end

def destroy
  # remove an authentication authentications linked to the current user
  @authentications = current_user.authentications.find(params[:id])
  @authentications.destroy
  
  redirect_to authentications_path
end

def create
    # get the authentications parameter from the Rails router
    params[:authentications] ? authentication_route = params[:authentications] : authentication_route = 'no authentications (invalid callback)'

    # get the full hash from omniauth
    omniauth = request.env['omniauth.auth']

    # continue only if hash and parameter exist
    if omniauth and params[:authentications]
      
      # map the returned hashes to our variables first - the hashes differ for every authentications
      if authentication_route == 'facebook'
        omniauth['extra']['user_hash']['email'] ? email =  omniauth['extra']['user_hash']['email'] : email = ''
        omniauth['extra']['user_hash']['name'] ? name =  omniauth['extra']['user_hash']['name'] : name = ''
        omniauth['extra']['user_hash']['id'] ?  uid =  omniauth['extra']['user_hash']['id'] : uid = ''
        omniauth['provider'] ? provider =  omniauth['provider'] : provider = ''
      elsif authentication_route == 'twitter'
        email = ''    # Twitter API never returns the email address
        omniauth['user_info']['name'] ? name =  omniauth['user_info']['name'] : name = ''
        omniauth['uid'] ?  uid =  omniauth['uid'] : uid = ''
        omniauth['provider'] ? provider =  omniauth['provider'] : provider = ''
      else
        # we have an unrecognized authentications, just output the hash that has been returned
        render :text => omniauth.to_yaml
        #render :text => uid.to_s + " - " + name + " - " + email + " - " + provider
        return
      end
    
      # continue only if provider and uid exist
      if uid != '' and provider != ''
          
        # nobody can sign in twice, nobody can sign up while being signed in (this saves a lot of trouble)
        if !user_signed_in?
          
          # check if user has already signed in using this authentications provider and continue with sign in process if yes
          auth = Authentication.find_by_provider_and_uid(provider, uid)
          if auth
            flash[:notice] = 'Signed in successfully via ' + provider.capitalize + '.'
            sign_in_and_redirect(:user, auth.user)
          else
            # check if this user is already registered with this email address; get out if no email has been provided
            if email != ''
              # search for a user with this email address
              existinguser = User.find_by_email(email)
              if existinguser
                # map this new login method via a authentications provider to an existing account if the email address is the same
                existinguser.authentications.create(:provider => provider, :uid => uid, :username => name, :useremail => email)
                flash[:notice] = 'Sign in via ' + provider.capitalize + ' has been added to your account ' + existinguser.email + '. Signed in successfully!'
                sign_in_and_redirect(:user, existinguser)
              else
                # let's create a new user: register this user and add this authentication method for this user
                name = name[0, 39] if name.length > 39             # otherwise our user validation will hit us

                # new user, set email, a random password and take the name from the authentication authentications
                user = User.new :email => email, :password => SecureRandom.hex(10), :fullname => name

                # add this authentication authentications to our new user
                user.authentications.build(:provider => provider, :uid => uid, :username => name, :uemail => email)

                # do not send confirmation email, we directly save and confirm the new record
                user.skip_confirmation!
                user.save!
                user.confirm!

                # flash and sign in
                flash[:myinfo] = 'Your account on Calenshare has been created via ' + provider.capitalize + '. In your profile you can change your personal information and add a local password.'
                sign_in_and_redirect(:user, user)
              end
            else
              flash[:error] =  authentication_route.capitalize + ' can not be used to sign-up on Calenshare as no valid email address has been provided. Please use another authentication provider or use local sign-up. If you already have an account, please sign-in and add ' + authentication_route.capitalize + ' from your profile.'
              redirect_to new_user_session_path
            end
          end
        else
          # the user is currently signed in
          
          # check if this authentications is already linked to his/her account, if not, add it
          auth = Authentication.find_by_provider_and_uid(provider, uid)
          if !auth
            current_user.authentications.create(:provider => provider, :uid => uid, :username => name, :useremail => email)
            flash[:notice] = 'Sign in via ' + provider.capitalize + ' has been added to your account.'
            redirect_to authentications_path
          else
            flash[:notice] = authentication_route.capitalize + ' is already linked to your account.'
            redirect_to authentications_path
          end  
        end  
      else
        flash[:error] =  authentication_route.capitalize + ' returned invalid data for the user id.'
        redirect_to new_user_session_path
      end
    else
      flash[:error] = 'Error while authenticating via ' + authentication_route.capitalize + '.'
      redirect_to new_user_session_path
    end
  end 
end
