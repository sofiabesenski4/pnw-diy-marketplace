# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Home layout', type: :request, with_signed_in_user: true do
  let(:user) { create(:user) }

  context "layout" do
    it "renders default layout" do
      get root_path
      expect(response).to render_template(layout: 'layouts/storefront')
    end
  end

  context "variant cards" do
    let(:color) { create(:option_type, name: "color", presentation: "Color") }
    let(:green) { create(:option_value, option_type: color, presentation: "Green") }
    let(:blue) { create(:option_value, option_type: color, presentation: "Blue") }
    let!(:hoodie) { create(:product, name: "Solidus hoodie", option_types: [color]) }
    let!(:green_hoodie) { create(:variant, product: hoodie, option_values: [green], price: 30) }
    let!(:blue_hoodie) { create(:variant, product: hoodie, option_values: [blue], price: 35) }
    let!(:mug) { create(:product, name: "Solidus mug", price: 12) }

    it "shows one card per variant, and one card for products without options" do
      get root_path

      aggregate_failures do
        expect(response.body).to include("variant_#{green_hoodie.id}")
        expect(response.body).to include("variant_#{blue_hoodie.id}")
        expect(response.body).to include("variant_#{mug.master.id}")
        expect(response.body).not_to include("variant_#{hoodie.master.id}")
        page = Nokogiri::HTML(response.body)
        expect(page.css("#variant_#{green_hoodie.id}").text.squish).to include("Green", "$30.00")
        expect(page.css("#variant_#{blue_hoodie.id}").text.squish).to include("Blue", "$35.00")
        expect(page.css("#variant_#{mug.master.id}").text.squish).to include("$12.00")
      end
    end

    it "hides variants without a price in the current currency" do
      blue_hoodie.prices.each { |price| price.update!(currency: "USD") }

      get root_path

      expect(response.body).not_to include("variant_#{blue_hoodie.id}")
    end

    it "hides variants of unavailable products" do
      hoodie.update!(available_on: 1.day.from_now)

      get root_path

      expect(response.body).not_to include("variant_#{green_hoodie.id}")
    end
  end
end
