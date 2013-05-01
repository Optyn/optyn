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
  has_many :file_imports

  mount_uploader :picture, ImageUploader

  validates :name, :presence => true
  #validates_presence_of :shop_id, :message=>"^ Business details cant be blank"

  attr_accessible :name,:email, :password, :password_confirmation, :remember_me,:shop_id,:parent_id,:owner,:confirmed_at, :picture, :oauth_image
  attr_accessor :skip_password
  accepts_nested_attributes_for :file_imports

  def self.create_from_omniauth(auth)
    email = auth.info.email.to_s
    manager = Manager.find_by_email(email)

    if !manager
      manager = Manager.new(name: auth.info.name, email: email, oauth_image: auth.info.image)
      manager
    else
      authentication = manager.authentications.create(uid: auth['uid'], provider: auth['provider'])
      manager
    end
  end

  def create_authentication(uid, provider)
    self.authentications.create(uid: uid, provider: provider)
  end

  def password_required?
    return false if skip_password.present? && skip_password

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

  def image_url
    if !picture.blank?
      picture
    elsif !oauth_image.blank?
      oauth_image
    else
      "/assets/avatar.png"
    end
  end

end

