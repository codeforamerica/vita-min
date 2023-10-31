require 'rails_helper'

RSpec.describe StateFile::PhoneNumberForm do
  let(:intake) { create :state_file_ny_intake }
  describe "#save" do
    let(:valid_params) do
      { email_address: "someone@example.com" }
    end

    it "saves the contact preference to the intake" do
      form = described_class.new(intake, valid_params)
      expect do
        form.save
      end.to change { intake.reload.email_address }.from(nil).to("someone@example.com")
    end
  end
end