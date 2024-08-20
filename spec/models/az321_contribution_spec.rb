# == Schema Information
#
# Table name: az321_contributions
#
#  id                      :bigint           not null, primary key
#  amount                  :decimal(12, 2)
#  charity_code            :string
#  charity_name            :string
#  date_of_contribution    :date
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  state_file_az_intake_id :bigint
#
# Indexes
#
#  index_az321_contributions_on_state_file_az_intake_id  (state_file_az_intake_id)
#
require 'rails_helper'

describe Az321Contribution do
  let(:intake) { create(:state_file_az_intake) }

  describe 'simple validation' do
    it { should validate_presence_of :charity_name }
    it { should validate_presence_of :charity_code }
    it { should validate_presence_of :date_of_contribution }
  end

  describe '#made_contributions' do
    it 'should validate presence on form_create context' do
      az = Az321Contribution.new(state_file_az_intake: intake)

      az.valid?(:form_create)

      expect(az.errors[:made_contributions]).not_to be_empty
    end

    it 'should not validate presence in the default context' do
      az = Az321Contribution.new(state_file_az_intake: intake)

      az.valid?

      expect(az.errors[:made_contributions]).to be_empty
    end
  end

  describe '#date_of_contribution' do
    it 'should be valid in the current tax year' do
      az = Az321Contribution.new(state_file_az_intake: intake)

      az.date_of_contribution_year = Rails.configuration.statefile_current_tax_year

      az.valid?

      expect(az.errors[:date_of_contribution]).to be_empty
    end

    it 'should be invalid in the previous year' do
      az = Az321Contribution.new(state_file_az_intake: intake)

      az.date_of_contribution_year = Rails.configuration.statefile_current_tax_year - 1

      az.valid?

      expect(az.errors[:date_of_contribution]).not_to be_empty
    end

    it 'should be invalid in the next year' do
      az = Az321Contribution.new(state_file_az_intake: intake)

      az.date_of_contribution_year = Rails.configuration.statefile_current_tax_year + 1

      az.valid?

      expect(az.errors[:date_of_contribution]).not_to be_empty
    end

    it 'should be valid when a correct date is provided' do
      az = Az321Contribution.new(state_file_az_intake: intake)

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
      az = Az321Contribution.new(state_file_az_intake: intake)

      az.date_of_contribution = "foo"

      az.valid?

      expect(az.errors[:date_of_contribution]).not_to be_empty
    end
  end

  describe '#charity_code' do
    it 'should accept valid charity codes' do
      az = Az321Contribution.new

      az.charity_code = 20000
      az.valid?
      expect(az.errors[:charity_code]).to be_empty

      az.charity_code = 29999
      az.valid?
      expect(az.errors[:charity_code]).to be_empty

      az.charity_code = "20000"
      az.valid?
      expect(az.errors[:charity_code]).to be_empty

      az.charity_code = "29999"
      az.valid?
      expect(az.errors[:charity_code]).to be_empty
    end

    it 'should reject invalid charity codes' do
      az = Az321Contribution.new

      az.charity_code = 30000
      az.valid?
      expect(az.errors[:charity_code]).to be_present

      az.charity_code = 19999
      az.valid?
      expect(az.errors[:charity_code]).to be_present

      az.charity_code = "30000"
      az.valid?
      expect(az.errors[:charity_code]).to be_present

      az.charity_code = "19999"
      az.valid?
      expect(az.errors[:charity_code]).to be_present

      az.charity_code = "199a9"
      az.valid?
      expect(az.errors[:charity_code]).to be_present

      az.charity_code = "299a9"
      az.valid?
      expect(az.errors[:charity_code]).to be_present
    end
  end
end
