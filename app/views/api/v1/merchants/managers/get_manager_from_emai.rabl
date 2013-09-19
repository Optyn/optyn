object @manager => :data
attributes :uuid, :email, :name, :owner
 node :shop do |manager|
    manager.business_name
 end

node :errors do |manager|
  manager.error_messages
end