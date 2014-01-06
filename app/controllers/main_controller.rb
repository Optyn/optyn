class MainController < ApplicationController
  layout 'application'

  before_filter :require_not_logged_in, only: [:index]
  before_filter :skip_menu

  def sitemap
    populate_real_shops

    respond_to do |format|
      format.html 
      format.xml {send_file('public/sitemap.xml.gz', filename: 'sitemap.xml.gz')}
    end
  end

  def sitemap_customer_profiles
    populate_real_shops
  end

  private
  def populate_real_shops
    @shops = Shop.real.not_pre_added.alphabetized
  end

  def skip_menu
    @skip_menu = true
  end
end
