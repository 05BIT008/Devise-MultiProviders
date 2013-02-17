class User < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,:confirmable,
         :recoverable, :rememberable, :trackable, :validatable , :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me ,:twitter_uid ,:twitter_confirmation_token,
                  :linkedin_uid ,:linkedin_confirmation_token


#--- Devise with Omniauth follow below -----------------
# https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview
# for facebook followed https://github.com/mkdynamic/omniauth-facebook

  def self.from_omniauth(auth)  #For All Provider Common Method
    where(auth.slice(:provider, :uid)).first_or_create do |user|  #Find or Create User
      user.provider = auth.provider
      user.uid = auth.uid
      user.user_name = auth.info.nickname
      if auth.provider == "twitter"  # twitter do not return First & Last name it return only Name.
        name = auth.info.name.split
        user.first_name = name[0]
        user.last_name = name[1]
      else
        user.email = auth.info.email  #we get email from Facebook & Linkedin API response.
        user.first_name = auth.info.first_name
        user.last_name = auth.info.last_name
      end
    end
  end

  def self.new_with_session(params, session)
    if session["devise.user_attributes"]
      new(session["devise.user_attributes"], without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end

  def password_required? # Define for Omniauth, Initially Password is Blank.
    super && provider.blank?
  end

  def update_with_password(params, *options)  # Define for Change Password.
    if encrypted_password.blank?
      update_attributes(params, *options)
    else
      super
    end
  end

end
