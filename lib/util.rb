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
end