# Be sure to restart your server when you modify this file.

if Rails.env.development? || Rails.env.test?
  Rails.application.config.session_store :cookie_store, key: '_aicrowd_session'
else
  Rails.application.config.session_store :cookie_store, key: '_aicrowd_session', domain: ENV['DOMAIN_NAME'].gsub("https://", "").gsub("http://", "").gsub("www.", "")
end
