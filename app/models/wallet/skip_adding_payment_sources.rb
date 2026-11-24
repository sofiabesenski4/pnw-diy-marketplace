# frozen_string_literal: true

module Wallet
  # Replaces Spree::Wallet::AddPaymentSourcesToWallet so completed orders never
  # save their payment sources to the customer's wallet.
  class SkipAddingPaymentSources
    def initialize(order)
      @order = order
    end

    def add_to_wallet; end
  end
end
