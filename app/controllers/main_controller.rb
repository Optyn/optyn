class MainController < ApplicationController
  layout 'application'

  before_filter :require_not_logged_in, only: [:index]
  before_filter :skip_menu
  before_filter :fetch_blog_posts, only: [:resources_email_marketing, :resources_capturing_customer_emails, :resources_capturing_customer_data, :resources_mobile_responsive_emails, :resources_evolution_email, :resources_best_practices, :resources_measuring_success, :resources_email_marketing_getting_started, :resources_email_marketing_types, :resources_email_marketing_tips, :resources_social_media, :resources_digital_marketing, :resources_contests, :resources_coupons, :resources_specials_sales, :resources_customer_retention, :resources_loyalty_marketing, :resources_surveys, :resources_marketing_analytics, :resources_online_marketing, :resources_marketing_automation, :resources_marketing_promotions, :resources_marketing_syndication, :resources_marketing_ideas, :resources_integrated_marketing, :resources_reachable_audience, :resources_email_marketing_system, :resources_cheap_email_marketing, :resources_best_bulk_email_software, :resources_top_email_marketing_software, :resources_email_broadcast, :resources_best_email_marketing, :resources_best_email_marketing_software, :resources_best_newsletter_software, :resources_bulk_email, :resources_direct_email_marketing, :resources_email_blast, :resources_best_free_email_marketing, :resources_email_advertising, :resources_email_campaign, :resources_email_templates, :resources_email_marketing_stats, :resources_small_business_email_marketing, :resources_email_marketing_strategy, :resources_how_to_email_marketing, :resources_catchy_email_subject_lines, :resources_top_email_marketing, :resources_email_marketing_online, :resources_what_is_email_marketing, :resources_follow_up_emails, :resources_email_types, :resources_email_newsletter, :resources_mass_email, :resources_opt_in_email_marketing]

  def index
    if params[:unsubscribe].present?
      flash.now[:notice] = "Unsubscribe to #{params[:shop_name]} successful."
    end

    if params[:flash_msg].present?
      flash.now[:alert] = params[:flash_msg]
    end
  end

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

  def robots
    content_type = 'text/plain'
    if request.url.include?('optynmail.com')
      render(file: "#{Rails.public_path}/robots-optynmail.txt", layout: false, content_type: content_type)
    else
      render(file: "#{Rails.public_path}/robots-optyn.txt", layout: false, content_type: content_type)
    end  
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
