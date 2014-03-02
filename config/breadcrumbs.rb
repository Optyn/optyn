crumb :root do
  link "<i class='icon-home'></i>
<span></span>".html_safe, root_path
end

crumb :marketing do
  link "Marketing Software<span></span>".html_safe, marketing_path
  parent :root
end

crumb :testimonial do
  link "Testimonial<span></span>".html_safe, alley_gallery_testimonial_path
  parent :root
end

crumb :terms do
  link "Terms of Use<span></span>".html_safe, terms_path
  parent :root
end

crumb :anti_spam_policy do
  link "Anti Spam Policy<span></span>".html_safe, terms_path
  parent :root
end

crumb :privacy_policy do
  link "Privacy Policy<span></span>".html_safe, privacy_path
  parent :root
end

crumb :sitemap do
  link "Sitemap <span></span>".html_safe, website_sitemap_path
  parent :root
end

crumb :profile_sitemap do
  link "Merchant Profile Sitemap <span></span>".html_safe, website_sitemap_path
  parent :sitemap
end

crumb :marketing_automation do
  link "Marketing Automation<span></span>".html_safe, marketing_automation_path
  parent :marketing
end

crumb :merchant_features do
  link "Features<span></span>".html_safe, merchant_features_path
  parent :marketing
end

crumb :tour do
  link "Tour<span></span>".html_safe, tour_page_path
  parent :marketing
end

crumb :pricing do
  link "Pricing<span></span>".html_safe, pricing_path
  parent :marketing
end

crumb :social_media_marketing do
  link "Social Media Marketing<span></span>".html_safe, social_media_marketing_path
  parent :marketing
end

crumb :marketing_ideas do
  link "Marketing Ideas<span></span>".html_safe, marketing_ideas_path
  parent :marketing
end

crumb :online_marketing do
  link "Online Marketing<span></span>".html_safe, online_marketing_path
  parent :marketing
end

crumb :automated_marketing do
  link "Automated Marketing<span></span>".html_safe, automated_marketing_path
  parent :marketing
end

crumb :loyalty_marketing do
  link "Loyalty Marketing<span></span>".html_safe, loyalty_marketing_path
  parent :marketing
end

crumb :customer_retention do
  link "Customer Retention<span></span>".html_safe, customer_retention_path
  parent :marketing
end

crumb :marketing_analytics do
  link "Marketing Analytics<span></span>".html_safe, marketing_analytics_path
  parent :marketing
end

crumb :digital_marketing do
  link "Digital Marketing<span></span>".html_safe, digital_marketing_path
  parent :marketing
end

crumb :marketing_collaboration do
  link "Marketing Collaboration<span></span>".html_safe, marketing_collaboration_path
  parent :marketing
end

crumb :integrated_marketing do
  link "Integrated Marketing<span></span>".html_safe, integrated_marketing_path
  parent :marketing
end


crumb :marketing_promotions do
  link "Marketing Promotions<span></span>".html_safe, marketing_promotions_path
  parent :marketing
end

crumb :marketing_promotions_coupon do
  link "Marketing Promotions<span></span>".html_safe, marketing_promotions_path
  parent :marketing
end

crumb :coupons do
  link "Coupon Marketing<span></span>".html_safe, coupons_path
  parent :marketing_promotions_coupon
end

crumb :contests do
  link "Contest Marketing<span></span>".html_safe, contests_path
  parent :marketing_promotions_coupon
end

crumb :surveys do
  link "Survey Marketing<span></span>".html_safe, surveys_path
  parent :marketing_promotions_coupon
end

crumb :specials do
  link "Specials<span></span>".html_safe, specials_path
  parent :marketing_promotions_coupon
end



crumb :multi_channel_marketing do
  link "Multi Channel Marketing<span></span>".html_safe, multi_channel_marketing_path
  parent :marketing
end

crumb :marketing_syndication do
  link "Marketing Syndication<span></span>".html_safe, marketing_syndication_path
  parent :marketing
