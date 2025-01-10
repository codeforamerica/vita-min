# == Schema Information
#
# Table name: state_file1099_gs
#
#  id                                 :bigint           not null, primary key
#  address_confirmation               :integer          default("unfilled"), not null
#  federal_income_tax_withheld_amount :decimal(12, 2)
#  had_box_11                         :integer          default("unfilled"), not null
#  intake_type                        :string           not null
#  payer_city                         :string
#  payer_name                         :string
#  payer_street_address               :string
#  payer_tin                          :string
#  payer_zip                          :string
#  recipient                          :integer          default("unfilled"), not null
#  recipient_city                     :string
#  recipient_state                    :string
#  recipient_state                    :string
#  recipient_street_address           :string
#  recipient_street_address_apartment :string
#  recipient_zip                      :string
#  state_identification_number        :string
#  state_income_tax_withheld_amount   :decimal(12, 2)
#  unemployment_compensation_amount   :decimal(12, 2)
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  intake_id                          :bigint           not null
#
# Indexes
#
#  index_state_file1099_gs_on_intake  (intake_type,intake_id)
#
require 'rails_helper'

RSpec.describe StateFile1099G do
  describe "conditional attributes" do
    describe '#address_confirmation' do
      before do
        allow_any_instance_of(DirectFileData).to receive(:mailing_street).and_return "321 Main St"
        allow_any_instance_of(DirectFileData).to receive(:mailing_apartment).and_return "Apt D"
        allow_any_instance_of(DirectFileData).to receive(:mailing_city).and_return "Buffalo"
        allow_any_instance_of(DirectFileData).to receive(:mailing_state).and_return "NY"
        allow_any_instance_of(DirectFileData).to receive(:mailing_zip).and_return "11105"
      end

      it 'sets address to default address that was confirmed' do
        state_file_1099 = create(
          :state_file1099_g,
          intake: create(:state_file_ny_intake),
          address_confirmation: 'no',
          recipient_city: 'New York',
          recipient_street_address: '123 Main St',
          recipient_street_address_apartment: 'Apt E',
          recipient_zip: '11102',
          unemployment_compensation_amount: '1',
          federal_income_tax_withheld_amount: '0',
          state_income_tax_withheld_amount: '0',
        )
        state_file_1099.address_confirmation = 'yes'
        state_file_1099.save
        expect(state_file_1099.recipient_street_address).to eq state_file_1099.intake.direct_file_data.mailing_street
        expect(state_file_1099.recipient_street_address_apartment).to eq state_file_1099.intake.direct_file_data.mailing_apartment
        expect(state_file_1099.recipient_city).to eq state_file_1099.intake.direct_file_data.mailing_city
        expect(state_file_1099.recipient_state).to eq state_file_1099.intake.direct_file_data.mailing_state
        expect(state_file_1099.recipient_zip).to eq state_file_1099.intake.direct_file_data.mailing_zip
      end
    end
  end

  describe "validation" do
    let!(:state_file_1099) {
      create(
        :state_file1099_g,
        intake: create(:state_file_ny_intake),
        address_confirmation: 'no',
        recipient_city: 'New York',
        recipient_street_address: '123 Main St',
        recipient_street_address_apartment: 'Apt E',
        recipient_zip: '11102',
        unemployment_compensation_amount: '1',
        federal_income_tax_withheld_amount: '0',
        state_income_tax_withheld_amount: '0',
      )
    }

    it "validates recipient" do
      state_file_1099.recipient = 'unfilled'
      expect(state_file_1099.save).to eq false
      state_file_1099.recipient = 'spouse'
      expect(state_file_1099.save).to eq true
      state_file_1099.recipient = 'primary'
      expect(state_file_1099.save).to eq true
    end

    it "validates unemployment_compensation_amount" do
      state_file_1099.unemployment_compensation_amount = nil
      expect(state_file_1099.save).to eq false
      state_file_1099.unemployment_compensation_amount = '0'
      expect(state_file_1099.save).to eq false
    end

    it "validates federal_income_tax_withheld_amount" do
      state_file_1099.federal_income_tax_withheld_amount = nil
      expect(state_file_1099.save).to eq false
      state_file_1099.federal_income_tax_withheld_amount = '-1'
      expect(state_file_1099.save).to eq false
    end

    it "validates state_income_tax_withheld_amount" do
      state_file_1099.state_income_tax_withheld_amount = nil
      expect(state_file_1099.save).to eq false
      state_file_1099.state_income_tax_withheld_amount = '-1'
      expect(state_file_1099.save).to eq false
    end

    it "validates presence of address_confirmation when had_box_11 is yes" do
      state_file_1099.had_box_11 = 'yes'
      state_file_1099.address_confirmation = nil
      expect(state_file_1099.save).to eq false
      expect(state_file_1099.errors[:address_confirmation]).to include(I18n.t("errors.messages.blank"))

      state_file_1099.address_confirmation = 'yes'
      expect(state_file_1099.save).to eq true

      state_file_1099.address_confirmation = 'no'
      expect(state_file_1099.save).to eq true
    end

    it "yields a valid recipient address line 1 and line 2" do
      expect(state_file_1099.recipient_address_line1).to eq "123 Main St"
      expect(state_file_1099.recipient_address_line2).to eq "Apt E"
      state_file_1099.recipient_street_address_apartment = nil
      expect(state_file_1099.recipient_address_line1).to eq "123 Main St"
      expect(state_file_1099.recipient_address_line2).to eq nil
    end

    context "for wrong range" do
      let(:state_file_1099) { build(
        :state_file1099_g,
        intake: create(:state_file_ny_intake),
        address_confirmation: 'no',
        recipient_city: 'New York',
        recipient_street_address: '123 Main St',
        recipient_street_address_apartment: 'Apt E',
        recipient_zip: '11102',
        unemployment_compensation_amount: '0',
        federal_income_tax_withheld_amount: '0',
        state_income_tax_withheld_amount: '0',
      ) }

      it "validates unemployment_compensation" do
        state_file_1099.valid?
        expect(state_file_1099.errors[:unemployment_compensation_amount]).to include "must be greater than or equal to 1"
      end
    end
  end

  describe "save" do
    context "stripping string attributes" do
      it "strips address attributes before saving" do
        state1099g = create(:state_file1099_g, intake: create(:state_file_az_intake))
        attrs = {
          payer_name: " Payer ",
          payer_street_address: " 123 Main St   ",
          payer_city: "A City  ",
          payer_zip: " 83704",
          recipient_street_address: " 321 Side Street",
          recipient_street_address_apartment: "B ",
          recipient_city: " B City",
          recipient_zip: "83704 ",
        }

        state1099g.assign_attributes(attrs)
        expect(state1099g.valid?).to eq true
        state1099g.save
        expect(state1099g.payer_name).to eq "Payer"
        expect(state1099g.payer_street_address).to eq "123 Main St"
        expect(state1099g.payer_city).to eq "A City"
        expect(state1099g.payer_zip).to eq "83704"
        expect(state1099g.recipient_street_address).to eq "321 Side Street"
        expect(state1099g.recipient_street_address_apartment).to eq "B"
        expect(state1099g.recipient_city).to eq "B City"
        expect(state1099g.recipient_zip).to eq "83704"
      end
    end
  end
end
