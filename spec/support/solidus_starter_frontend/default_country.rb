# frozen_string_literal: true

# The app defaults addresses to Canada, but the factories build a US-only
# store (US country, US states, US shipping zone). Keep specs on that store
# unless they opt in to the real default with `:app_default_country`.
RSpec.configure do |config|
  config.before do |example|
    next if example.metadata[:app_default_country]

    stub_spree_preferences(default_country_iso: 'US')
  end
end
