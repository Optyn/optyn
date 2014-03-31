module Merchants::FileImportsHelper
  STATS = {:user_creation => "Connections Creations", :existing_user => "Existing Connections", :unparsed_rows => "Unparsed rows" }
  def stats_change
    {:user_creation => "Connections Creations", :existing_connection => "Existing Connections", :unparsed_rows => "Unparsed rows" }
  end

end
