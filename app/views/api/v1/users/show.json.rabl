object current_user => :data

node :email do |user|
  user.display_email
end

node :name do |user|
  user.display_name
end

node :errors do |user|
  user.errors.full_messages rescue []
end