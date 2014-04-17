require File.expand_path('../../../config/initializers/site_config', __FILE__)

desc "PG Backup"
namespace :pg do
  task :backup => [:environment] do
    if Rails.env.production?
      #stamp the filename
      datestamp = Time.now.strftime("%Y-%m-%d_%H-%M-%S")

      #drop it in the /mnt/backups/db directory temporarily
      backup_file_name = "/mnt/backups/db/optyn_#{Rails.env}_#{datestamp}.sql"
      compressed_backup_file_name = "#{backup_file_name.gsub(".sql", "")}.tar.gz"

      username, database = fetch_username_and_database

      #dump the backup and zip it up
      #Added the ~/.pgpass with the deploy user and chmod 600 on it.
      puts "Dumping the database"
      sh "pg_dump -U #{username} -h localhost #{database} -f #{backup_file_name}"
      puts "Compressing the database"
      sh "tar czf #{compressed_backup_file_name} #{backup_file_name}"

      puts "Sending to Amazon"
      send_to_amazon(compressed_backup_file_name)

      #remove the file on completion so we don't clog up our app
      File.delete backup_file_name
      File.delete compressed_backup_file_name
    end
  end # end of the backup task

  def fetch_username_and_database
    conf = YAML::load_file(File.expand_path('../../../config/database.yml', __FILE__))
    dbenv = conf[Rails.env]
    [dbenv['username'], dbenv['database']]
  end

  def send_to_amazon(file_path)
    s3 = AWS::S3.new(
        :access_key_id => SiteConfig.aws_access_key_id,
        :secret_access_key => SiteConfig.aws_secret_access_key)

    bucket = s3.buckets["backup#{Rails.env}"]

    keys = bucket.objects.with_prefix('db/optyn').collect(&:key).sort

    if keys.size >= 3
      deletes = keys.slice(0, (keys.size - 2))
      bucket.objects.delete(deletes)
    end

    db_obj = bucket.objects["db/#{File.basename(file_path)}"]
    db_obj.write(Pathname.new(file_path))
  end
end #end of the pg namespace