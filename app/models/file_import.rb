class FileImport < ActiveRecord::Base
  belongs_to :manager

  attr_accessible :csv_file

  mount_uploader :csv_file, FileUploader
end
