class OauthTokensController < Doorkeeper::TokensController
  ActionController::Metal.send(:include, Airbrake::Rails::ControllerMethods)
  include ActionController::Rendering

  def create
    super
    self.response_body = {data: JSON.parse(self.response_body.first)}.to_json
  end
end
