# frozen_string_literal: true

# Keeps a pickup order's ship address pointed at the chosen store.
module OrderPickupOverride
  def self.prepended(base)
    base.validate :bill_address_is_not_a_pickup_location
  end

  # Solidus merges new address fields onto the current ship address. When a
  # customer switches from pickup back to delivery, merging would keep the
  # store's company name, so start from a clean address instead.
  def ship_address_attributes=(attributes)
    new_attributes = attributes.to_h.stringify_keys
    switching_to_delivery = ship_address&.pickup? &&
                            new_attributes.key?("pickup_location_id") &&
                            new_attributes["pickup_location_id"].blank?

    if switching_to_delivery
      self.ship_address = Spree::Address.immutable_merge(nil, attributes)
    else
      super
    end
  end

  private

  # Bill and ship addresses share permitted attributes, so a store could
  # otherwise be submitted as the billing address.
  def bill_address_is_not_a_pickup_location
    errors.add(:bill_address, :invalid) if bill_address&.pickup?
  end

  # "Use billing address" would copy the billing address over the store and
  # silently turn a pickup order back into a delivery.
  def use_billing?
    super && !ship_address&.pickup?
  end

  Spree::Order.prepend(self)
end
