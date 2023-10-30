require 'rails_helper'

RSpec.describe StateFile::SetUpAccountForm do
  let(:intake) { create :state_file_ny_intake }
  describe "#save" do
    let(:valid_params) do
      { contact_preference: "email" }
    end

    it "saves the contact preference to the intake" do
      form = described_class.new(intake, valid_params)
      expect do
        form.save
      end.to change { intake.reload.contact_preference }.from("unfilled").to("email")
    end
  end
end
