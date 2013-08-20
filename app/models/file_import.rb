require 'csv'
require 'open-uri'

class FileImport < ActiveRecord::Base
  belongs_to :manager

  attr_accessible :csv_file, :label

  serialize :stats, Hash

  mount_uploader :csv_file, FileUploader

  validates :csv_file, presence: true
  validates :csv_file, file_size: {maximum: 10.megabytes.to_i}, :if => :should_validate?

  DEFAULT_LABEL_NAME = 'Import'

  after_create :assign_queued_status

  def create_connections()
    content = download_file
    begin
      self.stats = User.import(content, manager, label)
      self.save
      assign_complete_status
      MerchantMailer.import_stats(self).deliver
    rescue => e
      Rails.logger.error e.message
      Rails.logger.error e.backtrace
      assign_error_status
      MerchantMailer.import_error(self, e.message).deliver
    end
  end

  def create_unparsed_rows_file_if
    dir_path = "#{Rails.root}/tmp/file_import/"
    file_path = "#{dir_path}/FileImport#{self.id}.csv"

    FileUtils.mkdir_p(dir_path) unless Dir.exists?("#{Rails.root}/tmp/file_import/")

    unless File.exists?(file_path)
      File.open(file_path, "wb+") do |file|
        file << %{"Name","Email"\n}
      end
    end

    file_path
  end

  def assign_being_parsed_status
    self.status = "being_parsed"
    self.save
  end

  def assign_complete_status
    self.status = "complete"
    self.save
  end

  def assign_error_status
    self.status = "error"
    self.save
  end

  private
  def should_validate?
    csv_file.present?
  end

  def download_file
    io_string = open(self.csv_file.to_s)
    io_string.read
  end

  def validate_headers(headers)
    raise "Incorrect Headers. The file should have headers of 'Name' and 'Email'" if !headers.include?(:name) || !headers.include?(:email)
  end

  def add_unparsed_row(row)
    puts "Adding an unparsed row"
    unparsed_file_path = create_unparsed_rows_file_if
    File.open(unparsed_file_path, "a") do |file|
      file << (row.to_s + "\n")
    end
  end

  def assign_queued_status
    self.status = "queued"
    self.save
  end
end
