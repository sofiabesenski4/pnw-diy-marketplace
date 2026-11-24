# frozen_string_literal: true

require 'stripe'
require 'solidus_starter_frontend_spec_helper'

Dir["#{__dir__}/support/solidus_stripe/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.include SolidusStripe::Webhook::RequestHelper, type: :webhook_request

  # These specs drive Stripe's hosted card form against Stripe's test API.
  # They can only pass with real Stripe test keys in the environment.
  config.before(:each, :stripe_api) do
    skip 'Set SOLIDUS_STRIPE_* test keys to run specs against the Stripe API' if ENV['SOLIDUS_STRIPE_API_KEY'].blank?
  end
end
