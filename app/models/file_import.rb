require 'csv'
require 'open-uri'

class FileImport < ActiveRecord::Base
  belongs_to :manager

  attr_accessible :csv_file

  serialize :stats, Hash

  mount_uploader :csv_file, FileUploader

  validates :csv_file, presence: true
  validates :csv_file, file_size: {maximum: 10.megabytes.to_i}, :if => :should_validate?

  after_create :assign_queued_status

  def create_connections()
    begin
      shop = manager.shop
      path = download_file()

      csv_table = CSV.table(path, {headers: true})

      headers = csv_table.headers
      validate_headers(headers)

      counters = ActiveSupport::OrderedHash.new()
      counters[:user_creation] = 0
      counters[:existing_user] = 0
      counters[:connection_creation] = 0
      counters[:existing_connection]  = 0
      counters[:unparsed_rows] = 0

      csv_table.each do |row|


        user = User.find_by_email(row[:email]) || User.new(email: row[:email])
        user.name = row[:name] unless user.name.present?
        user.valid?

        (counters[:unparsed_rows] += 1) and (add_unparsed_row(row)) and next if user.errors.include?(:email) || user.errors.include?(:name)

        if user.new_record?
          passwd = Devise.friendly_token.first(8)
          user.password = passwd
          user.password_confirmation = passwd
          user.show_password
          counters[:user_creation] += 1
        else
          counters[:existing_user] += 1
        end
        user.save()


        connection = Connection.find_by_shop_id_and_user_id(shop.id, user.id) || Connection.new(shop_id: shop.id, user_id: user.id)
        if connection.new_record?
          connection.active = true
          connection.connected_via = Connection::CONNECTED_VIA_IMPORT
          counters[:connection_creation] += 1
        else
          counters[:existing_connection] += 1
        end
        connection.save()

        label = Label.find_or_create_by_shop_id_and_name(shop.id, 'Import')
        UserLabel.find_or_create_by_user_id_and_label_id(user.id, label.id)
      end

      self.stats = counters
      self.save

      assign_complete_status

      MerchantMailer.import_stats(self, counters).deliver
    rescue => e
      Rails.logger.error e.message
      Rails.logger.error
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

    if io_string.is_a?(Tempfile)
      path = io_string.path
    elsif io_string.is_a?(StringIO)
      File.open("#{Rails.root.to_s}/tmp/#{File.basename(self.csv_file.to_s)}", 'wb+') do |file|
        file << io_string.read
        path = file.path
      end
    else
      raise ArgumentError, 'Document not opening properly'
    end
    path
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
