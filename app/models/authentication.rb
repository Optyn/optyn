class Authentication < ActiveRecord::Base
	belongs_to :user

	attr_accessible :provider, :uid

	validates :provider, presence: true
	validates :uid, presence: true
	validates :user_id, presence: true

	scope :by_provider_and_uid, ->(provider, uid) {where(provider: provider, uid: uid)}

	def self.fetch_authentication(provider, uid)
		by_provider_and_uid(provider, uid).first
	end
end
