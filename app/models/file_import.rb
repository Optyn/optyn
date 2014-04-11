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
      statistics, output, unparsed = User.import(content, manager, label)
      puts ("-" * 25) + "OUTPUT" + ("-" * 25)
      puts "Statistics: #{statistics.inspect}"
      puts "Unparsed: #{unparsed}"
      puts "Output: #{output}"
      puts "-" * 56
      self.stats = statistics
      self.save
      assign_complete_status
      MerchantMailer.import_stats(self, output, unparsed).deliver
    rescue => e
      Rails.logger.error e.message
      Rails.logger.error e.backtrace
      assign_error_status
      self.error = e.message
      self.save(validate: false)
      MerchantMailer.import_error(self, e.message).deliver
    end
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

  def assign_queued_status
    self.status = "queued"
    self.save
  end
end
