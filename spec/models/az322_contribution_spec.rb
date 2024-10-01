# == Schema Information
#
# Table name: az322_contributions
#
#  id                      :bigint           not null, primary key
#  amount                  :decimal(12, 2)
#  ctds_code               :string
#  date_of_contribution    :date
#  district_name           :string
#  made_contribution       :integer          default("unfilled"), not null
#  school_name             :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  state_file_az_intake_id :bigint
#
# Indexes
#
#  index_az322_contributions_on_state_file_az_intake_id  (state_file_az_intake_id)
#
require 'rails_helper'

describe 'Az322Contribution' do
  let(:intake) { create(:state_file_az_intake) }

  describe "#made_contributions" do
    it 'should validate presence' do
      az = Az322Contribution.new(state_file_az_intake: intake, made_contribution: nil)
      az.valid?
      expect(az.errors[:made_contribution]).not_to be_empty

      az.made_contribution = 'yes'
      az.valid?
      expect(az.errors[:made_contribution]).to be_empty

      az.made_contribution = 'gobble'
      az.valid?
      expect(az.errors[:made_contribution]).not_to be_empty
    end
  end

  context "made_contributions is true" do
    let(:az) { Az322Contribution.new(state_file_az_intake: intake, made_contribution: 'yes') }

    describe "#school_name" do
      it 'should validate presence' do
        az.school_name = nil
        az.valid?
        expect(az.errors[:school_name]).not_to be_empty

        az.school_name = 'Hopscotch School'
        az.valid?
        expect(az.errors[:school_name]).to be_empty
      end
    end

    describe "#ctds_code" do
      it 'should validate presence' do
        az.ctds_code = nil
        az.valid?
        expect(az.errors[:ctds_code]).not_to be_empty

        az.ctds_code = '123456789'
        az.valid?
        expect(az.errors[:ctds_code]).to be_empty

        az.ctds_code = '12345678'
        az.valid?
        expect(az.errors[:ctds_code]).not_to be_empty

        az.ctds_code = 'fffffffff'
        az.valid?
        expect(az.errors[:ctds_code]).not_to be_empty
      end
    end

    describe "#district_name" do
      it 'should validate presence' do
        az.district_name = nil
        az.valid?
        expect(az.errors[:district_name]).not_to be_empty

        az.district_name = 'Sesame District'
        az.valid?
        expect(az.errors[:district_name]).to be_empty
      end
    end

    describe "#amount" do
      it 'should validate presence' do
        az.amount = nil
        az.valid?
        expect(az.errors[:amount]).to eq(["Can't be blank.", "is not a number"])

        az.amount = 0
        az.valid?
        expect(az.errors[:amount]).to eq(["must be greater than 0"])

        az.amount = 1
        az.valid?
        expect(az.errors[:amount]).to be_empty
        expect(az.amount).to eq(1)
      end
    end

    describe '#date_of_contribution' do
      it 'should be valid in the current tax year' do
        az.date_of_contribution_year = Rails.configuration.statefile_current_tax_year

        az.valid?

        expect(az.errors[:date_of_contribution]).to be_empty
      end

      it 'should be invalid in the previous year' do
        az.date_of_contribution_year = Rails.configuration.statefile_current_tax_year - 1

        az.valid?

        expect(az.errors[:date_of_contribution]).not_to be_empty
      end

      it 'should be invalid in the next year' do
        az.date_of_contribution_year = Rails.configuration.statefile_current_tax_year + 1

        az.valid?

        expect(az.errors[:date_of_contribution]).not_to be_empty
      end

      it 'should be valid when a correct date is provided' do
        current_tax_year = Rails.configuration.statefile_current_tax_year

        az.date_of_contribution_year = current_tax_year
        az.date_of_contribution_day = 12
        az.date_of_contribution_month = 5

        az.valid?

        expect(az.errors[:date_of_contribution]).to be_empty

        az.restore_attributes

        expect(az.date_of_contribution).to be_nil

        az.date_of_contribution = "#{current_tax_year}-05-12"

        az.valid?

        expect(az.errors[:date_of_contribution]).to be_empty
      end

      it 'should be invalid when nonsense is provided' do
        az.date_of_contribution = "foo"

        az.valid?

        expect(az.errors[:date_of_contribution]).not_to be_empty
      end
    end
  end
end
