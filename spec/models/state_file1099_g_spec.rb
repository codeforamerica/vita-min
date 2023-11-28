# == Schema Information
#
# Table name: state_file1099_gs
#
#  id                          :bigint           not null, primary key
#  address_confirmation        :integer          default("unfilled"), not null
#  federal_income_tax_withheld :integer
#  had_box_11                  :integer          default("unfilled"), not null
#  intake_type                 :string           not null
#  payer_name                  :string
#  recipient                   :integer          default("unfilled"), not null
#  recipient_city              :string
#  recipient_state             :string
#  recipient_street_address    :string
#  recipient_zip               :string
#  state_income_tax_withheld   :integer
#  unemployment_compensation   :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  intake_id                   :bigint           not null
#
# Indexes
#
#  index_state_file1099_gs_on_intake  (intake_type,intake_id)
#
require 'rails_helper'

RSpec.describe StateFile1099G do
  describe "conditional attributes" do
    describe '#address_confirmation' do
      it 'clears address attributes if set to yes' do
        state_file_1099 = create(
          :state_file1099_g,
          intake: create(:state_file_ny_intake),
          address_confirmation: 'no',
          payer_name: 'Business',
          payer_street_address: '123 Main St',
          payer_city: 'New York',
          payer_zip: '11102',
          payer_tin: '123456789',
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
