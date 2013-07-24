class Reseller::BaseController < ApplicationController
  before_filter :authenticate_reseller_partner!
  helper_method :partner_signed_in?, :current_partner
end