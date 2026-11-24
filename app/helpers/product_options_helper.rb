# frozen_string_literal: true

module ProductOptionsHelper
  def product_variants_with_options(product)
    product.variants_and_option_values_for(current_pricing_options)
  end

  # The variant checked when the product page loads: the one the shopper
  # clicked on a variant card, otherwise the first one.
  def initial_variant(product, selected_variant = nil)
    variants = product_variants_with_options(product)
    variants.find { |variant| variant == selected_variant } || variants.first
  end

  def sorted_option_values(variant)
    variant.option_values.sort_by { |value| value.option_type.position }.map(&:id)
  end

  def sorted_option_types(product)
    product.option_types.sort_by(&:position)
  end

  # move to model
  def option_values(product:, option_type:)
    product.variants.map do |variant|
      variant.option_values.find { |option_value| option_value.option_type_id == option_type.id }
    end.compact.uniq
  end
end
