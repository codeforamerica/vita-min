require 'rails_helper'

RSpec.describe StateFile1099G do
  describe "conditional attributes" do
    describe '#payer_name_is_default' do
      it 'clears payer_name if set to yes' do
        state_file_1099 = create(:state_file1099_g, intake: create(:state_file_ny_intake), payer_name_is_default: 'no', payer_name: 'Steve')
        state_file_1099.payer_name_is_default = 'yes'
        expect do
          state_file_1099.save
        end.to change { state_file_1099.payer_name }.to(nil)
      end
    end

    describe '#address_confirmation' do
      it 'clears address attributes if set to yes' do
        state_file_1099 = create(
          :state_file1099_g,
          intake: create(:state_file_ny_intake),
          address_confirmation: 'no',
          recipient_city: 'New York',
          recipient_state: 'New York',
          recipient_street_address: '123 Main St',
          recipient_zip: '11102',
        )
        state_file_1099.address_confirmation = 'yes'
        state_file_1099.save
        expect(state_file_1099.recipient_city).to be_nil
        expect(state_file_1099.recipient_state).to be_nil
        expect(state_file_1099.recipient_street_address).to be_nil
        expect(state_file_1099.recipient_zip).to be_nil
      end
    end
  end
end
