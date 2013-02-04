PufferPages.setup do |config|
  config.localize = ENV['LOCALIZE'] != 'false'
  config.access_token = 'token'
end
