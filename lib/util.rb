class Util
  def self.nightly_jobs
    clean_sessions
  end

  def self.clean_sessions
    begin
      #date = Chronic.parse('midnight yesterday').to_s(:db)
      date = Chronic.parse('2 days ago midnight').to_s(:db)
      ActiveRecord::Base.connection.execute("DELETE FROM sessions WHERE updated_at < '#{date}'")
      nil
    rescue Exception => e
      email_exception(e, "clean_sessions")
    end
  end

  def self.email_exception(e, method_name)
    content = "#{"-" * 5} Error while running #{method_name} task #{"-" * 5}" + '\n'
    content << e.message + "\n"
    content << e.backtrace + "\n"
    content << "#{"-" * 5} End Error while running #{method_name} task #{"-" * 5}"
    NightlyJobsMailer.announce_failure(content, method_name).deliver
  end

  def self.verify_website_response
    check_uri_response
  end

  private
  def self.check_uri_response
    begin
      uri = URI.parse(SiteConfig.app_base_url)
      host = uri.host
      port = uri.port

      response = Net::HTTP.start(host, port) { |http|
        req = Net::HTTP::Get.new("/")
        http.request(req)
      }

      response_code = response.code.strip
      unless response_code == "200"
        PingMailer.announce_downtime("uri => " + host + " returned status code => " + response_code).deliver
      end

    rescue Exception => ex
      PingMailer.announce_downtime("uri => " + host + " Raised Exception => " + ex.to_s).deliver
    end
  end
end