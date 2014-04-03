module Merchants::FileImportsHelper
  STATS = {:connection_creation => "Connections Creations", :existing_connection => "Existing Connections", :unparsed_rows => "Unparsed rows" }
  def stats_change
    {:connection_creation => "Connections Creations", :existing_connection => "Existing Connections", :unparsed_rows => "Unparsed rows" }
  end

end
