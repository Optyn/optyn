class Survey < ActiveRecord::Base
  belongs_to :shop
  has_many :survey_questions, order: "CASE WHEN survey_questions.position IS NULL THEN 999 ELSE survey_questions.position END, survey_questions.id", dependent: :destroy

  has_many :survey_answers, order: "survey_answers.created_at", :through => :survey_questions

  attr_accessible :title, :ready, :survey_answers, :shop_id

  accepts_nested_attributes_for :survey_questions, allow_destroy: true

  scope :includes_shop, includes(:shop)

  scope :for_shop_ids, ->(shop_ids){where(shop_id: shop_ids)}


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
    shop.name
  end

  def shop_description
    shop.description.blank? ? "Not Available" : shop.description
  end
end
