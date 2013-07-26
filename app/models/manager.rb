class Manager < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable,
  # :lockable, :timeoutable and :omniauthable

  devise :database_authenticatable, :async, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  has_many :authentications,:as=>:account, dependent: :destroy
  has_many :children, :class_name => "Manager",:foreign_key => "parent_id"
  belongs_to :parent, :class_name => "Manager"
  belongs_to :shop
  has_many :file_imports
  has_many :messages

  mount_uploader :picture, ImageUploader

  validates :name, :presence => true
  validate :check_for_used_user_email
  #validates_presence_of :shop_id, :message=>"^ Business details cant be blank"

  attr_accessible :name,:email, :password, :password_confirmation, :remember_me,:shop_id,:parent_id,:owner,:confirmed_at, :picture
  attr_accessor :skip_password
  accepts_nested_attributes_for :file_imports

  after_create :send_welcome_email

  scope :owner, where(owner: true)

  def self.create_from_omniauth(auth)
    authentication = Authentication.fetch_authentication(auth.provider, auth.uid, "Manager")
    manager = authentication.account rescue Manager.find_by_email(auth.info.email)

    unless manager.present?
      manager = Manager.new(name: auth.info.name, email: auth.info.email)
      manager
    else

      if authentication.blank?
        authentication = manager.authentications.create(uid: auth['uid'], provider: auth['provider'])
      end
      authentication.image_url = auth.info.image
      authentication.save

      [manager, authentication]
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

  def image_url(omniauth_provider_id=nil)
    if !picture.blank?
      picture
    elsif (authentication = authentications.find_by_id(omniauth_provider_id)).present?
      url = authentication.image_url
      url.blank? ? "/assets/avatar.png" : url
    else
      "/assets/avatar.png"
    end
  end

  def send_welcome_email
    Resque.enqueue(WelcomeMessageSender, :manager, self.id) unless self.shop.virtual
  end

  def check_for_used_user_email
    unless self.errors.include?(:email)
      user = User.find_by_email(self.email)
      self.errors.add(:email, "already taken") if user.present?
    end
  end
end

