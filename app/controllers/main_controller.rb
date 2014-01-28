class MainController < ApplicationController
  layout 'application'

  before_filter :require_not_logged_in, only: [:index]
  before_filter :skip_menu
  before_filter :fetch_blog_posts, only: [:resources_email_marketing, :email_marketing_agency]

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

  def fetch_blog_posts
    feed = Feedzirra::Feed.fetch_and_parse("http://blog.optyn.com/feed/")
    @posts = feed.entries.sort{ rand() - 0.5 }[0..4]
  end

end
