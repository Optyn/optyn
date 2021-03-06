require 'doorkeeper/plain_application_generator'

class Partner < ActiveRecord::Base
  include Doorkeeper::PlainApplicationGenerator

  has_many :shops
  has_many :managers,:through=>:shops

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :first_name, :last_name, :organization, :phone, :email, :password, :password_confirmation, :remember_me, :redirect_uri, :subscription_required, :header_background_color, :footer_background_color

  attr_accessor :redirect_uri

  has_one :oauth_application, class_name: 'Doorkeeper::Application', as: :owner, dependent: :destroy
  has_many :access_tokens,:through=>:oauth_application
  
  after_create :generate_application

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :organization, presence: true, uniqueness: true
  validates :phone , presence: true
  validate :validate_phone_digits

  scope :lower_name, ->(org) { where(["LOWER(partners.organization) LIKE LOWER(:org)", {org: org}]) }

  ORGANIZATION_OPTYN = 'Optyn Inc.'
  ORGANIZATION_EATSTREET = 'Eatstreet Inc.'

  class << self
    class_eval do
      if Partner.table_exists?
        #Adding methods optyn, optyn_id
        optyn_org = Partner.find_by_organization(ORGANIZATION_OPTYN)
        define_method(:optyn) do
          eval("@@OPTYN ||= optyn_org")
        end
        define_method(:optyn_id) do
          eval("@@OPTYN_ID ||= optyn_org.id")
        end

        #Adding methods eatstreet, eatstreet_id
        eatstreet_org = Partner.find_by_organization(ORGANIZATION_EATSTREET)
        define_method(:eatstreet) do
          eval("@@EATSTREET ||= eatstreet_org")
        end
        define_method(:eatstreet_id) do
          eval("@@EATSTREET_ID ||= eatstreet_org.id")
        end
      end  
    end
  end #end of the self block

  def self.for_organization(org)
    lower_name(org.to_s).first
  end

  def name
    "#{first_name} #{last_name}"
  end

  def optyn?
    self.id == self.class.optyn_id
  end

  def eatstreet?
    self.id == self.class.eatstreet_id
  end

  def subscription_required?
    self.subscription_required
  end

  private
  def validate_phone_digits
    self.errors.add(:phone, "invalid") if !self.errors.include?(:phone) && self.phone.to_s.gsub(/\D/, '').size != 10
  end
end
