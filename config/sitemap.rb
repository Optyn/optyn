require 'rubygems'
require 'sitemap_generator'
require 'sitemap_url_helper'

SitemapGenerator::Sitemap.default_host = 'http://www.optyn.com'
SitemapGenerator::Sitemap.create do

   if Rails.env.production?
    
    add '/', :changefreq => 'daily', :priority => 1.0  
    add '/features', :changefreq => 'weekly', :priority => 0.8 
    add '/pricing', :changefreq => 'weekly', :priority => 0.8 
    add '/faq', :changefreq => 'weekly', :priority => 0.8 
    add '/about', :changefreq => 'weekly', :priority => 0.8
    add '/contact', :changefreq => 'weekly', :priority => 0.8
    add '/terms', :changefreq => 'weekly', :priority => 0.8
    add '/privacy', :changefreq => 'weekly', :priority => 0.8
    add '/tour', :changefreq => 'weekly', :priority => 0.8
    add '/testimonials/alley-gallery', :changefreq => 'weekly', :priority => 0.8
    add '/affiliates', :changefreq => 'weekly', :priority => 0.8
    add marketing_path, :changefreq => 'weekly', :priority => 0.8
    add resources_path, :changefreq => 'weekly', :priority => 0.8
    add email_marketing_path, :changefreq => 'weekly', :priority => 0.8
    add mobile_responsive_path, :changefreq => 'weekly', :priority => 0.8
    add capturing_data_path, :changefreq => 'weekly', :priority => 0.8
    add email_deliverability_path, :changefreq => 'weekly', :priority => 0.8
    add marketing_promotions_path, :changefreq => 'weekly', :priority => 0.8
    add coupons_path, :changefreq => 'weekly', :priority => 0.8
    add contests_path, :changefreq => 'weekly', :priority => 0.8
    add surveys_path, :changefreq => 'weekly', :priority => 0.8
    add specials_path, :changefreq => 'weekly', :priority => 0.8
    add social_media_marketing_path, :changefreq => 'weekly', :priority => 0.8
    add marketing_automation_path, :changefreq => 'weekly', :priority => 0.8
    add marketing_syndication_path, :changefreq => 'weekly', :priority => 0.8
    add marketing_ideas_path, :changefreq => 'weekly', :priority => 0.8
    add online_marketing_path, :changefreq => 'weekly', :priority => 0.8
    add automated_marketing_path, :changefreq => 'weekly', :priority => 0.8
    add loyalty_marketing_path, :changefreq => 'weekly', :priority => 0.8
    add customer_retention_path, :changefreq => 'weekly', :priority => 0.8
    add marketing_analytics_path, :changefreq => 'weekly', :priority => 0.8
    add ditgital_marketing_path, :changefreq => 'weekly', :priority => 0.8
    add marketing_collaboration_path, :changefreq => 'weekly', :priority => 0.8
    add multi_channel_marketing_path, :changefreq => 'weekly', :priority => 0.8
    add integrated_marketing_path, :changefreq => 'weekly', :priority => 0.8
    # sell pages for keywords
    add free_email_marketing_path, :changefreq => 'weekly', :priority => 0.8
    add free_email_marketing_software_path, :changefreq => 'weekly', :priority => 0.8
    add free_newsletter_software_path, :changefreq => 'weekly', :priority => 0.8
    add mass_mail_software_path, :changefreq => 'weekly', :priority => 0.8
    add email_marketing_programs_path, :changefreq => 'weekly', :priority => 0.8
    add email_marketing_solutions_path, :changefreq => 'weekly', :priority => 0.8
    add email_blast_software_path, :changefreq => 'weekly', :priority => 0.8
    add bulk_email_software_path, :changefreq => 'weekly', :priority => 0.8
    add newsletter_software_path, :changefreq => 'weekly', :priority => 0.8
    add email_marketing_agency_path, :changefreq => 'weekly', :priority => 0.8
    add email_marketing_software_path, :changefreq => 'weekly', :priority => 0.8
    add free_email_marketing_software_path, :changefreq => 'weekly', :priority => 0.8
    #resource pages
    add resources_email_marketing_path, :changefreq => 'weekly', :priority => 0.8
    add resources_mobile_responsive_emails_path, :changefreq => 'weekly', :priority => 0.8
    add resources_capturing_customer_emails_path, :changefreq => 'weekly', :priority => 0.8
    add resources_capturing_customer_data_path, :changefreq => 'weekly', :priority => 0.8
    add resources_evolution_email_path, :changefreq => 'weekly', :priority => 0.8
    add resources_best_practices_path, :changefreq => 'weekly', :priority => 0.8
    add resources_email_marketing_tips_path, :changefreq => 'weekly', :priority => 0.8
    add resources_getting_started_path, :changefreq => 'weekly', :priority => 0.8
    add resources_email_marketing_types_path, :changefreq => 'weekly', :priority => 0.8
    add resources_measuring_success_path, :changefreq => 'weekly', :priority => 0.8
    add resources_contests_path, :changefreq => 'weekly', :priority => 0.8
    add resources_coupons_path, :changefreq => 'weekly', :priority => 0.8
    add resources_surveys_path, :changefreq => 'weekly', :priority => 0.8
    add resources_specials_sales_path, :changefreq => 'weekly', :priority => 0.8
    add resources_social_media_path, :changefreq => 'weekly', :priority => 0.8
    add resources_digital_marketing_path, :changefreq => 'weekly', :priority => 0.8
    add resources_online_marketing_path, :changefreq => 'weekly', :priority => 0.8
    add esources_customer_retention_path, :changefreq => 'weekly', :priority => 0.8
    add resources_loyalty_marketing_path, :changefreq => 'weekly', :priority => 0.8
    add resources_marketing_analytics_path, :changefreq => 'weekly', :priority => 0.8
    add resources_marketing_automation_path, :changefreq => 'weekly', :priority => 0.8
    add resources_marketing_promotions_path, :changefreq => 'weekly', :priority => 0.8
    add resources_marketing_syndication_path, :changefreq => 'weekly', :priority => 0.8
    add resources_marketing_ideas_path, :changefreq => 'weekly', :priority => 0.8
    add resources_integrated_marketing_path, :changefreq => 'weekly', :priority => 0.8
    #resource keyword pages
    add resources_email_broadcast_path, :changefreq => 'weekly', :priority => 0.8
    add resources_cheap_email_marketing_path, :changefreq => 'weekly', :priority => 0.8
    add resources_top_email_marketing_software_path, :changefreq => 'weekly', :priority => 0.8
    add resources_best_bulk_email_software_path, :changefreq => 'weekly', :priority => 0.8
    add resources_email_marketing_system_path, :changefreq => 'weekly', :priority => 0.8
    add resources_best_email_marketing_path, :changefreq => 'weekly', :priority => 0.8
    add resources_best_email_marketing_software_path, :changefreq => 'weekly', :priority => 0.8
    add resources_best_newsletter_software_path, :changefreq => 'weekly', :priority => 0.8
    add resources_bulk_email_path, :changefreq => 'weekly', :priority => 0.8
    add resources_direct_email_marketing_path, :changefreq => 'weekly', :priority => 0.8
    add resources_email_blast_path, :changefreq => 'weekly', :priority => 0.8
    add resources_best_free_email_marketing_path, :changefreq => 'weekly', :priority => 0.8
    add resources_email_advertising_path, :changefreq => 'weekly', :priority => 0.8
    add resources_email_campaign_path, :changefreq => 'weekly', :priority => 0.8
    add resources_email_templates_path, :changefreq => 'weekly', :priority => 0.8
    add resources_email_marketing_stats_path, :changefreq => 'weekly', :priority => 0.8

    Shop.real.each do |shop|
      add "/shop/public/#{shop.identifier}", :changefreq => 'weekly', :priority => 0.8
    end

    SitemapGenerator::Sitemap.default_host = 'https://www.optyn.com'
    Message.made_public.each do |message|
      add("/#{message.shop.name.parameterize}/campaigns/#{message.name.parameterize}-#{message.uuid}", :changefreq => 'weekly', :priority => 0.8)
    end

    SitemapGenerator::Sitemap.default_host = 'https://www.optyn.com'
    add '/partner-with-us', :changefreq => 'weekly', :priority => 0.8

  end
end

if Rails.env.production?
  SitemapGenerator::Sitemap.ping_search_engines # called for you when you use the rake task
end  