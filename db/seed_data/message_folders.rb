#Add Message Folder inbox, deleted etc.
MessageFolder.create(:name => "Inbox")
MessageFolder.create(:name => "Deleted")
MessageFolder.create!(:name => "Saved")
MessageFolder.create!(:name => "Discarded")