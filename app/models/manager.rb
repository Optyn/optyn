class Manager < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable,
  # :lockable, :timeoutable and :omniauthable

  devise :database_authenticatable, :async, :registerable,
  :recoverable, :rememberable, :trackable, :validatable,:confirmable
  
  has_many :authentications,:as=>:account, dependent: :destroy
  has_many :children, :class_name => "Manager",:foreign_key => "parent_id"
  belongs_to :parent, :class_name => "Manager"
  belongs_to :shop
  
  validates :name, :presence => true
  #validates_presence_of :shop_id, :message=>"^ Business details cant be blank"
  
  attr_accessible :name,:email, :password, :password_confirmation, :remember_me,:shop_id,:parent_id,:owner,:confirmed_at
  

  def self.from_omniauth(auth)
    Authentication.fetch_authentication(auth.provider, auth.uid,"Manager").account rescue create_from_omniauth(auth)
  end
  
  def self.create_from_omniauth(auth)

    email = auth.info.email.to_s
    manager = Manager.find_by_email(email) 

    if !manager
      manager = Manager.new(name: auth.info.name, email: email) 
      manager
    else
      authentication = manager.authentications.create(uid: auth['uid'], provider: auth['provider'])
      manager
    end
    
  end

  def create_authentication(uid,provider)
    self.authentications.create(uid: uid, provider: provider)
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

  def business_name
    shop.name
  end

  def first_shop
    shop.first_location
  end

  def email_like_from
    %Q("#{name} <#{email}>")
  end
end
