# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe "In-store pickup checkout", :js, type: :system do
  include SolidusStarterFrontend::System::CheckoutHelpers

  include_context 'checkout setup'

  let!(:pickup_store) do
    create(
      :stock_location,
      name: "Fernwood store",
      pickup_enabled: true,
      backorderable_default: false,
      address1: "1 Store St",
      city: "Victoria",
      zipcode: "12345",
      country:,
      state:
    )
  end
  let(:ship_street) { "order_ship_address_attributes_address1" }
  let(:order) { Spree::Order.last }

  before do
    create(:shipping_method, name: "In-store pickup", cost: 0, available_to_all: false, stock_locations: [pickup_store])
    shipping_method.update!(available_to_all: false, stock_locations: [stock_location])
    set_stock(Spree::StockItem.all, 5)

    add_mug_to_cart
    checkout_as_guest
    fill_in_billing_address
  end

  it "sends a pickup order to the chosen store" do
    expect(find("#order_use_billing")).to be_checked

    choose "Pick up at Fernwood store"

    expect(page).to have_no_field(ship_street).and have_no_field("order_use_billing")
    expect(page).to have_field("order_bill_address_attributes_address1", with: "143 Swan Street")

    fill_in "order_ship_address_attributes_name", with: "Sam Pickup"
    fill_in "order_ship_address_attributes_phone", with: "555-1234"
    click_button "Save and Continue"

    expect(page).to have_content("In-store pickup").and have_no_content("UPS Ground")

    expect(order.ship_address).to have_attributes(
      pickup_location: pickup_store,
      name: "Sam Pickup",
      phone: "555-1234",
      address1: "1 Store St"
    )
    expect(order.bill_address.address1).to eq("143 Swan Street")
    expect(order.shipments.map(&:stock_location)).to eq([pickup_store])
  end

  it "goes back to delivery without keeping the store" do
    choose "Pick up at Fernwood store"
    fill_in "order_ship_address_attributes_name", with: "Sam Pickup"
    fill_in "order_ship_address_attributes_phone", with: "555-1234"
    click_button "Save and Continue"
    expect(page).to have_content("In-store pickup")

    visit checkout_state_path(:address)
    expect(page).to have_checked_field("Pick up at Fernwood store")
    expect(page).to have_no_field(ship_street)

    choose "Ship to my address"
    expect(page).to have_field(ship_street, with: "")
    check "order_use_billing"
    click_button "Save and Continue"

    expect(page).to have_content("UPS Ground").and have_no_content("In-store pickup")
    expect(order.ship_address).not_to be_pickup
    expect(order.ship_address).to have_attributes(address1: "143 Swan Street", company: nil)
    expect(order.shipments.map(&:stock_location)).to eq([stock_location])
  end

  it "asks the customer to choose again when the store is out of stock" do
    set_stock(pickup_store.stock_items, 0)

    choose "Pick up at Fernwood store"
    fill_in "order_ship_address_attributes_name", with: "Sam Pickup"
    fill_in "order_ship_address_attributes_phone", with: "555-1234"
    click_button "Save and Continue"

    expect(page).to have_content("Fernwood store doesn't have everything in your order")
    expect(page).to have_current_path(checkout_state_path(:address))
    expect(order.line_items).not_to be_empty
  end

  private

  def set_stock(stock_items, count)
    stock_items.reload.each do |item|
      item.set_count_on_hand(count)
      item.update!(backorderable: false)
    end
  end

  def fill_in_billing_address
    address = "order_bill_address_attributes"
    fill_in "#{address}_name", with: "Ryan Bigg"
    fill_in "#{address}_address1", with: "143 Swan Street"
    fill_in "#{address}_city", with: "Richmond"
    select "United States of America", from: "#{address}_country_id"
    select "Alabama", from: "#{address}_state_id"
    fill_in "#{address}_zipcode", with: "12345"
    fill_in "#{address}_phone", with: "(555) 555-5555"
  end

  def add_mug_to_cart
    visit products_path
    click_link mug.name
    click_button "add-to-cart-button"
    expect(page).to have_current_path(cart_path)
  end
end
