class Manager < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :async, :registerable,
  :recoverable, :rememberable, :trackable, :validatable
  
  has_many :authentications,:as=>:account, dependent: :destroy
  has_many :children, :class_name => "Manager",:foreign_key => "parent_id"
  belongs_to :parent, :class_name => "Manager"
  belongs_to :shop
  
  validates_presence_of :shop_id, :message=>"^ Business details cant be blank"
  
  attr_accessible :name,:email, :password, :password_confirmation, :remember_me,:shop_id,:parent_id,:owner
  
  def self.from_omniauth(auth)
    Authentication.fetch_authentication(auth.provider, auth.uid,"Manager").account rescue create_from_omniauth(auth)
  end
  
  def self.create_from_omniauth(auth)
    manager = nil
    Manager.transaction do
      email = auth.info.email.to_s

      manager = Manager.find_by_email(email) || Manager.new(name: auth.info.name, email: email)
      manager.save(validate: false)

      provider = auth.provider
      uid      = auth.uid
      authentication = Authentication.fetch_authentication(provider, uid,"Manager")
      if authentication.blank?
        authentication = manager.authentications.create(uid: auth['uid'], provider: auth['provider'])
      end
    end
    manager
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

  def get_child_managers
    self.children
  end

  def get_owner
    self.parent
  end

end