end

crumb :email_marketing do
  link "Email Marketing<span></span>".html_safe, email_marketing_path
  parent :marketing
end



crumb :mobile_responsive_emails do
  link "Mobile Responsive Emails<span></span>".html_safe, mobile_responsive_path
  parent :email_marketing
end

crumb :bulk_email_software do
  link "Bulk Email Software<span></span>".html_safe, bulk_email_software_path
  parent :email_marketing
end

crumb :email_blast_software do
  link "Email Blast Software<span></span>".html_safe, email_blast_software_path
  parent :email_marketing
end

crumb :email_marketing_agency do
  link "Email Marketing Agency<span></span>".html_safe, email_marketing_agency_path
  parent :email_marketing
end

crumb :email_marketing_programs do
  link "Email Marketing Programs<span></span>".html_safe, email_marketing_programs_path
  parent :email_marketing
end

crumb :email_marketing_software do
  link "Email Marketing Software<span></span>".html_safe, email_marketing_software_path
  parent :email_marketing
end

crumb :email_marketing_solutions do
  link "Email Marketing Solutions<span></span>".html_safe, email_marketing_solutions_path
  parent :email_marketing
end

crumb :free_email_marketing do
  link "Free Email Marketing<span></span>".html_safe, free_email_marketing_path
  parent :email_marketing
end

crumb :free_email_marketing_software do
  link "Free Email Marketing Software<span></span>".html_safe, free_email_marketing_software_path
  parent :email_marketing
end

crumb :free_newsletter_software do
  link "Free Newsletter Software<span></span>".html_safe, free_newsletter_software_path
  parent :email_marketing
end

crumb :mass_mail_software do
  link "Mass Mail Software<span></span>".html_safe, mass_mail_software_path
  parent :email_marketing
end

crumb :newsletter_software do
  link "Newsletter Software<span></span>".html_safe, mass_mail_software_path
  parent :email_marketing
end



crumb :capturing_data do
  link "Capturing Customer Emails<span></span>".html_safe, capturing_data_path
  parent :email_marketing
end

crumb :email_deliverability do
  link "Email Deliverability<span></span>".html_safe, email_deliverability_path
  parent :email_marketing
end



#resources

crumb :resources do
  link "Marketing Resources<span></span>".html_safe, resources_path
  parent :root
end


crumb :resources_email_marketing do
  link "Email Marketing<span></span>".html_safe, resources_email_marketing_path
  parent :resources
end

crumb :resources_social_media do
  link "Social Media Marketing<span></span>".html_safe, resources_social_media_path
  parent :resources
end

crumb :resources_marketing_automation do
  link "Marketing Automation<span></span>".html_safe, resources_marketing_automation_path
  parent :resources
end

crumb :resources_marketing_syndication do
  link "Marketing Syndication<span></span>".html_safe, resources_marketing_syndication_path
  parent :resources
end

crumb :resources_loyalty_marketing do
  link "Loyalty Marketing<span></span>".html_safe, resources_loyalty_marketing_path
  parent :resources
end

crumb :resources_marketing_analytics do
  link "Marketing Analytics<span></span>".html_safe, resources_marketing_analytics_path
  parent :resources
end

crumb :resources_marketing_ideas do
  link "Marketing Ideas<span></span>".html_safe, resources_marketing_ideas_path
  parent :resources
end

crumb :resources_integrated_marketing do
  link "Integrated Marketing<span></span>".html_safe, resources_integrated_marketing_path
  parent :resources
end



crumb :resources_digital_marketing do
  link "Digital Marketing<span></span>".html_safe, resources_digital_marketing_path
  parent :resources
end

crumb :resources_online_marketing do
  link "Online Marketing<span></span>".html_safe, resources_online_marketing_path
  parent :resources
end

crumb :resources_customer_retention do
  link "Customer Retention<span></span>".html_safe, resources_customer_retention_path
  parent :resources
