namespace :templates do
  desc "Populate system generated templates"
  task :populate_system_templates => :environment do

    #Create a baisc template
    puts "Adding the template Basic"
    options = {shop_id: nil, system_generated: true, name: "Basic"}
    template = Template.where(options).first || Template.new(options)
    template.templates_sections.destroy_all
    template.reload if template.id.present?
    template.templates_sections.build(section_id: Section.header_id, position: 1)
    template.templates_sections.build(section_id: Section.text_only_id, position: 2)
    template.templates_sections.build(section_id: Section.footer_id, position: 3)
    template.save

    #Create a hero template
    puts "Adding the template Hero"
    options = {shop_id: nil, system_generated: true, name: "Hero"}
    template = Template.where(options).first || Template.new(options)
    template.templates_sections.destroy_all
    template.reload if template.id.present?
    template.templates_sections.build(section_id: Section.header_id, position: 1)
    template.templates_sections.build(section_id: Section.text_with_full_image_id, position: 2)
    template.templates_sections.build(section_id: Section.footer_id, position: 3)
    template.save

    #Create a sidebar hero template
    puts "Adding the template Hero Sidebar"
    options = {shop_id: nil, system_generated: true, name: "Hero Sidebar"}
    template = Template.where(options).first || Template.new(options)
    template.templates_sections.destroy_all
    template.reload if template.id.present?
    template.templates_sections.build(section_id: Section.header_id, position: 1)
    template.templates_sections.build(section_id: Section.text_with_full_image_id, position: 2)
    template.templates_sections.build(section_id: Section.sidebar_id, position: 3)
    template.templates_sections.build(section_id: Section.half_text_id, position: 4)
    template.templates_sections.build(section_id: Section.footer_id, position: 5)
    template.save

    #Create a sidebar template
    puts "Adding the template Sidebar"
    options = {shop_id: nil, system_generated: true, name: "Sidebar"}
    template = Template.where(options).first || Template.new(options)
    template.templates_sections.destroy_all
    template.reload if template.id.present?
    template.templates_sections.build(section_id: Section.header_id, position: 1)
    template.templates_sections.build(section_id: Section.half_text_id, position: 2)
    template.templates_sections.build(section_id: Section.sidebar_id, position: 3)
    template.templates_sections.build(section_id: Section.footer_id, position: 4)   
    template.save
  end
end