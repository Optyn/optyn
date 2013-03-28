module Merchants::MerchantManagersHelper
  def format_managers_created_at(time)
    time.strftime(" %m/%d/%Y %I:%M%p" )
  end
end
