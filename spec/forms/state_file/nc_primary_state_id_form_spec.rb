require 'rails_helper'

RSpec.describe StateFile::NcPrimaryStateIdForm, type: :model do
  include_examples :nc_state_id

  describe '#save' do
    let(:intake) { create(:state_file_nc_intake) }

    it 'should update values for allowed values' do
      form = StateFile::NcPrimaryStateIdForm.from_intake(intake)

      state_id = intake.primary_state_id
      state_id.id_number = "123456789"

      expect { form.save }.to change(state_id, :id_number)
    end
  end

  describe '#existing_attributes' do
    let(:intake) { create(:state_file_nc_intake) }

    it 'should assign nil when no attributes exist already' do
      attrs = StateFile::NcPrimaryStateIdForm.existing_attributes(intake)

      expect(attrs[:id_number]).to be_nil
    end

    it 'should assign values on whitelisted attributes when they exist' do
      intake.create_primary_state_id(
        id_number: "123456789",
        id_type: "driver_license",
        issue_date: "1980-06-16".to_datetime
      )
      attrs = StateFile::NcPrimaryStateIdForm.existing_attributes(intake)

      expect(attrs[:id_number]).to eq("123456789")
    end

    it 'should not assign values on whitelisted attributes when they do not exist' do
      expect(intake.primary_state_id).to be_nil

      form = StateFile::NcPrimaryStateIdForm.existing_attributes(intake)

      expect(form[:id_number]).to be_nil
    end
  end
end
