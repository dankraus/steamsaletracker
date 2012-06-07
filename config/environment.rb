# Load the rails application
require File.expand_path('../application', __FILE__)

# Load heroku vars from local file
heroku_env = File.join('config', 'heroku_env.rb')
load(heroku_env) if File.exists?(heroku_env)

# Initialize the rails application
SteamSaleTracker::Application.initialize!

# Configuration for using SendGrid on Heroku
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
	:user_name => ENV['SENDGRID_USERNAME'],
	:password => ENV['SENDGRID_PASSWORD'],
	:domain => "steamsaletracker.com",
	:address => "smtp.sendgrid.net",
	:port => 587,
	:authentication => :plain,
	:enable_starttls_auto => true
}