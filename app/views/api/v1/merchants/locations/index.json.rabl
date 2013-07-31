collection @locations, :root => "data", :object_root => "location"
attributes :uuid, :street_address1, :street_address2, :city, :zip

node(:state_abbr) do |location|
    location.state_abbr
end

node(:errors) do |location|
    location.error_messages
end