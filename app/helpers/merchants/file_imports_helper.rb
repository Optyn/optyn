module Merchants::FileImportsHelper
  STATS = {:connection_creation => "New Subscribers", :existing_connection => "Existing Subscribers", :unparsed_rows => "Unparsed rows" }
  def stats_change
    {:connection_creation => "New Subscribers", :existing_connection => "Existing Subscribers", :unparsed_rows => "Unparsed rows" }
  end

end
