class User < ActiveRecord::Base
	has_many :authentications,:as=>:account, dependent: :destroy

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :async, :registerable,
  :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me

  def self.from_omniauth(auth)
  	Authentication.fetch_authentication(auth.provider, auth.uid,"User").account rescue create_from_omniauth(auth)
  end
  
  def self.create_from_omniauth(auth)
  	user = nil
  	User.transaction do
  		email = auth.info.email.to_s

  		user = User.find_by_email(email) || User.new(name: auth.info.name, email: email)
  		user.save(validate: false)

  		provider = auth.provider
  		uid      = auth.uid
  		authentication = Authentication.fetch_authentication(provider, uid,"User")
  		if authentication.blank?
  			authentication = user.authentications.new(uid: auth['uid'], provider: auth['provider'])
  		end
  	end

  	user
  end

  def password_required?
  	super && authentications.blank?
  end

  def update_with_password(params, *options)
  	if encrypted_password.blank?
  		update_attributes(params, *options)
  	else
  		super
  	end
  end

end
