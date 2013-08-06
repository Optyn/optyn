object @user => :data
node :errors do |user|
  user.errors.full_messages rescue []
end

node :authenticity_token do |user|
  form_authenticity_token
end