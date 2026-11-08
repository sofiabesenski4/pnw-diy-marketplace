# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Product', type: :request, with_signed_in_user: true do
  let!(:product) { create(:product, available_on: 1.year.from_now) }
  let(:user) { create(:user) }

  context 'when not admin user' do
    it "cannot view non-active products" do
      get product_path(product.to_param)

      expect(response.status).to eq(404)
    end

    it "provides the current user to the searcher class" do
      get products_path

      expect(assigns[:searcher].current_user).to eq user
      expect(response.status).to eq(200)
    end
  end

  context 'when an admin' do
    let(:user) { create(:admin_user) }

    # Regression test for https://github.com/spree/spree/issues/1390
    it "allows admins to view non-active products" do
      get product_path(id: product.to_param)
      expect(assigns[:products]).to include(product)
      expect(response.status).to eq(200)
    end

    # Regression test for https://github.com/spree/spree/issues/2249
    it "doesn't error when given an invalid referer" do
      # Previously a URI::InvalidURIError exception was being thrown
      get product_path(product.to_param), headers: { 'HTTP_REFERER' => 'not|a$url' }
    end
  end

  context "when a variant_id is passed" do
    let(:color) { create(:option_type, name: "color", presentation: "Color") }
    let(:green) { create(:option_value, option_type: color, presentation: "Green") }
    let(:blue) { create(:option_value, option_type: color, presentation: "Blue") }
    let!(:hoodie) { create(:product, name: "Solidus hoodie", option_types: [color]) }
    let!(:green_hoodie) { create(:variant, product: hoodie, option_values: [green]) }
    let!(:blue_hoodie) { create(:variant, product: hoodie, option_values: [blue]) }

    def checked_value(page, name)
      page.css("input[name='#{name}'][checked]").pluck(:value)
    end

    it "preselects that variant and its option values" do
      get product_path(hoodie, variant_id: blue_hoodie.id)
      page = Nokogiri::HTML(response.body)

      aggregate_failures do
        expect(checked_value(page, "variant_id")).to eq([blue_hoodie.id.to_s])
        expect(checked_value(page, "color")).to eq([blue.id.to_s])
        expect(page.css("#selected-color").text.strip).to eq("Blue")
      end
    end

    it "preselects the first variant without a variant_id" do
      get product_path(hoodie)
      page = Nokogiri::HTML(response.body)

      expect(checked_value(page, "variant_id")).to eq([green_hoodie.id.to_s])
    end

    it "ignores a variant_id from another product" do
      get product_path(hoodie, variant_id: create(:variant).id)
      page = Nokogiri::HTML(response.body)

      expect(checked_value(page, "variant_id")).to eq([green_hoodie.id.to_s])
    end
  end

  context "when invalid search params are passed" do
    it "raises ActionController::BadRequest" do
      get products_path, params: { search: "blurb" }
      expect(response.status).to eq(400)
    end
  end
end
