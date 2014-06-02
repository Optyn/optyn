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
    template.attributes=({position: 1, name: "Basic", system_generated: true, html: File.open("#{Rails.root}/db/seed_data/system_template_data/basic.html", 'r'){|file| file.read}})
    template.save!
    # sleep(10)

    #Adding the Left Sidebar Template
    puts "Adding the Left Sidebar Template"
    template = Template.for_shop(nil).for_name('Left Sidebar').first || Template.new
    template.attributes = ({position: 2, name: "Left Sidebar", system_generated: true, html: File.open("#{Rails.root}/db/seed_data/system_template_data/left_sidebar.html", 'r'){|file| file.read}})
    template.save!
    # sleep(10)

    puts "Adding the Right Sidebar Template"
    template = Template.for_shop(nil).for_name('Right Sidebar').first || Template.new
    template.attributes = ({position: 3, name: "Right Sidebar", system_generated: true, html: File.open("#{Rails.root}/db/seed_data/system_template_data/right_sidebar.html", 'r'){|file| file.read}})
    template.save!
    # sleep(10)

    #Adding the Hero Template
    puts "Adding the Hero Template"
    template = Template.for_shop(nil).for_name('Hero').first || Template.new
    template.attributes = ({position: 4, name: "Hero", system_generated: true, html: File.open("#{Rails.root}/db/seed_data/system_template_data/hero.html", 'r'){|file| file.read}})
    template.save!
    # sleep(10)

    #Adding the Galleria Template
    puts "Adding the Galleria Template"
    template = Template.for_shop(nil).for_name('Galleria').first || Template.new
    template.attributes = ({position: 5, name: "Galleria", system_generated: true, html: File.open("#{Rails.root}/db/seed_data/system_template_data/galleria.html", 'r'){|file| file.read}})
    template.save!
    # sleep(10)
  end

  task :generate_thumbnails => :environment do
    Template.select('id, html').where(:thumbnail => nil).each do |template|
      template.generate_thumbnail
      puts "DONE generating thumbnail for #{template.id}"
    end
  end

  task :add_missing_optyn_button_link => :environment do
    button_style = <<-STYLE
    <style type="text/css">  
      .ss-content a.ss-button-link{
        text-decoration:none;
        color: #FFF !important;
        background-color: #64aaef;
        -webkit-border-radius: 0;
        -moz-border-radius: 0;border-radius: 0;
        font: normal 16px/25px 'Open Sans', sans-serif;
        letter-spacing: 1px;
        border-bottom: solid 2px rgba(0, 0, 0, 0.2);
        -webkit-transition: all 0.2s ease-out;-moz-transition: all 0.2s ease-out;-o-transition: all 0.2s ease-out;transition: all 0.2s ease-out;
        border-top: 0;
        border-left: 0;
        border-right: 0;
        padding: 3px 10px;
        display: inline-block;
        margin-top: 15px;
      }

      .ss-content a.ss-button-link:hover{
        color: #FFF !important;
        background-color: #64aaef;
      }

      .ss-content a.ss-button-link:visited{
        color: #FFF !important;
        background-color: #64aaef;
      }

      .ss-content a.ss-button-link:active{
        color: #FFF !important;
        background-color: #64aaef;
      }
      </style>
    STYLE

    templates = Template.where("shop_id IS NOT NULL")
    templates.each do |template|
      html = template.html
      if html.present?
        layout_node = Nokogiri::HTML(html)
        style_node = layout_node.css('style').last  
        unless style_node.to_s.include?('optyn-button-link')
          style_node.after(button_style)

          template.html = layout_node.to_s
          template.send(:create_structure)

          Rails.logger.info %{-- Updating Template: #{template.name} and the Shop Name: #{template.shop.name}}
        else
          Rails.logger.info %{xx Updating Template: #{template.name} and the Shop Name: #{template.shop.name}}
        end
      end
    end
  end


  desc "Update the html and structure of systme generated templates"
  task :update_class_prefix => :environment do
    #Updating the basic Template
    puts "Update the Basic Template"
    template = Template.for_shop(nil).for_name('Basic').where(:system_generated => true).first
    template.attributes=({html: File.open("#{Rails.root}/db/seed_data/system_template_data/basic.html", 'r'){|file| file.read}})
    template.send(:create_structure)
    puts "basic #{template.html.include? "ss-"} ,,,,#{template.html.include? "optyn-"}"

    #Update the Left Sidebar Template
    puts "Update the Left Sidebar Template"
    template = Template.for_shop(nil).for_name('Left Sidebar').where(:system_generated => true).first 
    template.attributes = ({html: File.open("#{Rails.root}/db/seed_data/system_template_data/left_sidebar.html", 'r'){|file| file.read}})
    template.send(:create_structure)
    puts "basic #{template.html.include? "ss-"} ,,,,#{template.html.include? "optyn-"}"

    #Update the Right Sidebar Template
    puts "Update the Right Sidebar Template"
    template = Template.for_shop(nil).for_name('Right Sidebar').where(:system_generated => true).first
    template.attributes = ({html: File.open("#{Rails.root}/db/seed_data/system_template_data/right_sidebar.html", 'r'){|file| file.read}})
    template.send(:create_structure)

    #Update the Hero Template
    puts "Update the Hero Template"
    template = Template.for_shop(nil).for_name('Hero').where(:system_generated => true).first
    template.attributes = ({html: File.open("#{Rails.root}/db/seed_data/system_template_data/hero.html", 'r'){|file| file.read}})
    template.send(:create_structure)

    #Update the Galleria Template
    puts "Update the Galleria Template"
    template = Template.for_shop(nil).for_name('Galleria').where(:system_generated => true).first
    template.attributes = ({html: File.open("#{Rails.root}/db/seed_data/system_template_data/galleria.html", 'r'){|file| file.read}})
    template.send(:create_structure)
  end

  desc "Updating the html and structure of all existing generated templates"
  task :update_existing_templates_class_prefix => :environment do
   templates = Template.with_deleted.all
    templates.each do |template|
      template.html = template.html.gsub("optyn-", "ss-")
      template.send(:create_structure)
      puts "Updated #{template.name}'s html and structure."
    end
  end
end

