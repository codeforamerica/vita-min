require 'rails_helper'

describe Az321Contribution do
  let(:intake) { create(:state_file_az_intake) }

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

  describe "#date_of_contribution" do
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
end
