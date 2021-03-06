class Authentication < ActiveRecord::Base

	ACCOUNT_TYPES = ['User','Manager']
	
	belongs_to :user
  belongs_to :account, :polymorphic => true

	attr_accessible :provider, :uid, :account_id, :account_type, :image_url

	validates :provider, presence: true
	validates :uid, presence: true, :uniqueness => { :scope => :account_type }
  validates :account_id, presence: true
  validates :account_type, presence: true
  
	scope :by_provider_and_uid, ->(provider, uid,account_type=nil) {where(provider: provider, uid: uid,account_type: account_type)}

	def self.fetch_authentication(provider, uid, account_type=nil)
		by_provider_and_uid(provider, uid,account_type).first
	end

end
