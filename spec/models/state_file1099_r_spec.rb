# == Schema Information
#
# Table name: state_file1099_rs
#
#  id                                 :bigint           not null, primary key
#  capital_gain_amount                :decimal(12, 2)
#  designated_roth_account_first_year :integer
#  distribution_code                  :string
#  federal_income_tax_withheld_amount :decimal(12, 2)
#  gross_distribution_amount          :decimal(12, 2)
#  intake_type                        :string           not null
#  payer_address_line1                :string
#  payer_address_line2                :string
#  payer_city_name                    :string
#  payer_identification_number        :string
#  payer_name                         :string
#  payer_name_control                 :string
#  payer_state_code                   :string
#  payer_state_identification_number  :string
#  payer_zip                          :string
#  phone_number                       :string
#  recipient_name                     :string
#  recipient_ssn                      :string
#  standard                           :boolean
#  state_code                         :string
#  state_distribution_amount          :decimal(12, 2)
#  state_specific_followup_type       :string
#  state_tax_withheld_amount          :decimal(12, 2)
#  taxable_amount                     :decimal(12, 2)
#  taxable_amount_not_determined      :boolean
#  total_distribution                 :boolean
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  intake_id                          :bigint           not null
#  state_specific_followup_id         :bigint
#
# Indexes
#
#  index_state_file1099_rs_on_intake                   (intake_type,intake_id)
#  index_state_file1099_rs_on_state_specific_followup  (state_specific_followup_type,state_specific_followup_id)
#
require 'rails_helper'

RSpec.describe StateFile1099R do
  describe "validation" do
    context "retirement_income_intake" do
      let!(:state_file1099_r) { create(:state_file1099_r, intake: create(:state_file_nc_intake)) }
      let(:context) { :retirement_income_intake }

      context "state_tax_withheld_amount and state_distribution_amount must be less than gross_distribution_amount" do
        let(:state_file1099_r) {
          create :state_file1099_r,
                 intake: create(:state_file_nc_intake),
                 gross_distribution_amount: gross_distribution_amount,
                 state_tax_withheld_amount: state_tax_withheld_amount,
                 state_distribution_amount: state_distribution_amount
        }

        context "when the gross_distribution_amount is present" do
          let(:gross_distribution_amount) { 100 }

          context "other values are less" do
            let(:state_tax_withheld_amount) { 50 }
            let(:state_distribution_amount) { 50 }

            it "is valid" do
              expect(state_file1099_r).to be_valid(context)
            end
          end

          context "other values are greater" do
            let(:state_tax_withheld_amount) { 200 }
            let(:state_distribution_amount) { 200 }

            it "is invalid" do
              expect(state_file1099_r).not_to be_valid(context)
              expect(state_file1099_r.errors[:state_tax_withheld_amount]).to be_present
              expect(state_file1099_r.errors[:state_distribution_amount]).to be_present
            end
          end
        end
      end

      it "validates gross_distribution_amount is present and a positive number" do
        state_file1099_r.state_tax_withheld_amount = 0
        state_file1099_r.state_distribution_amount = 0

        state_file1099_r.gross_distribution_amount = 'string'
        expect(state_file1099_r.valid?(context)).to eq false
        state_file1099_r.gross_distribution_amount = nil
        expect(state_file1099_r.valid?(context)).to eq false
        state_file1099_r.gross_distribution_amount = -1
        expect(state_file1099_r.valid?(context)).to eq false
        state_file1099_r.gross_distribution_amount = 0
        expect(state_file1099_r.valid?(context)).to eq false

        state_file1099_r.gross_distribution_amount = 1
        expect(state_file1099_r.valid?(context)).to eq true
      end

      it "validates state_tax_withheld_amount and state_distribution_amount are positive numbers if present" do
        [:state_distribution_amount, :state_tax_withheld_amount].each do |attr|
          ['string', -1].each do |val|
            state_file1099_r.send("#{attr}=", val)
            expect(state_file1099_r.valid?(context)).to eq false
          end

          [nil, 0, 1].each do |val|
            state_file1099_r.send("#{attr}=", val)
            expect(state_file1099_r.valid?(context)).to eq true
          end
        end

      end

      it "validates payer_state_identification_number" do
        state_file1099_r.payer_state_identification_number = nil
        expect(state_file1099_r.valid?(context)).to eq false
        state_file1099_r.payer_state_identification_number = '-1'
        expect(state_file1099_r.valid?(context)).to eq false
        state_file1099_r.payer_state_identification_number = '1231578123'
        expect(state_file1099_r.valid?(context)).to eq false
        state_file1099_r.payer_state_identification_number = 'az31578123'
        expect(state_file1099_r.valid?(context)).to eq false
        state_file1099_r.payer_state_identification_number = 'nc31578123'
        expect(state_file1099_r.valid?(context)).to eq true
        state_file1099_r.payer_state_identification_number = 'nc31578123123125412'
        expect(state_file1099_r.valid?(context)).to eq false
      end
    end
  end
end