end

crumb :resources_marketing_promotions do
  link "Marketing Promotions<span></span>".html_safe, resources_marketing_promotions_path
  parent :resources
end

crumb :resources_reachable_audience do
  link "Reachable Audience<span></span>".html_safe, resources_reachable_audience_path
  parent :resources
end

crumb :resources_contests do
  link "Running Contests<span></span>".html_safe, resources_contests_path
  parent :resources_marketing_promotions
end

crumb :resources_coupons do
  link "Marketing with Coupons<span></span>".html_safe, resources_coupons_path
  parent :resources_marketing_promotions
end

crumb :resources_surveys do
  link "Surveys<span></span>".html_safe, resources_surveys_path
  parent :resources_marketing_promotions
end

crumb :resources_specials_sales do
  link "Running Specials and Sales<span></span>".html_safe, resources_specials_sales_path
  parent :resources_marketing_promotions
end






crumb :resources_mobile_responsive_emails do
  link "Mobile Responsive Design<span></span>".html_safe, resources_mobile_responsive_emails_path
  parent :resources_email_marketing
end

crumb :resources_capturing_customer_emails do
  link "How to capture customer emails.<span></span>".html_safe, resources_mobile_responsive_emails_path
  parent :resources_email_marketing
end


crumb :resources_capturing_customer_data do
  link "Capture Customer Data.<span></span>".html_safe, resources_capturing_customer_data_path
  parent :resources_email_marketing
end

crumb :resources_evolution_email do
  link "Evolution of Email Marketing<span></span>".html_safe, resources_evolution_email_path
  parent :resources_email_marketing
end

crumb :resources_email_marketing_tips do
  link "Email Marketing Tips<span></span>".html_safe, resources_email_marketing_tips_path
  parent :resources_email_marketing
end

crumb :resources_best_practices do
  link "Email Marketing Best Practices<span></span>".html_safe, resources_best_practices_path
  parent :resources_email_marketing
end

crumb :resources_measuring_success do
  link "Measuring Success<span></span>".html_safe, resources_measuring_success_path
  parent :resources_email_marketing
end

crumb :resources_getting_started do
  link "Getting Started with Email Marketing<span></span>".html_safe, resources_getting_started_path
  parent :resources_email_marketing
end

crumb :resources_email_marketing_types do
  link "Different Types of Emails<span></span>".html_safe, resources_email_marketing_types_path
  parent :resources_email_marketing
end

crumb :resources_best_bulk_email_software do
  link "Best Bulk Email Software<span></span>".html_safe, resources_best_bulk_email_software_path
  parent :resources_email_marketing
end

crumb :resources_best_email_marketing do
  link "Best Email Marketing<span></span>".html_safe, resources_best_email_marketing_path
  parent :resources_email_marketing
end

crumb :resources_best_email_marketing_software do
  link "Best Email Marketing Software<span></span>".html_safe, resources_best_email_marketing_software_path
  parent :resources_email_marketing
end

crumb :resources_best_free_email_marketing do
  link "Best Free Email Marketing<span></span>".html_safe, resources_best_free_email_marketing_path
  parent :resources_email_marketing
end

crumb :resources_best_newsletter_software do
  link "Best Newsletter Software<span></span>".html_safe, resources_best_newsletter_software_path
  parent :resources_email_marketing
end

crumb :resources_bulk_email do
  link "Bulk Email<span></span>".html_safe, resources_bulk_email_path
  parent :resources_email_marketing
end

crumb :resources_catchy_email_subject_lines do
  link "Catchy Email Subject Lines<span></span>".html_safe, resources_catchy_email_subject_lines_path
  parent :resources_email_marketing
end

crumb :resources_cheap_email_marketing do
  link "Cheap Email Marketing<span></span>".html_safe, resources_cheap_email_marketing_path
  parent :resources_email_marketing
end

