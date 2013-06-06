module Merchants
 module MessageCounter
   def self.included(controller)
     controller.before_filter(:populate_folder_count)
   end

   def populate_folder_count
     @drafts_count = Message.cached_drafts_count(current_manager)
     @queued_count = Message.cached_queued_count(current_manager)
   end
 end
end