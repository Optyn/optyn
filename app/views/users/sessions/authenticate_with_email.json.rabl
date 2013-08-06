object @user => :data
attributes :name
node :errors do |user|
  user.errors.full_messages
end