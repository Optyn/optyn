class Shop < ActiveRecord::Base
  SHOP_TYPES=['local','online']
  attr_accessible :name,:stype,:managers_attributes,:locations_attributes

  validates :name,:presence=>true
  validates :stype, :presence => true, :inclusion => { :in => SHOP_TYPES , :message => "is Invalid" }

  has_many :managers
  has_many :locations
  accepts_nested_attributes_for :managers
  accepts_nested_attributes_for :locations 



  def shop_already_exists?
    Shop.where("name LIKE ?",self.name).count != 0
  end

  def update_manager
    self.managers.first.update_attributes(:owner=>true)
  end


end
