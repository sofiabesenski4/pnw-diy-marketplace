# frozen_string_literal: true

# A pickup address is the customer's name and phone at a store's street address.
module AddressPickupOverride
  def self.prepended(base)
    base.belongs_to :pickup_location, class_name: "Spree::StockLocation", optional: true
    base.before_validation :copy_pickup_location_address, if: :pickup_location
    base.validate :pickup_location_accepts_pickup, if: :pickup_location
  end

  def pickup?
    pickup_location_id.present?
  end

  private

  # The customer only chooses a store. Taking the street fields from the
  # browser would let someone pair their home address with a store ID.
  def copy_pickup_location_address
    self.company = pickup_location.name
    self.address1 = pickup_location.address1
    self.address2 = pickup_location.address2
    self.city = pickup_location.city
    self.zipcode = pickup_location.zipcode
    self.country_id = pickup_location.country_id
    self.state_id = pickup_location.state_id
    self.state_name = pickup_location.state_name
  end

  def pickup_location_accepts_pickup
    return if pickup_location.active? && pickup_location.pickup_enabled?

    errors.add(:pickup_location, :invalid)
  end

  Spree::Address.prepend(self)
end
