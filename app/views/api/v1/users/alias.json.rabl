object current_user => :data
node :user do |user|
  user.display_name rescue nil
end

node :alias do |user|
  user.alias rescue nil
end