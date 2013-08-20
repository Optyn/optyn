object @shop => :data
attributes :name, :uuid, :identifier, :description, :stype, :website, :time_zone

node :logo do |shop|
	shop.logo_location
end

node :errors do |shop|
  shop.error_messages
end

child :manager do
  attributes :uuid, :email, :owner, :identifier
end