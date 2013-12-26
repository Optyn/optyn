namespace :sections do
  desc "Populate different section types"
  task :populate_sections => :environment do
    section = Section.find_or_create_by_section_type('header')    
    section.update_attributes!(addable: false, content: %Q(<table class="row template-section"><tbody><tr><td class="wrapper last"><table class="twelve columns"><tbody><tr><td class="six sub-columns"><img src="http://placehold.it/200x50"></td><td class="six sub-columns last" align="right" style="text-align:right; vertical-align:middle;"><span class="template-label">HERO</span></td><td class="expander"></td></tr></tbody></table></td></tr></tbody></table>))
    
    section = Section.find_or_create_by_section_type('footer')
    section.update_attributes!(addable: false, content: %Q(<table class="row footer template-section"><tbody><tr><td class="wrapper"></td></tr></tbody></table>))
    
    section = Section.find_or_create_by_section_type('text_only')
    section.update_attributes!(content: %Q(<table class="twelve columns template-section"><tbody><tr><td class="ink-editable"><p><span style="font-size:24px;">Hi, Susan Calvin<span></p><p class="lead">Phasellus dictum sapien a neque luctus cursus. Pellentesque sem dolor, fringilla et pharetra vitae.</p><p>Phasellus dictum sapien a neque luctus cursus. Pellentesque sem dolor, fringilla et pharetra vitae. consequat vel lacus. Sed iaculis pulvinar ligula, ornare fringilla ante viverra et.</p></td><td class="expander"></td></tr></tbody></table>))
    

    section = Section.find_or_create_by_section_type('text_with_full_image')
    section.update_attributes!(content: %Q(<table class="row template-section"><tbody><tr><td class="wrapper last"><table class="twelve columns"><tbody><tr><td class="ink-editable"><p>Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et.</p><img width="580" height="300" src="http://placehold.it/580x300"></td><td class="expander"></td></tr></tbody></table></td></tr></tbody></table>))
    
    
    section = Section.find_or_create_by_section_type('text_with_left_image')
    section.update_attributes!(content: %Q(<table class="row template-section"><tbody><tr><td class="wrapper"><table class="four"><tr><td></td></tr></table><table class="eight"><tr><td></td></tr></table></td></tr></tbody></table>))
    

    section = Section.find_or_create_by_section_type('text_with_right_image')
    section.update_attributes!(content: %Q(<table class="row template-section"><tbody><tr><td class="wrapper"><table class="eight"><tbody><tr><td></td></tr></tbody></table><table class="four"><tbody><tr><td></td></tr></tbody></table></td></tr></tbody></table>))
    
    
    section = Section.find_or_create_by_section_type('sidebar')
    section.update_attributes!(addable: false, content: %Q(<table class="row template-section"><tbody><tr><td class="wrapper"><table class="six"><tbody><tr><td></td></tr></tbody></table></td></tr></tbody></table>))
    
    section = Section.find_or_create_by_section_type('half_text')
    section.update_attributes!(content: %Q(<table class="row template-section"><tbody><tr><td class="wrapper"><table class="six"><tbody><tr><td></td></tr></tbody></table></td></tr></tbody></table>))
  end #end of the task

  desc "Seed the sections"
  task :seed => [:populate_sections]
end #end of the namespace