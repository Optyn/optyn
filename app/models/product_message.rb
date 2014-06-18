class ProductMessage < Message
  attr_accessible :special_try, :content

  validates :content, presence: true, on: :update
end