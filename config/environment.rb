# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Optyn::Application.initialize!

HUMAN_DATE_FORMAT = '%m/%d/%Y'
HUMAN_TIME_FORMAT = '%m/%d/%Y %H:%M:%S'
ActionMailer::Base.delivery_method = :sendmail
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.raise_delivery_errors = true