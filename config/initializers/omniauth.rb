Rails.application.config.middleware.use OmniAuth::Builder do
  #provider :steam, :api_key => '4C648E197A23479682AA2D4C21DE2BBA'
  #provider :steam, ENV['4C648E197A23479682AA2D4C21DE2BBA']
  provider :steam, '4C648E197A23479682AA2D4C21DE2BBA'
  #provider :facebook, '259767311485', 'bce150eb47de6b7515bde35604e5b085'
end
