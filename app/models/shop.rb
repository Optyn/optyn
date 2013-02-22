class Shop < ActiveRecord::Base
  SHOP_TYPES=['local','online']
  attr_accessible :name,:stype,:managers_attributes

  validates :name,:presence=>true
  validates :stype, :presence => true, :inclusion => { :in => SHOP_TYPES , :message => "is Invalid" }

  has_many :managers
  accepts_nested_attributes_for :managers

  has_many :locations

  def self.shop_already_exists?(shop_name)
    Shop.where("name LIKE ?",shop_name).count != 0
  end
  
  def self.create_shop(params)
    Shop.create(:name=>params[:name],:stype=>params[:stype])
  end
end
