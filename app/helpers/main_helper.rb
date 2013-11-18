module MainHelper
  def pricing_navigation_link
    # %a.btn.btn-primary.btn-large{ href: new_merchants_manager_registration_path } Get Started
    if merchants_manager_signed_in?
      link_to("Back to Pricing", merchants_upgrade_subscription_path, class: "btn btn-primary btn-large")
    else
      link_to("Get Started", new_merchants_manager_registration_path, class: "btn btn-primary btn-large")
    end
  end
end
