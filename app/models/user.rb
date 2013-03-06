class User < ActiveRecord::Base
	has_many :authentications,:as => :account, dependent: :destroy
  has_many :connections, class_name: "Connection", dependent: :destroy
  has_many :shops, through: :connections

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :async, :registerable,
  :recoverable, :rememberable, :trackable, :validatable

  validates :name ,:presence => true
  validates_presence_of :home_zip_code,:message=>"Please enter atleast one zip code", :if => lambda{ |user| user.office_zip_code.blank? }
  validates_presence_of :office_zip_code, :presence => true, :if => lambda{ |user| user.home_zip_code.blank? && !user.errors.has_key?(:home_zip_code) }
  validates :office_zip_code, :length => { :minimum => 5,:maximum => 5,:message=>"invalid" }, :format => { :with => /^\d+$/ , } , :if => lambda{|user| !user.office_zip_code.blank? }
  validates :home_zip_code, :length => { :minimum => 5,:maximum  => 5,:message=>"invalid" }, :format => { :with => /^\d+$/} , :if => lambda{|user| !user.home_zip_code.blank? }


  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation,
  :remember_me,:office_zip_code, :home_zip_code


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
      connections.create!(user_id: self.id, shop_id: shop.id)
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
