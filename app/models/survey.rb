class Survey < ActiveRecord::Base
  belongs_to :shop
  has_many :survey_questions, order: "CASE WHEN survey_questions.position IS NULL THEN 999 ELSE survey_questions.position END, survey_questions.id", dependent: :destroy
  has_many :survey_answers, order: "survey_answers.created_at", :through => :survey_questions

  attr_accessible :title, :ready, :survey_answers, :shop_id

  accepts_nested_attributes_for :survey_questions, allow_destroy: true

  scope :includes_shop, includes(:shop)

  scope :for_shop_ids, ->(shop_ids) { where(shop_id: shop_ids) }

  scope :active, where(ready: true)


  def survey_answers_attributes=(answer_attributes)
    answer_attributes.each do |attrs|
      survey_answers.build(attrs)
    end
  end

  def dummy?
    !(title.present?)
  end

  def ready_text
    ready ? "Yes" : "No"
  end

  def shop_name 
    Shop.with_deleted.find(self.shop_id).name
  end

  def shop_description
    shop.description.blank? ? "Not Available" : shop.description
  end

  def add_canned_questions
    self.survey_questions.build(:element_type => 'radio', :label => "Have you purchased anything from #{shop_name}?", :position => 1, :values => ['Yes', 'No'])
    self.survey_questions.build(:element_type => 'radio', :label => "How often do you visit #{shop_name}?", :position => 2, :values => ['Daily', 'Weekly', 'Monthly', 'Yearly', 'Never'])
  end
end
