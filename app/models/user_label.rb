class UserLabel < ActiveRecord::Base
  belongs_to :user
  belongs_to :label

  attr_accessible :user_id, :label_id

  scope :for_label_ids, ->(label_ids){where(label_id: label_ids)}

  scope :pluck_user_id, pluck(:user_id)

  scope :active_labels, joins(:label).where("labels.active = true")

  def self.fetch_user_count(label_ids)
    for_label_ids(label_ids).collect(&:user_id).uniq.size
  end
end
