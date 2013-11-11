class MainController < ApplicationController
  layout 'application'

  before_filter :require_not_logged_in, only: [:index]
  before_filter :skip_menu

  def sitemap
    @shops = Shop.real.not_pre_added.alphabetized

    respond_to do |format|
      format.html 
      format.xml {send_data('public/sitemap.xml.gz', filename: 'sitename.xml.gz', disposition: 'attachment', type: 'application/x-gzip')}
    end
  end

  private
  def skip_menu
    @skip_menu = true
  end
end
