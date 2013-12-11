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
    add '/marketing', :changefreq => 'weekly', :priority => 0.8
    add '/resources', :changefreq => 'weekly', :priority => 0.8
    add '/marketing/email-marketing', :changefreq => 'weekly', :priority => 0.8
    add '/marketing/email-marketing/mobile-responsive-emails', :changefreq => 'weekly', :priority => 0.8
    add '/marketing/email-marketing/capturing-customer-emails', :changefreq => 'weekly', :priority => 0.8
    add '/marketing/email-marketing/email-deliverability', :changefreq => 'weekly', :priority => 0.8
    add '/marketing/marketing-promotions', :changefreq => 'weekly', :priority => 0.8
    add '/marketing/coupons', :changefreq => 'weekly', :priority => 0.8
    add '/marketing/contests', :changefreq => 'weekly', :priority => 0.8
    add '/marketing/surveys', :changefreq => 'weekly', :priority => 0.8
    add '/marketing/specials-and-sales', :changefreq => 'weekly', :priority => 0.8
    add '/marketing/social-media-marketing', :changefreq => 'weekly', :priority => 0.8
    add '/marketing/marketing-automation', :changefreq => 'weekly', :priority => 0.8
    add '/marketing/marketing-ideas', :changefreq => 'weekly', :priority => 0.8
    add '/marketing/marketing-ideas', :changefreq => 'weekly', :priority => 0.8
    add '/marketing/online-marketing', :changefreq => 'weekly', :priority => 0.8
    add '/marketing/automated-marketing', :changefreq => 'weekly', :priority => 0.8
    add '/marketing/loyalty-marketing', :changefreq => 'weekly', :priority => 0.8
    add '/marketing/customer-retention', :changefreq => 'weekly', :priority => 0.8
    add '/marketing/marketing-analytics', :changefreq => 'weekly', :priority => 0.8
    add '/marketing/digital-marketing', :changefreq => 'weekly', :priority => 0.8
    add '/marketing/marketing-collaboration', :changefreq => 'weekly', :priority => 0.8
    add '/marketing/multi-channel-marketing', :changefreq => 'weekly', :priority => 0.8
    add '/marketing/integrated-marketing', :changefreq => 'weekly', :priority => 0.8
    # sell pages for keywords
    add '/marketing/free-email-marketing', :changefreq => 'weekly', :priority => 0.8
    add '/marketing/free-email-marketing-software', :changefreq => 'weekly', :priority => 0.8
    add '/marketing/free-newsletter-software', :changefreq => 'weekly', :priority => 0.8
    add '/marketing/mass-mail-software', :changefreq => 'weekly', :priority => 0.8
    add '/marketing/email-marketing-programs', :changefreq => 'weekly', :priority => 0.8
    add '/marketing/email-marketing-solutions', :changefreq => 'weekly', :priority => 0.8
    add '/marketing/email-blast-software', :changefreq => 'weekly', :priority => 0.8
    add '/marketing/bulk-email-software', :changefreq => 'weekly', :priority => 0.8
    add '/marketing/newsletter-software', :changefreq => 'weekly', :priority => 0.8
    add email_marketing_agency_path, :changefreq => 'weekly', :priority => 0.8
    add email_marketing_software_path, :changefreq => 'weekly', :priority => 0.8
    add free_email_marketing_software_path, :changefreq => 'weekly', :priority => 0.8
    #resource pages
    add '/resources/email-marketing', :changefreq => 'weekly', :priority => 0.8
    add '/resources/email-marketing/mobile-responsive-emails', :changefreq => 'weekly', :priority => 0.8
    add '/resources/email-marketing/capturing-customer-emails', :changefreq => 'weekly', :priority => 0.8
    add '/resources/email-marketing/capturing-customer-data', :changefreq => 'weekly', :priority => 0.8
    add '/resources/email-marketing/evolution-of-email-marketing', :changefreq => 'weekly', :priority => 0.8
    add '/resources/email-marketing/email-marketing-best-practices', :changefreq => 'weekly', :priority => 0.8
    add '/resources/email-marketing/email-marketing-tips', :changefreq => 'weekly', :priority => 0.8
    add '/resources/contests', :changefreq => 'weekly', :priority => 0.8
    add '/resources/coupons', :changefreq => 'weekly', :priority => 0.8
    add '/resources/surveys', :changefreq => 'weekly', :priority => 0.8
    add '/resources/social-media-marketing', :changefreq => 'weekly', :priority => 0.8
    add '/resources/digital-marketing', :changefreq => 'weekly', :priority => 0.8
    add '/resources/online-marketing', :changefreq => 'weekly', :priority => 0.8
    add '/resources/customer-retention', :changefreq => 'weekly', :priority => 0.8
    add '/resources/loyalty-marketing', :changefreq => 'weekly', :priority => 0.8
    add '/resources/marketing-analytics', :changefreq => 'weekly', :priority => 0.8
    add '/resources/marketing-automation', :changefreq => 'weekly', :priority => 0.8
    add '/resources/marketing-promotions', :changefreq => 'weekly', :priority => 0.8
    add '/resources/marketing-syndication', :changefreq => 'weekly', :priority => 0.8
    add '/resources/marketing-ideas', :changefreq => 'weekly', :priority => 0.8
    add '/resources/integrated-marketing', :changefreq => 'weekly', :priority => 0.8
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