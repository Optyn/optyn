module Messagecenter
  class ProcessManager
    class << self
      @@email_counter = 0

      def email_counter
        @@email_counter
      end

      def increment_email_counter
        @@email_counter += 1
      end

      def reset_email_counter
        @@email_counter = 0
      end

      def time_to_rest?
        email_counter >= 50
      end
    end #end of the self block

    attr_accessor :relevant_pid_names, :content, :current_pid_file_name, :current_pid,
                  :deployment_file_name, :base_dir_path, :current_file_path, :other_process_name

    DEPLOYMENT_PID_FILE_NAME = "deployment.pid"
    PID_REGEX = /(.*)(PID:(.*))(.*)\n/
    BASE_FILE_PATH = "#{SiteConfig.deployment_shared_path}pids/"

    def initialize(options={})
      @base_dir_path = BASE_FILE_PATH
      @deployment_file_name = DEPLOYMENT_PID_FILE_NAME
      @current_pid_file_name = options[:current_pid_file_name]
      @relevant_pid_names = options[:relevant_pid_names].+([@deployment_file_name, @current_pid_file_name])
      @current_file_path = @base_dir_path + @current_pid_file_name
      @content = options[:content]
    end

    def create_pid_file
      File.open(current_file_path, "w+") do |file|
        file.puts(content)
      end
    end

    def delete_pid_file
      File.delete(current_file_path)
    end

    def no_lock_file?
      !lock_file_exists?
    end

    def relevant_existing_process_info
      error_message = ""
      if deployment_running?
        error_message = deployment_running_message
      elsif !current_process_running? && other_relevant_process_running?
        error_message = another_process_running_message
      end
      error_message
    end

#    private
    def deployment_running?
      File.exists?(base_dir_path + deployment_file_name)
    end

    def current_process_running?
      file_absolute_path = current_file_path
      if File.exists?(file_absolute_path)
        file_content = File.read(file_absolute_path)
        pid = file_content.match(PID_REGEX).to_s.strip.split(":").last
        return pid == Process.pid.to_s
      end
      false
    end

    def lock_file_content
      File.read base_dir_path + other_process_name unless other_process_name.blank?
    end

    def lock_file_exists?
      pid_files = Dir.entries(base_dir_path)
      !pid_files.&(relevant_pid_names).blank?
    end

    def deployment_running_message
      message = "Deployment Running"
      message.<<(File.read("#{base_dir_path}#{deployment_file_name}"))
    end

    def another_process_running_message
      message = "Another #{other_relevant_process_file.split(".").first.humanize} Process Running\n"
      message.<<("Details:\n")
      message.<<(other_relevant_process_file_content)
      message.<<("Current Process ID:#{Process.pid}")
      message
    end

    def other_relevant_process_file_content
      relevant_pid_names.each do |filename|
        file_absolute_path = base_dir_path + filename
        return File.read(file_absolute_path) if File.exists?(file_absolute_path)
      end
    end

    def other_relevant_process_running?
      relevant_pid_names.each do |filename|
        return @other_process_name = filename if File.exists?(base_dir_path + filename)
      end
    end
    alias_method :other_relevant_process_file, :other_relevant_process_running?
  end
end
