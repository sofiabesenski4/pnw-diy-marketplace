# frozen_string_literal: true

# A product card for a single variant. It shows the variant's own image and
# price, and links to the product page with that variant preselected.
# Reuses the ProductCardComponent template.
class VariantCardComponent < ProductCardComponent
  def initialize(variant, price: variant.default_price, **)
    @variant = variant
    super(variant.product, price: price, **)
  end

  attr_reader :variant

  def main_image
    variant.gallery.images.first
  end

  def card_path
    return product_path(product) if variant.is_master?

    product_path(product, variant_id: variant.id)
  end

  def card_dom_id
    "variant_#{variant.id}"
  end

  def options_label
    variant.option_values
           .sort_by { |option_value| option_value.option_type.position }
           .map(&:presentation)
           .join(" / ")
  end
end
