class OauthTokensController < Doorkeeper::TokensController
  ActionController::Metal.send(:include, Airbrake::Rails::ControllerMethods)
  include ActionController::Rendering

  def create
    super
    if params[:callback].present?
      self.response_body = "#{params[:callback]}(#{JSON.parse(self.response_body.first).to_json.to_s})"
    else
      self.response_body = {data: JSON.parse(self.response_body.first)}.to_json
    end
  end
end
