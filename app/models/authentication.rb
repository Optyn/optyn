class Authentication < ActiveRecord::Base
	belongs_to :user
  ACCOUNT_TYPES = ['User','Merchant']
  belongs_to :account, :polymorphic => true

	attr_accessible :provider, :uid, :account_id ,:account_type

	validates :provider, presence: true
	validates :uid, presence: true, :uniqueness => { :scope => :account_type }
  
	scope :by_provider_and_uid, ->(provider, uid,account_type=nil) {where(provider: provider, uid: uid,account_type: account_type)}

	def self.fetch_authentication(provider, uid,account_type=nil)
		by_provider_and_uid(provider, uid,account_type).first
	end
end
