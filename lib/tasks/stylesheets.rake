namespace :stylesheets do
  desc "Add the ink styles without template_id"
  task :ink => :environment do
    ink = Stylesheet.ink
    if ink.blank?
      location = "#{Rails.root}/public/ink.css"
      Stylesheet.create(location: location, name: "ink.css")
    end
  end  
end