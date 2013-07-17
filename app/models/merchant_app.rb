class MerchantApp < ActiveRecord::Base
  attr_accessor :redirect_uri

  attr_accessible :name, :redirect_uri

  has_one :oauth_application, class_name: 'Doorkeeper::Application', as: :owner, dependent: :destroy

  after_create :generate_application

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
