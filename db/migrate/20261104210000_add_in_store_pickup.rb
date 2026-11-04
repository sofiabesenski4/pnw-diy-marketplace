# frozen_string_literal: true

# Stores can offer pickup, and a pickup address remembers which store holds the stock.
class AddInStorePickup < ActiveRecord::Migration[8.1]
  def change
    add_column :spree_stock_locations, :pickup_enabled, :boolean, default: false, null: false
    add_reference :spree_addresses, :pickup_location,
                  type: :integer,
                  foreign_key: { to_table: :spree_stock_locations }
  end
end
