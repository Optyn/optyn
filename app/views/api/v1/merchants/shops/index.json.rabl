collection @shops, :root => "data", :object_root => "shop"
attributes :name, :uuid, :identifier, :description, :stype, :website, :time_zone, :created_at

child :manager do
  attributes :uuid, :email, :owner, :identifier
end
