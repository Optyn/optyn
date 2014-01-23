class Manager < ActiveRecord::Base
  include UuidFinder

  # Include default devise modules. Others available are:
  # :token_authenticatable,
  # :lockable, :timeoutable and :omniauthable

  devise :database_authenticatable, :async, :registerable,
    :recoverable, :rememberable, :trackable, :validatable

  has_many :authentications, :as => :account, dependent: :destroy
  has_many :children, :class_name => "Manager", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "Manager"
  belongs_to :shop
  has_many :file_imports
  has_many :messages

  mount_uploader :picture, ImageUploader

  validates :name, :presence => true, unless: :skip_name
  validate :check_for_used_user_email
  #validates_presence_of :shop_id, :message=>"^ Business details cant be blank"

  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :shop_id, :parent_id, :owner, :confirmed_at, :picture, :skip_email, :skip_name

  attr_accessor :skip_password, :skip_email, :skip_name

  accepts_nested_attributes_for :file_imports

  after_create :assign_uuid, :send_welcome_email
  after_save :update_stripe_customer_email

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
    shop.name rescue nil
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

  def assign_uuid
    IdentifierAssigner.assign_random(self, 'uuid')
    self.save
  end

  def send_welcome_email
    return if self.shop.virtual || self.skip_email || !(self.partner_optyn?)
    WelcomeMessageSender.perform_async(:manager, self.id)
  end

  def check_for_used_user_email
    unless self.errors.include?(:email)
      user = User.find_by_email(self.email)
      self.errors.add(:email, "already taken") if user.present?
    end
  end

  def partner_eatstreet?
    self.shop.partner_eatstreet?
  end

  def partner_optyn?
    self.shop.partner_optyn?
  end

  def error_messages
    self.errors.full_messages
  end

  def update_stripe_customer_email
    if not self.created_at_changed? #Check if an update call.
      if self.email_changed?
        subscription = Subscription.find(self.shop.subscription.id)
        if subscription.stripe_customer_token.present?
          stripe_customer = Stripe::Customer.retrieve(subscription.stripe_customer_token)
          stripe_customer.email = self.email
          stripe_customer.save
        end
      end
    end
  end

  #Gotcha:  if some one enters their <last_name> <first_name> while registering or something then the split is inappropriate
  def first_name
    name.to_s.split(/\s/).first.to_s.capitalize #to_s if the name is blank by chance
  end

  def encode64_uuid
    Base64.urlsafe_encode64(self.uuid)
  end
end

