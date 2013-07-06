namespace :app_settings do
  desc "Seed some App specific settings"
  task :optyn_oauth_client => :environment do
   oauth_setting = AppSetting.find_or_create_by_name('optyn_oauth_client')
   oauth_setting.value = "1"  #This value can be changed through the admin section
   oauth_setting.save
  end
end