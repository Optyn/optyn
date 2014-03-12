module Merchants::FileImportsHelper
  STATS = {:user_creation => "New Subscribers", :existing_user => "Existing Subscribers", :unparsed_rows => "Unparsed rows" }
  def stats_chage
    {:user_creation => "New Subscribers", :existing_connection => "Existing Subscribers", :unparsed_rows => "Unparsed rows" }
  end

end
