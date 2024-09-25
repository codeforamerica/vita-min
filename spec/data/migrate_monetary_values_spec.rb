require 'rails_helper'
require Rails.root.join('db/data/20240918164810_backfill_new_decimal_columns.rb')

RSpec.describe MigrateMonetaryValues do
  let(:intake) { create(:state_file_az_intake,
                        charitable_cash: 100,
                        charitable_noncash: 200,
                        household_excise_credit_claimed_amt: 300,
                        tribal_wages: 400,
                        armed_forces_wages: 500
  ) }

  let!(:w2) { create(:state_file_w2,
                     state_file_intake: intake,
                     employer_state_id_num: "001245788",
                     local_income_tax_amt: 200,
                     local_wages_and_tips_amt: 8000,
                     locality_nm: "NYC",
                     state_income_tax_amt: 600,
                     state_wages_amt: 8000,
                     w2_index: 0
  ) }

  let!(:state_file_1099) { create(:state_file1099_g,
                                  intake: intake,
                                  address_confirmation: 'no',
                                  recipient_city: 'New York',
                                  recipient_street_address: '123 Main St',
                                  recipient_street_address_apartment: 'Apt E',
                                  recipient_zip: '11102',
                                  unemployment_compensation: 1,
                                  federal_income_tax_withheld: 0,
                                  state_income_tax_withheld: 0
  ) }

  let(:migrate) { described_class.new.migrate }

  describe '#migrate' do
    before do
      migrate
      intake.reload
    end
    it 'migrates all monetary values correctly' do
      expect(intake.charitable_cash_amount).to eq 100
      expect(intake.charitable_noncash_amount).to eq 200
      expect(intake.household_excise_credit_claimed_amount).to eq 300
      expect(intake.tribal_wages_amount).to eq 400
      expect(intake.armed_forces_wages_amount).to eq 500

      expect(state_file_1099.unemployment_compensation_amount).to eq 1
      expect(state_file_1099.federal_income_tax_withheld_amount).to eq 0
      expect(state_file_1099.state_income_tax_withheld_amount).to eq 0

      expect(w2.state_wages_amount).to eq 8000
      expect(w2.state_income_tax_amount).to eq 600
      expect(w2.local_wages_and_tips_amount).to eq 8000
      expect(w2.local_income_tax_amount).to eq 200
    end
  end
end