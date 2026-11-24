window.addEventListener('DOMContentLoaded', () => {
  if (document.getElementById('checkout_form_address')) {
    // Hidden by default to support browsers with javascript disabled
    document.querySelectorAll('.js-address-fields')
      .forEach(field => field.style.display = 'block');

    const statesCache = {};

    function updateState(stateContainer, countryId) {
      if (statesCache[countryId]) {
        fillStates(stateContainer, countryId);
        return;
      }

      fetch(`${Solidus.routes.states_search}?country_id=${countryId}`)
        .then(response => response.json())
        .then(data => {
          statesCache[countryId] = {
            states: data.states,
            states_required: data.states_required
          };
          fillStates(stateContainer, countryId);
        });
    };

    function fillStates(stateContainer, countryId) {
      // Pickup hides the street fields. Leave their state field disabled.
      if (stateContainer.closest('[data-street-field]')?.style.display === 'none') {
        return;
      }

      const stateData = statesCache[countryId];

      if (!stateData) {
        return;
      }

      const statesRequired = stateData.states_required;
      const states = stateData.states;

      const stateSelect = stateContainer.querySelector('select');
      const stateInput = stateContainer.querySelector('input');

      if (states.length > 0) {
        const selected = parseInt(stateSelect.value);
        stateSelect.innerHTML = '';
        const statesWithBlank = [{ name: '', id: ''}].concat(states);
        statesWithBlank.forEach(state => {
          const selectOption = document.createElement('option');
          selectOption.value = state.id;
          selectOption.innerHTML = state.name;
          if (selected === state.id) {
            selectOption.setAttribute('selected', true);
          }
          stateSelect.appendChild(selectOption);
        })
        stateSelect.style.display = 'block';
        stateSelect.removeAttribute('disabled');
        stateInput.style.display = 'none';
        stateInput.setAttribute('disabled', true);
        stateContainer.style.display = 'block';
        if (statesRequired) {
          stateSelect.classList.add('required');
          stateContainer.classList.add('field-required');
        } else {
          stateSelect.classList.remove('required');
          stateContainer.classList.remove('field-required');
        }
        stateInput.classList.remove('required');
      } else {
        stateSelect.style.display = 'none';
        stateSelect.setAttribute('disabled', true);
        stateInput.style.display = 'block';
        if (statesRequired) {
          stateContainer.classList.add('field-required');
          stateInput.classList.add('required');
        } else {
          stateInput.value = '';
          stateContainer.classList.remove('field-required');
          stateInput.classList.remove('required');
        }
        stateContainer.style.display = !!statesRequired ? 'block' : 'none';
        if (!statesRequired) {
          stateInput.setAttribute('disabled', true);
        } else {
          stateInput.removeAttribute('disabled');
        }
        stateSelect.classList.remove('required');
      }
    };

    document.querySelectorAll('.js-trigger-state-change').forEach(element => {
      element.addEventListener('change', () => {
        const stateContainer = document.querySelector(element.dataset.stateContainer);
        if (stateContainer) {
          const countryId = element.value;
          updateState(stateContainer, countryId);
        }
      });
    });

    document.querySelectorAll('.js-trigger-state-change:not([hidden])').forEach(element => {
      element.dispatchEvent(new Event('change'));
    });

    const orderUseBilling = document.getElementById('order_use_billing');
    orderUseBilling.addEventListener('change', function() {
      update_shipping_form_state(orderUseBilling);
    });

    const isPickup = () =>
      document.querySelector('[data-pickup-choice]:checked')?.dataset.pickupChoice === 'store';

    // Pickup orders ship to the store. The server copies the store's street,
    // so only the customer's name and phone are sent.
    function update_shipping_form_state(order_use_billing) {
      const pickup = isPickup();
      if (pickup) order_use_billing.checked = false;
      order_use_billing.closest('label').style.display = pickup ? 'none' : '';
      const useBilling = order_use_billing.checked;

      document.querySelectorAll('#shipping .address-inputs').forEach(addressInput => {
        addressInput.style.display = useBilling ? 'none' : '';
      });

      document.querySelectorAll('#shipping [data-street-field]').forEach(wrapper => {
        wrapper.style.display = pickup ? 'none' : '';
      });

      document.querySelectorAll('#shipping .address-inputs input, #shipping .address-inputs select')
        .forEach(input => {
          input.disabled = useBilling || (pickup && !!input.closest('[data-street-field]'));
        });

      if (!useBilling && !pickup) {
        document.querySelector('#shipping .js-trigger-state-change').dispatchEvent(new Event('change'));
      }
    };

    document.querySelectorAll('[data-pickup-choice]').forEach(radio => {
      radio.addEventListener('change', () => update_shipping_form_state(orderUseBilling));
    });

    update_shipping_form_state(orderUseBilling);
  }
});
