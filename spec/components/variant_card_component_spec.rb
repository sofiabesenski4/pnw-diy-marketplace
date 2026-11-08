# frozen_string_literal: true

require "solidus_starter_frontend_spec_helper"

RSpec.describe VariantCardComponent, type: :component do
  let(:product) { create(:product, name: "Wool hat", slug: "wool-hat") }
  let(:color) { create(:option_type, name: "color", presentation: "Color", position: 1) }
  let(:size) { create(:option_type, name: "size", presentation: "Size", position: 2) }
  let(:green) { create(:option_value, option_type: color, name: "green", presentation: "Green") }
  let(:small) { create(:option_value, option_type: size, name: "small", presentation: "S") }
  let(:variant) { create(:variant, product: product, option_values: [small, green], price: 42) }

  it "renders the variant name, options, price and a link that preselects the variant" do
    rendered = render_inline(described_class.new(variant, price: variant.default_price))

    aggregate_failures do
      expect(rendered.css("li").first[:id]).to eq("variant_#{variant.id}")
      expect(rendered.css(".product-card_header a").text).to include("Wool hat")
      expect(rendered.css(".product-card_options").text).to include("Green / S")
      expect(rendered.css(".product-card_price .price").text).to include("42.00")
      expect(rendered.css(".product-card_header a").first[:href]).to eq("/products/wool-hat?variant_id=#{variant.id}")
      expect(rendered.css(".product-card_image a").first[:href]).to eq("/products/wool-hat?variant_id=#{variant.id}")
    end
  end

  it "shows the variant's own image" do
    variant_image = create(:image, viewable: variant, alt: "Green hat")
    create(:image, viewable: product.master, alt: "Master hat")

    rendered = render_inline(described_class.new(variant.reload))

    expect(rendered.css(".product-card_image img").first[:alt]).to eq(variant_image.alt)
  end

  it "falls back to the master image when the variant has none" do
    create(:image, viewable: product.master, alt: "Master hat")

    rendered = render_inline(described_class.new(variant.reload))

    expect(rendered.css(".product-card_image img").first[:alt]).to eq("Master hat")
  end

  it "links to the plain product page for a master variant" do
    rendered = render_inline(described_class.new(product.master))

    aggregate_failures do
      expect(rendered.css(".product-card_header a").first[:href]).to eq("/products/wool-hat")
      expect(rendered.css(".product-card_options")).to be_empty
    end
  end
end
