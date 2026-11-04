# frozen_string_literal: true

require 'selenium/webdriver'
require 'capybara/rspec'
require 'capybara-screenshot/rspec'
require 'spree/testing_support/capybara_ext'

Capybara.default_max_wait_time = 10

# Chrome reports a node that left the page as an UnknownError instead of a stale
# element, so Capybara would fail instead of finding the node again.
module RetryDetachedNodes
  def invalid_element_errors
    super + [::Selenium::WebDriver::Error::UnknownError]
  end
end
Capybara::Selenium::Driver.prepend(RetryDetachedNodes)

RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by((ENV['CAPYBARA_DRIVER'] || :rack_test).to_sym)
  end

  config.before(:each, type: :system, js: true) do |example|
    screen_size = example.metadata[:screen_size] || [1800, 1400]
    driven_by(:selenium, using: :headless_chrome, screen_size: screen_size) do |capabilities|
      capabilities.add_argument("--disable-search-engine-choice-screen")
      # The browser is shared across examples. After a login, Chrome's password
      # manager can open a dialog that swallows keystrokes in later examples.
      capabilities.add_preference('credentials_enable_service', false)
      capabilities.add_preference('profile.password_manager_enabled', false)
      capabilities.add_preference('profile.password_manager_leak_detection', false)
    end
  end
end

Capybara.register_driver :selenium_chrome_headless_docker_friendly do |app|
  browser_options = ::Selenium::WebDriver::Chrome::Options.new
  browser_options.args << '--headless'
  browser_options.args << '--disable-gpu'
  browser_options.args << '--disable-search-engine-choice-screen'
  # Sandbox cannot be used inside unprivileged Docker container
  browser_options.args << '--no-sandbox'
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
end
