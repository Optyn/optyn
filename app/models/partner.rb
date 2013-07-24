require 'doorkeeper/plain_application_generator'

class Partner < ActiveRecord::Base
  include Doorkeeper::PlainApplicationGenerator

  has_many :shops

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :first_name, :last_name, :organization, :phone, :email, :password, :password_confirmation, :remember_me, :redirect_uri

  attr_accessor :redirect_uri

  has_one :oauth_application, class_name: 'Doorkeeper::Application', as: :owner, dependent: :destroy

  after_create :generate_application

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :organization, presence: true
  validates :phone , presence: true
  validate :validate_phone_digits


  def name
    "#{first_name} #{last_name}"
  end

  private
  def validate_phone_digits
    self.errors.add(:phone, "invalid") if !self.errors.include?(:phone) && self.phone.to_s.gsub(/\D/, '').size != 10
  end
end