crumb :resources_direct_email_marketing do
  link "Direct Email Marketing<span></span>".html_safe, resources_direct_email_marketing_path
  parent :resources_email_marketing
end

crumb :resources_email_advertising do
  link "Email Advertising<span></span>".html_safe, resources_email_advertising_path
  parent :resources_email_marketing
end

crumb :resources_email_blast do
  link "Email Blast<span></span>".html_safe, resources_email_blast_path
  parent :resources_email_marketing
end

crumb :resources_email_broadcast do
  link "Email Broadcast<span></span>".html_safe, resources_email_broadcast_path
  parent :resources_email_marketing
end

crumb :resources_email_campaign do
  link "Email Campaign<span></span>".html_safe, resources_email_campaign_path
  parent :resources_email_marketing
end

crumb :resources_email_marketing_online do
  link "Email Marketing Online<span></span>".html_safe, resources_email_marketing_online_path
  parent :resources_email_marketing
end

crumb :resources_email_marketing_stats do
  link "Email Marketing Stats<span></span>".html_safe, resources_email_marketing_stats_path
  parent :resources_email_marketing
end

crumb :resources_email_marketing_strategy do
  link "Email Marketing Strategy<span></span>".html_safe, resources_email_marketing_strategy_path
  parent :resources_email_marketing
end

crumb :resources_email_marketing_system do
  link "Email Marketing System<span></span>".html_safe, resources_email_marketing_system_path
  parent :resources_email_marketing
end

crumb :resources_email_newsletter do
  link "Email Newsletter<span></span>".html_safe, resources_email_newsletter_path
  parent :resources_email_marketing
end

crumb :resources_email_templates do
  link "Email Templates<span></span>".html_safe, resources_email_templates_path
  parent :resources_email_marketing
end

crumb :resources_email_types do
  link "Email Types<span></span>".html_safe, resources_email_types_path
  parent :resources_email_marketing
end

crumb :resources_follow_up_emails do
  link "Follow Up Emails<span></span>".html_safe, resources_follow_up_emails_path
  parent :resources_email_marketing
end

crumb :resources_how_to_email_marketing do
  link "How to Email Marketing<span></span>".html_safe, resources_how_to_email_marketing_path
  parent :resources_email_marketing
end

crumb :resources_mass_email do
  link "Mass Email<span></span>".html_safe, resources_mass_email_path
  parent :resources_email_marketing
end

crumb :resources_opt_in_email_marketing do
  link "Opt In Email Marketing<span></span>".html_safe, resources_opt_in_email_marketing_path
  parent :resources_email_marketing
end

crumb :resources_small_business_email_marketing do
  link "Small Business Email Marketing<span></span>".html_safe, resources_small_business_email_marketing_path
  parent :resources_email_marketing
end

crumb :resources_top_email_marketing do
  link "Top Email Marketing<span></span>".html_safe, resources_top_email_marketing_path
  parent :resources_email_marketing
end

crumb :resources_top_email_marketing_software do
  link "Top Email Marketing Software<span></span>".html_safe, resources_top_email_marketing_software_path
  parent :resources_email_marketing
end

crumb :resources_what_is_email_marketing do
  link "What is Email Marketing<span></span>".html_safe, resources_what_is_email_marketing_path
  parent :resources_email_marketing
end



# crumb :project do |project|
#   link project.name, project_path(project)
#   parent :projects
# end

# crumb :project_issues do |project|
#   link "Issues", project_issues_path(project)
#   parent :project, project
# end

# crumb :issue do |issue|
#   link issue.title, issue_path(issue)
#   parent :project_issues, issue.project
# end

# If you want to split your breadcrumbs configuration over multiple files, you
# can create a folder named `config/breadcrumbs` and put your configuration
# files there. All *.rb files (e.g. `frontend.rb` or `products.rb`) in that
# folder are loaded and reloaded automatically when you change them, just like
# this file (`config/breadcrumbs.rb`).