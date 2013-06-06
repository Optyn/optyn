require 'surveys/question_field_type'

class SurveyQuestion < ActiveRecord::Base
	belongs_to :survey
	has_many :survey_answers, dependent: :destroy 
	
  attr_accessible :survey_id,  :element_type, :label, :values, :default_text, :show_label, :required, :position
  serialize :values, Array

  validates :label, presence: true
  validates :element_type, presence: true

  ELEMENT_TYPES = ["radio", "select", "checkbox", "text", "textarea"]

  # after_save :sanitize_value, :clear_default_values, :clear_values_for_text

  def markup(render_options = {})
    label_attr = label.slice(0, 10).gsub(/[^A-Za-z]/,'_').underscore
    render_options = {
      :name => label_attr,
      :id => label_attr + '_' + id.to_s,
      :value => values,
      :default_text => default_text,
      :required => required
    }.merge(render_options)
    "Surveys::QuestionFieldType::#{element_type.classify}".constantize.generate_markup(render_options)
  end

  def text?
    ["textarea", "text"].include?(element_type)
  end

  def poll_answer_element_attributes=(question_element_attributes)
    question_element_attributes.each do |attrs|
      question_elem = poll_question_elements.detect{|question_elem| question_elem.id == attrs['poll_question_element_id'].to_i}
      poll_answer_elements.build(attrs)
    end
  end
end
