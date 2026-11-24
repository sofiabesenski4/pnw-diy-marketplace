# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Default address country', :app_default_country, :with_signed_in_user, type: :request do
  let!(:canada) { create(:country, name: 'Canada', iso: 'CA', states_required: true) }
  let(:order) { create(:order_with_line_items, ship_address: nil, bill_address: nil) }
  let(:user) { order.user }

  it 'starts the checkout address forms on Canada' do
    order.update!(state: 'address')

    get checkout_state_path('address')

    expect(response).to have_http_status(:ok)
    expect(assigns(:order).bill_address.country).to eq(canada)
    expect(assigns(:order).ship_address.country).to eq(canada)
  end
end
