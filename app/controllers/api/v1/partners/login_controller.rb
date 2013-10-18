module Api
  module V1
    module Partners
      class LoginController < ApplicationController
        respond_to :json
        def new
          #DO NOTHING JUST RETURN THE CRF TOKEN
          request.env["devise.mapping"] = Devise.mappings[:reseller_partner]
        end

        def create
          auth_options = {scope: :reseller_partner}
          resource_name = :reseller_partner
          warden.config[:default_scope] = :reseller_partner
          params[:reseller_partner] = params.delete(:partner)
          resource_name = :reseller_partner
          
          request.env["devise.allow_params_authentication"] = true
          resource = @partner = warden.authenticate!(auth_options)
          
          sign_in(resource)
          session[:user_return_to] = nil
          head :created
        rescue => e
          binding.pry
        end
      end
    end
  end
end
