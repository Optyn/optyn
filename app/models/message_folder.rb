class MessageFolder < ActiveRecord::Base
  has_many :messages

  attr_accessible :name

  validates :name, presence: true, uniqueness: true

  class << self
    class_eval do
      if MessageFolder.table_exists?
        common_folders = MessageFolder.all(:conditions => {:name => ["Inbox", "Saved", "Deleted"]})
        common_folders.each do |folder|
          define_method(folder.name.underscore.to_sym) do
            eval("@@#{folder.name.upcase} ||= folder")
          end

          define_method("#{folder.name.underscore}_id".to_sym) do
            folder.id
          end

        end
      end
    end
  end #end of self block
end
