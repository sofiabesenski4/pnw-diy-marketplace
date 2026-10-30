# frozen_string_literal: true

class LinkToCartComponent < ViewComponent::Base
  delegate :current_order, :spree, to: :helpers

  LINK_CLASSES = %w[
    inline-flex items-center whitespace-nowrap gap-1.5 sm:gap-2 min-h-[44px] px-2.5 sm:px-3.5 py-2.5
    bg-ink text-paper rounded-[3px_10px_4px_8px] no-underline dark:bg-sand dark:text-ink
  ].join(' ')

  ICON = <<~SVG
    <svg class="w-5 h-5 shrink-0" viewBox="0 0 24 24" aria-hidden="true"><path d="M4 8 L20 7.6 L18.6 21 L5.4 21.2 Z M8.6 8 C8.4 4.6 10 2.9 12 3 C14 3.1 15.6 4.6 15.4 7.8" fill="none" stroke="currentColor" stroke-width="2" stroke-linejoin="round" stroke-linecap="round"></path></svg>
  SVG

  def call
    link_to cart_path, class: "cart-info #{css_class} #{LINK_CLASSES}", title: I18n.t('spree.cart') do
      safe_join(
        [
          ICON.html_safe,
          content_tag(:span, I18n.t('spree.cart'), class: 'hidden sm:inline'),
          content_tag(:span, "(#{item_count})", class: 'link-text')
        ]
      )
    end
  end

  private

  def item_count
    empty_current_order? ? 0 : current_order.item_count
  end

  def css_class
    empty_current_order? ? 'empty' : 'full'
  end

  def empty_current_order?
    current_order.nil? || current_order.item_count.zero?
  end
end
