require "rails_helper"

describe ZendeskSmsService do
  let(:phone_number) { "15557779999" }
  let(:service) { described_class.new(phone_number: phone_number) }

  describe "#find_associated_records" do
    context "with a matching user" do
      let!(:user) { create :user, phone_number: phone_number}

      it "returns the drop off" do
        results = service.find_associated_records
        expect(results.length).to eq 1
        expect(results.first).to eq user
      end
    end

    xcontext "with a matching intake_site_drop_off" do
      let!(:intake_site_drop_off) { create :intake_site_drop_off, phone_number: phone_number}

      it "returns the drop off" do
        results = service.find_associated_records
        expect(results.length).to eq 1
        expect(results.first).to eq intake_site_drop_off
      end
    end
  end
end
