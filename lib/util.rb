class Util
  def self.nightly_jobs
    clean_sessions
  end

  def self.clean_sessions
    begin

      results = ActiveRecord::Base.connection.select_all( "SELECT * FROM sessions" )
      
      results.each do |session|
        session_data = Marshal.restore( Base64.decode64( session[ 'data' ] ) ) if session[ 'data' ]
        manager_session_key = 'warden.user.merchants_manager.key'
        
        if session_data.has_key?(manager_session_key)
          manager_id = session_data[manager_session_key]
          manager = Manager.where(id: manager_id).first

          next if manager.partner_eatstreet?
        end

        delete_session_entry(session) if Time.parse(session['updated_at']) < 2.days.ago
      
      end

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
    GenericMailer.announce_nightly_job_failure(content, method_name).deliver
  end

  def self.verify_website_response
    check_uri_response
  end

  private
  def self.delete_session_entry(session)
    ActiveRecord::Base.connection.select_all("DELETE FROM sessions WHERE id = #{session['id']}")
  end

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
        GenericMailer.announce_ping_failure("uri => " + host + " returned status code => " + response_code).deliver
      end

    rescue Exception => ex
      GenericMailer.announce_ping_failure("uri => " + host + " Raised Exception => " + ex.to_s).deliver
    end
  end
end