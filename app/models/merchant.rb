class Merchant < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :async, :registerable,
  :recoverable, :rememberable, :trackable, :validatable

  has_one :address, dependent: :destroy
  has_many :authentications,:as=>:account, dependent: :destroy
  # Setup accessible (or protected) attributes for your model
  attr_accessible :name,:email, :password, :password_confirmation, :remember_me

  def self.from_omniauth(auth)
    Authentication.fetch_authentication(auth.provider, auth.uid,"Merchant").account rescue create_from_omniauth(auth)
  end
  
  def self.create_from_omniauth(auth)
    merchant = nil
    Merchant.transaction do
      email = auth.info.email.to_s

      merchant = Merchant.find_by_email(email) || Merchant.new(name: auth.info.name, email: email)
      merchant.save(validate: false)

      provider = auth.provider
      uid      = auth.uid
      authentication = Authentication.fetch_authentication(provider, uid,"Merchant")
      if authentication.blank?
        authentication = merchant.authentications.create(uid: auth['uid'], provider: auth['provider'])
      end
    end
    merchant
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
