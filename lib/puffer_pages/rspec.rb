module PufferPages
  module Rspec

  end
end

RSpec.configure do |config|
  config.include PufferPages::Rspec::Matchers
end

RSpec::Rails::ControllerExampleGroup.send :include, PufferPages::Rspec::ViewRendering
