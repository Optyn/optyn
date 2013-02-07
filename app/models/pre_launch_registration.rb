require 'email_validator'

class PreLaunchRegistration < ActiveRecord::Base
	include ActiveModel::Validations

  attr_accessible :email

  validates :email, :presence => true, :email => true

  def persist
  	self.class.transaction do 
  		save
  		#TODO ADD THE LOGIC TO SEND A THANK YOU EMAIL
  	end
  end
end
