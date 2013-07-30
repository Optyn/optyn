#Tasks related to the manager model
namespace :manager do
  desc "Add missing uuids to managers"
  task :assign_missing_uuid => :environment do
    missing_uuid_managers = Manager.where(uuid: nil)
    missing_uuid_managers.each do |manager|
      manager.send(:assign_uuid)
    end
  end
end