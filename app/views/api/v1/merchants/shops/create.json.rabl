object @shop => :data
attributes :name, :uuid, :identifier, :description, :stype, :website, :time_zone

node :logo_img do |shop|
	shop.logo_img.url
end

node :errors do |shop|
  shop.error_messages
end

child :manager do
  attributes :uuid, :email, :owner, :identifier
end