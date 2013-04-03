class GeneralMessage < Message
  attr_accessible :content

  validates :content, presence: true
end