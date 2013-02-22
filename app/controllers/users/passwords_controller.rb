class Users::PasswordsController < Devise::PasswordsController
  before_filter :require_consumer
  def create
    super
  end
end