# frozen_string_literal: true

module Spree
  # Featured products and related products for product pages.
  module ProductOverride
    extend ActiveSupport::Concern

    prepended do
      scope :featured, -> { where(featured: true) }
    end

    def similar_products(limit = 3)
      taxons.map do |taxon|
        taxon.all_products_except(id)
      end.flatten.uniq.first(limit)
    end

    Spree::Product.prepend(self)
  end
end
