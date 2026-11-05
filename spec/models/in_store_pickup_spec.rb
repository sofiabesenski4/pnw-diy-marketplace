# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe "In-store pickup", type: :model do
  let(:country) { create(:country) }
  let(:state) { create(:state, country:) }

  let!(:warehouse) { create(:stock_location, name: "Warehouse", country:, state:) }
  let!(:store) do
    create(
      :stock_location,
      name: "Fernwood store",
      pickup_enabled: true,
      backorderable_default: false,
      address1: "1 Store St",
      address2: nil,
      city: "Victoria",
      zipcode: "12345",
      country:,
      state:
    )
  end
  let!(:delivery_method) do
    create(:shipping_method, name: "UPS Ground", available_to_all: false, stock_locations: [warehouse])
  end
  let(:home_address) { create(:address, address1: "9 Home Rd", country:, state:) }

  before do
    create(:shipping_method, name: "In-store pickup", cost: 0, available_to_all: false, stock_locations: [store])
  end

  def set_stock(stock_items, count)
    stock_items.reload.each do |item|
      item.set_count_on_hand(count)
      item.update!(backorderable: false)
    end
  end

  def pickup_address(location = store, **attributes)
    Spree::Address.new(name: "Sam Customer", phone: "555-1234", pickup_location: location, **attributes)
  end

  describe Spree::Address do
    it "takes the street address from the store and keeps the customer's name and phone" do
      address = pickup_address

      expect(address).to be_valid
      expect(address).to be_pickup
      expect(address).to have_attributes(
        name: "Sam Customer",
        phone: "555-1234",
        company: "Fernwood store",
        address1: "1 Store St",
        city: "Victoria",
        zipcode: "12345",
        country:,
        state:
      )
    end

    it "ignores a street address sent with a store" do
      address = pickup_address(address1: "9 Home Rd", city: "Elsewhere")

      address.valid?

      expect(address).to have_attributes(address1: "1 Store St", city: "Victoria")
    end

    it "rejects a warehouse" do
      address = pickup_address(warehouse)

      expect(address).not_to be_valid
      expect(address.errors[:pickup_location]).to be_present
    end

    it "rejects an inactive store" do
      store.update!(active: false)

      expect(pickup_address).not_to be_valid
    end

    it "is never equal to the same customer's home address" do
      expect(pickup_address(store, **home_address.attributes.slice("address1", "city"))).not_to eq(home_address)
    end
  end

  describe Spree::Order do
    let(:order) { create(:order, bill_address: home_address, ship_address: home_address) }

    it "rejects a store as the billing address" do
      order.bill_address = pickup_address

      expect(order).not_to be_valid
      expect(order.errors[:bill_address]).to be_present
    end

    it "keeps the store when 'use billing address' is ticked" do
      order.update!(
        use_billing: true,
        ship_address_attributes: { name: "Sam Customer", phone: "555-1234", pickup_location_id: store.id }
      )

      expect(order.reload.ship_address.pickup_location).to eq(store)
    end

    it "drops the store's company name when switching back to delivery" do
      order.update!(ship_address: pickup_address)

      delivery_fields = %w[name address1 city zipcode phone country_id state_id]
      delivery_attributes = home_address.attributes.slice(*delivery_fields)

      order.update!(ship_address_attributes: delivery_attributes.merge("pickup_location_id" => ""))

      expect(order.reload.ship_address).not_to be_pickup
      expect(order.ship_address).to have_attributes(company: nil, address1: "9 Home Rd")
    end

    it "keeps the store when only name and phone are resubmitted" do
      order.update!(ship_address: pickup_address)
      ship_address = order.ship_address

      order.update!(ship_address_attributes: { name: "Sam Customer", phone: "555-1234", pickup_location_id: store.id })

      expect(order.reload.ship_address).to eq(ship_address)
    end
  end

  describe "fulfilment" do
    let!(:order) do
      create(
        :order_with_line_items,
        stock_location: warehouse,
        shipping_method: delivery_method,
        ship_address: home_address
      )
    end

    before { set_stock(Spree::StockItem.all, 5) }

    def proposed_shipments
      Spree::Stock::SimpleCoordinator.new(order).shipments
    end

    it "fulfils a pickup order from the chosen store with only the pickup rate" do
      order.update!(ship_address: pickup_address)

      shipments = proposed_shipments

      expect(shipments.map(&:stock_location)).to eq([store])
      expect(shipments.flat_map(&:shipping_rates).map(&:name)).to eq(["In-store pickup"])
    end

    it "never fulfils a delivery order from a store" do
      set_stock(store.stock_items, 100)

      shipments = proposed_shipments

      expect(shipments.map(&:stock_location)).to eq([warehouse])
      expect(shipments.flat_map(&:shipping_rates).map(&:name)).to eq(["UPS Ground"])
    end

    it "raises when the store is out of an item" do
      order.update!(ship_address: pickup_address)
      set_stock(store.stock_items, 0)

      expect { proposed_shipments }.to raise_error(Spree::Order::InsufficientStock)
    end

    it "uses the store's address for tax" do
      order.update!(ship_address: pickup_address)

      expect(order.tax_address.address1).to eq("1 Store St")
    end
  end

  describe "address book" do
    let(:user) { create(:user) }
    let(:order) { create(:order, user:, bill_address: home_address, ship_address: pickup_address) }

    it "does not save the store as the customer's address" do
      user.save_in_address_book(home_address.attributes, true)

      user.persist_order_address(order)

      expect(user.reload.ship_address).to eq(home_address)
      expect(user.bill_address).to eq(home_address)
      expect(user.addresses.select(&:pickup?)).to be_empty
    end
  end
end
