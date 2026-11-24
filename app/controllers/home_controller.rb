# frozen_string_literal: true

class HomeController < StoreController
  helper 'spree/products'
  respond_to :html

  # Lists every purchasable variant as its own card, so each colourway or
  # size shows its own image and price. Products without options appear once,
  # through their master variant.
  def index
    @variants = Spree::Variant
                .non_template_variants
                .where(product_id: Spree::Product.available.select(:id))
                .with_prices(current_pricing_options)
                .includes(:images, :prices, option_values: :option_type, product: { master: :images })
                .order(:product_id, :position)
                .page(params[:page])
                .per(Spree::Config.products_per_page)
  end
end
