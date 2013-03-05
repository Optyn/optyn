class Shop < ActiveRecord::Base

  
  SHOP_TYPES=['local','online']
  attr_accessible :name,:stype,:managers_attributes,:locations_attributes

  validates :name,:presence=>true
  validates :stype, :presence => true, :inclusion => { :in => SHOP_TYPES , :message => "is Invalid" }

  has_one :subscription, dependent: :destroy
  has_many :managers, dependent: :destroy
  has_many :locations, dependent: :destroy
  has_one :oauth_application, class_name: 'Doorkeeper::Application', as: :owner, dependent: :destroy

  accepts_nested_attributes_for :managers
  accepts_nested_attributes_for :locations 


  def shop_already_exists?
    Shop.where("name LIKE ?",self.name).count != 0
  end

  def update_manager
    self.managers.first.update_attributes(:owner=>true)
  end

  def get_shop_owner
    self.managers.where(:owner => true).first
  end

  def is_subscription_active?
    is_online? || (is_local? && self.subscription && self.subscription.active?)
  end

  def is_local?
    self.stype == 'local'
  end

  def is_online?
    self.stype == 'online'
  end

  def first_location_zip
    first_location.zip rescue ""
  end

  def generate_oauth_token(redirect_uri, force=false)
    app = nil
    if force 
      oauth_application.destroy
      reload
    end
    
    app = self.oauth_application
    if app.present?
      app.redirect_uri = redirect_uri
      debugger
      app.save
    else
      generate_application(redirect_uri)
    end
  end

  private
  def generate_application(redirect_uri)
    app = Doorkeeper::Application.new(:name => self.name + self.first_location_zip, 
      :redirect_uri => redirect_uri)
    app.owner = self
    app.save
  end

  def first_location
    locations.first rescue ""
  end
end
