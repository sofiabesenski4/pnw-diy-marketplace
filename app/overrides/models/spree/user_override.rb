# frozen_string_literal: true

module Spree
  # Keeps stores out of the customer's saved addresses.
  module UserOverride
    extend ActiveSupport::Concern

    # Solidus saves the order's ship address as the customer's default. A store
    # must not become the default, or the next delivery would go to the store.
    def persist_order_address(order)
      return super unless order.ship_address&.pickup?

      if order.bill_address
        address = save_in_address_book(
          order.bill_address.attributes,
          Spree::Config.automatic_default_address,
          :billing
        )
        self.bill_address_id = address.id if address&.persisted?
      end

      save!
    end

    Spree::User.prepend(self)
  end
end
