puts "Populating all System generated templates"
Rake::Task['templates:populate_system_templates'].invoke