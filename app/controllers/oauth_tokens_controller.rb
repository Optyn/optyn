class OauthTokensController < Doorkeeper::TokensController
  def create
    super
    self.response_body = "#{params[:callback]}(#{self.response_body})"
  end
end
