namespace :returnpath do
  desc "Send emails to returnpath seedlist args ex: ['jparekh.communications@gmail.com@@5bd341ae75344eb7a365f374b56367b9--edward@idyllic-software.com@@e52f2280b5124208bf8dd4091a3b0e5c']"
  task :send_emails, [:list] => :environment do |t, args|
    group_str = args[:list]
    groups = group_str.split(/--/)
    
    groups.each do |group|
      email, uuid = group.split(/@@/)
      Returnpath.send_for_manager(email, uuid)
      sleep(30)
    end
  end
end