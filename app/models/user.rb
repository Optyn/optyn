require 'digest/sha1'
class User < ActiveRecord::Base
	has_many :authentications,:as => :account, dependent: :destroy
  has_many :connections, class_name: "Connection", dependent: :destroy
  has_many :shops, through: :connections
  has_many :interests, :as => :holder
  has_many :businesses, :through => :interests
  has_many :user_labels, dependent: :destroy
  has_many :permissions_users, dependent: :destroy
  has_many :permissions , :through => :permissions_users
  
  mount_uploader :picture, ImageUploader
  
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :async, :registerable,
  :recoverable, :rememberable, :trackable, :validatable

  validates :name ,:presence => true

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation,
  :remember_me,:office_zip_code, :home_zip_code, :gender, :birth_date, :business_ids, :permissions_users_attributes, :picture, :oauth_image

  accepts_nested_attributes_for :permissions_users

  #accepts_nested_attributes_for :permission
  after_create :update_zip_prompted, :create_permission_users

  PER_PAGE = 30

  def self.import(file,shop)
    invalid_records = []
    index = 0
    CSV.foreach(file, headers: true) do |row|
      password_length = 8
      user_password = Devise.friendly_token.first(password_length)
      new_user = User.new row.to_hash.merge({password: user_password,  password_confirmation: user_password })
      if new_user.save
        new_connection = new_user.connections.create(shop_id: shop.id ) if new_user.present?
        new_user.permissions_users.create(action: "true", permission_id: "1") if new_user.present?        
        new_user.permissions_users.create(action: "true", permission_id: "2") if new_user.present?        
        MerchantMailer.user_account_created_notifier(new_user,user_password).deliver if new_connection.present?
      else
         invalid_records <<{:index=>index,:csv_row=>row.to_hash,:error=>new_user.errors.full_messages.join(",")}
      end

      index = index+1    
    end
    # Return an array of invalid records and total no of record
    [invalid_records,index]
  end

  def self.from_omniauth(auth)
  	Authentication.fetch_authentication(auth.provider, auth.uid,"User").account rescue create_from_omniauth(auth)
  end
  

  def self.create_from_omniauth(auth)
    user = nil
    User.transaction do
      email = auth.info.email.to_s
      user = User.find_by_email(email) || User.new(name: auth.info.name, email: email, oauth_image: auth.info.image)
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

  def active_connections(page_number=1, per_page=PER_PAGE)
    connections.active.includes_business_and_locations.ordered_by_shop_name.page(page_number).per(per_page)
  end

  def active_shop_ids
    connections.active.collect(&:shop_id)
  end

  def zip_prompted?
    zip_prompted
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

  def update_zip_prompted(force=false)
    if home_zip_code.present? || office_zip_code.present? || force
      self.zip_prompted = true
      save!(validate: false)
    end
  end

  def create_permission_users
    Permission.all.each do |permission|
      PermissionsUser.create(user_id: self.id, permission_id: permission.id, action: true)
    end
  end

  def create_or_update_zips(attrs={})
    assign_office_zip_code(attrs)
    assign_home_zip_code(attrs)
    if self.errors.has_key?(:home_zip_code) || self.errors.has_key?(:home_zip_code)
      false
    else
      zip_prompted = true
      save(:validate => false)
    end
  end

  def make_connection_if!(shop)
    unless connections.for_shop(shop.id).present?
      connections.create!(user_id: self.id, shop_id: shop.id, connected_via: 'Optyn Button')
    end
  end

  def unanswered_surveys
    connection_shop_ids = connections.active.collect(&:shop_id)
    survey_shop_ids = SurveyAnswer.uniq_shop_ids(self.id)
    Survey.for_shop_ids(connection_shop_ids - survey_shop_ids).includes_shop
  end

  def adjust_labels(label_ids)
    existing_label_ids = self.user_labels.collect(&:label_id)

    destruction_values = existing_label_ids - label_ids
    new_values = label_ids - existing_label_ids

    UserLabel.transaction do
      self.user_labels.find_all_by_label_id(destruction_values).each{|user_label| user_label.destroy}
      new_values.each do |label_id|
        self.user_labels.create(label_id: label_id)
      end
    end
  end

  def build_permission_users
    Permission.scoped.map do |permission|
      permissions_users.new(:permission_id => permission.id) 
    end  
  end

  def visible_permissions_users
    permissions_users.visible
  end

  def permission_names
    permissions_users.visible.includes(:permission).collect(&:permission).collect(&:name)
  end

  def image_url
    if !picture.blank?
      picture
    else
      oauth_image
    end
  end

  private
  def assign_office_zip_code(attrs)
    assign_zip_code(:office_zip_code, attrs)
  end

  def assign_home_zip_code(attrs)
    assign_zip_code(:home_zip_code, attrs)    
  end

  def assign_zip_code(attr, attrs)
    if attrs[attr].present? 
      code = attrs[attr].strip
      if code.length == 5
        self.send((attr.to_s + "=").to_sym, code)   
      else
        self.errors.add(attr, "invalid")
      end
    end
  end
end
