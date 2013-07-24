object @connection => :data
node :user do |connection|
  connection.user.display_name rescue nil
end

node :shop do |connection|
    connection.shop.name rescue nil
end

node :active do |connection|
    connection.active rescue false
end