namespace :message do
  desc "Add the header message section"
  task :header_message_visual_section => :environment do
    MessageVisualSection.find_or_create_by_name('Header')
  end
end