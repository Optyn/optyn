class Interest < ActiveRecord::Base
  attr_accessible :business_id, :holder_type, :holder_id
  belongs_to :holder, :polymorphic => true
  belongs_to :business

end
