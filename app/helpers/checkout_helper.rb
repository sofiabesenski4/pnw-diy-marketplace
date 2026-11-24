# frozen_string_literal: true

module CheckoutHelper
  def partial_name_with_fallback(prefix, partial_name, fallback_name = 'default')
    if lookup_context.find_all("#{prefix}/_#{partial_name}").any?
      "#{prefix}/#{partial_name}"
    else
      "#{prefix}/#{fallback_name}"
    end
  end

  # A pickup ship address holds the store's street. Prefill the delivery fields
  # with the customer's own address, so switching back to delivery does not
  # ship to the store.
  def ship_address_for_form(order)
    address = order.ship_address
    return address unless address&.pickup?

    saved = order.user&.ship_address
    form_address = saved && !saved.pickup? ? saved.dup : Spree::Address.build_default
    form_address.name = address.name
    form_address.phone = address.phone
    form_address
  end
end
