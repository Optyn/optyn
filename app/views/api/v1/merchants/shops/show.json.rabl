object @shop => :data
attributes :name, :uuid, :identifier, :description, :stype, :website, :time_zone, :phone_number, :created_at

child :manager do
  attributes :uuid, :name, :email, :owner
end

node :errors do |shop|
  shop.error_messages
end

node :logo do |shop|
  shop.logo_location
end