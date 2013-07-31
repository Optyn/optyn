module UuidFinder
  def self.included(base)
    base.class_eval do
      scope :by_uuid, ->(uuid) { where(uuid: uuid) }
    end

    base.extend(ClassMethods)
  end

  module ClassMethods
    def for_uuid(uuid)
      by_uuid(uuid).first || (raise ActiveRecord::RecordNotFound)
    end
  end
end