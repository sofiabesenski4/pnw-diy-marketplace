# frozen_string_literal: true

# Pickup orders are fulfilled only from the chosen store. Delivery orders never
# take stock off store shelves.
class PickupLocationFilter < Spree::Stock::LocationFilter::Base
  def filter
    active = stock_locations.active
    pickup_location_id = order.ship_address&.pickup_location_id

    if pickup_location_id
      active.where(id: pickup_location_id, pickup_enabled: true)
    else
      active.where(pickup_enabled: false)
    end
  end
end
