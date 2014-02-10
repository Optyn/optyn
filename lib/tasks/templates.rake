namespace :templates do
  desc "Populate system generated templates"
  task :seed => :environment do
    Template.all.each do |template| 
      begin
        template.destroy!
      rescue 
        
      end
    end

    #Add the basic Template
    puts "Adding the Basic Template"
    template = Template.for_shop(nil).for_name('Basic').first || Template.new
    template.attributes=({name: "Basic", system_generated: true, html: File.open("#{Rails.root}/db/seed_data/system_template_data/basic.html", 'r'){|file| file.read}})
    template.save!
    sleep(10)

    #Adding the Sidebar Template
    puts "Adding the Sidebar Template"
    template = Template.for_shop(nil).for_name('Sidebar').first || Template.new
    template.attributes = ({name: "Sidebar", system_generated: true, html: File.open("#{Rails.root}/db/seed_data/system_template_data/sidebar.html", 'r'){|file| file.read}})
    template.save!
    sleep(10)

    #Adding the Hero Template
    puts "Adding the Hero Template"
    template = Template.for_shop(nil).for_name('Hero').first || Template.new
    template.attributes = ({name: "Hero", system_generated: true, html: File.open("#{Rails.root}/db/seed_data/system_template_data/hero.html", 'r'){|file| file.read}})
    template.save!
    sleep(10)

    #Adding the Galleria Template
    puts "Adding the Galleria Template"
    template = Template.for_shop(nil).for_name('Galleria').first || Template.new
    template.attributes = ({name: "Galleria", system_generated: true, html: File.open("#{Rails.root}/db/seed_data/system_template_data/galleria.html", 'r'){|file| file.read}})
    template.save!
    sleep(10)
  end

  task :generate_thumbnails => :environment do
    Template.select('id, html').where(:thumbnail => nil).each do |template|
      template.generate_thumbnail
      puts "DONE generating thumbnail for #{template.id}"
    end
  end
end
