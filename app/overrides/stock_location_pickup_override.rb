# frozen_string_literal: true

# Warehouses and stores are both stock locations. Stores can offer pickup.
module StockLocationPickupOverride
  def self.prepended(base)
    base.scope :available_for_pickup, -> { active.where(pickup_enabled: true) }
  end

  Spree::StockLocation.prepend(self)
end
