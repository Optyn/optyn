namespace :templates do
  desc "Populate system generated templates"
  task :seed => :environment do
    Template.all.each do |template| 
      begin
        template.destroy
      rescue 
        
      end
    end

    #Add the basic Template
    puts "Adding the Basic Template"
    template = Template.for_shop(nil).for_name('Basic').first || Template.new
    template.attributes=({name: "Basic", system_generated: true, html: File.open("#{Rails.root}/db/seed_data/system_template_data/basic.html", 'r'){|file| file.read}})
    template.save!
    # sleep(10)

    #Adding the Left Sidebar Template
    puts "Adding the Left Sidebar Template"
    template = Template.for_shop(nil).for_name('Left Sidebar').first || Template.new
    template.attributes = ({name: "Left Sidebar", system_generated: true, html: File.open("#{Rails.root}/db/seed_data/system_template_data/left_sidebar.html", 'r'){|file| file.read}})
    template.save!
    # sleep(10)

    puts "Adding the Right Sidebar Template"
    template = Template.for_shop(nil).for_name('Right Sidebar').first || Template.new
    template.attributes = ({name: "Right Sidebar", system_generated: true, html: File.open("#{Rails.root}/db/seed_data/system_template_data/right_sidebar.html", 'r'){|file| file.read}})
    template.save!
    sleep(10)

    #Adding the Hero Template
    puts "Adding the Hero Template"
    template = Template.for_shop(nil).for_name('Hero').first || Template.new
    template.attributes = ({name: "Hero", system_generated: true, html: File.open("#{Rails.root}/db/seed_data/system_template_data/hero.html", 'r'){|file| file.read}})
    template.save!
    # sleep(10)

    #Adding the Galleria Template
    puts "Adding the Galleria Template"
    template = Template.for_shop(nil).for_name('Galleria').first || Template.new
    template.attributes = ({name: "Galleria", system_generated: true, html: File.open("#{Rails.root}/db/seed_data/system_template_data/galleria.html", 'r'){|file| file.read}})
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
      .optyn-content a.optyn-button-link{
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

      .optyn-content a.optyn-button-link:hover{
        color: #FFF !important;
        background-color: #64aaef;
      }

      .optyn-content a.optyn-button-link:visited{
        color: #FFF !important;
        background-color: #64aaef;
      }

      .optyn-content a.optyn-button-link:active{
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
end
