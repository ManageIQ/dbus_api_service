require "simplecov"
SimpleCov.start

require "rack/test"
ENV["RACK_ENV"] = "test"

module RackTestMixin
  include Rack::Test::Methods
  def app
    described_class
  end
end

RSpec.configure do |config|
end

require "dbus_api_service"
