object current_user => :data
node :errors do |user|
  current_user.errors.full_messages rescue []
end

node :authenticity_token do |user|
  form_authenticity_token
end