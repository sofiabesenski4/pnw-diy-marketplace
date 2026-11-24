# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Order confirmation email', type: :mailer do
  let(:store) { create(:store, name: 'PNW DIY Marketplace', mail_from_address: 'no-reply@pnwdiy.store') }
  let(:order) { create(:order_ready_to_complete, store:) }

  it 'is sent to the customer once the order is placed' do
    expect { order.complete! }
      .to have_enqueued_mail(Spree::OrderMailer, :confirm_email).with(order)

    perform_enqueued_jobs
    message = ActionMailer::Base.deliveries.last

    expect(message.to).to eq([order.email])
    expect(message.from).to eq(['no-reply@pnwdiy.store'])
    expect(message.subject).to include('PNW DIY Marketplace', order.number)
    expect(message.text_part.body.to_s).to include(order.display_total.to_s)
  end

  it 'is only sent once per order' do
    order.complete!

    expect { Spree::Bus.publish(:order_finalized, order:) }
      .not_to have_enqueued_mail(Spree::OrderMailer, :confirm_email)
  end
end
