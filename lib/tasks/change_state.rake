namespace :change_state do
  desc "Remove state_id and add state to location"
  task :state  => :environment do
    locations = Location.all
    locations.each do |location|
      location.update_attributes("state_name" => location.state.name) if !location.state.blank?
    end
  end
end