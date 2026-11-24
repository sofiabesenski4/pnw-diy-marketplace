# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe Wallet::SkipAddingPaymentSources do
  it "is the class Solidus uses after checkout" do
    expect(Spree::Config.add_payment_sources_to_wallet_class).to eq(described_class)
  end

  it "does not save a reusable card to the wallet when the order completes" do
    user = create(:user)
    order = create(:order_ready_to_complete, user: user)
    source = order.payments.first.source
    source.update!(gateway_customer_profile_id: "BGS-WEFWF")
    expect(source).to be_reusable

    order.complete!

    expect(order.reload).to be_complete
    expect(user.wallet.wallet_payment_sources).to be_empty
  end
end
