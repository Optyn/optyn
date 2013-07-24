module Doorkeeper
  module PlainApplicationGenerator
    def generate_application(force_delete=false)
      if force_delete
        self.oauth_application.destroy if self.oauth_application.present?
        reload
      end

      app = self.oauth_application || Doorkeeper::Application.new(:name => self.name)
      ActiveRecord::Base.transaction do
        app.redirect_uri = self.redirect_uri
        self.oauth_application = app
      end

      app.save
    end
  end
end