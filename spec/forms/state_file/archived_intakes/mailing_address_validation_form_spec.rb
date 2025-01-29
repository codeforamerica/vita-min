require "rails_helper"

RSpec.describe StateFile::ArchivedIntakes::MailingAddressValidationForm do
  let(:current_address) { "123 Main St, Springfield, USA" }
  let(:addresses) { ["123 Main St, Springfield, USA", "456 Elm St, Springfield, USA"] }
  let(:selected_address) { "123 Main St, Springfield, USA" }
  let(:form) { described_class.new({ selected_address: selected_address }, addresses: addresses, current_address: current_address) }

  context "when an invalid address is selected" do
    let(:selected_address) { "789 Oak St, Springfield, USA" }

    it "is not valid and adds a validation error" do
      expect(form).not_to be_valid
    end
  end

  context "when the selected address matches the current address" do
    let(:selected_address) { "123 Main St, Springfield, USA" }

    it "is valid" do
      expect(form).to be_valid
    end
  end
end
