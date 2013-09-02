class OauthTokensController < Doorkeeper::TokensController

  def create
    super
    if params[:callback].present?
      self.response_body = "#{params[:callback]}(#{JSON.parse(self.response_body.first).to_json.to_s})"
    else
      self.response_body
    end
  end
end
