class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
 
  def all
    # Calling The Omniauth API for Multi provider [Facebook, twitter, linkedin, Google, Github]
    user = User.from_omniauth(request.env["omniauth.auth"])
    if user.persisted? # Save User Information from API Response.
      flash.notice = I18n.t "devise.omniauth_callbacks.success", :kind => user.provider.titleize
      sign_in_and_redirect user, :event => :authentication  #Successful Redirect to Sign IN Page
    else
      session["devise.user_attributes"] = user.attributes  # Use for twitter for Store User's Email.
      if user.provider == 'twitter'
        redirect_to new_user_registration_url, :notice=>'Your Authorized from Twitter. Provide your Email so further communication made.'
      else
        redirect_to new_user_registration_url
      end
    end 
  end
  alias_method :twitter,  :all
  alias_method :linkedin, :all
  alias_method :facebook, :all
end
