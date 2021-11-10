require "rails_helper"

describe Hub::ZipCodeRoutingForm do
  subject { described_class.new(vita_partner, params) }

  let(:vita_partner) { create :site }
  let(:zip_code) { 94606 }
  let(:params) do
    {
        zip_code: zip_code
    }
  end
  describe "#valid?" do
    context "when the zip code is already in use" do
      context "when it belongs to current vita partner" do
        before do
          create :vita_partner_zip_code, vita_partner: vita_partner, zip_code: zip_code
        end

        it "is invalid with appropriate message" do
          expect(subject.valid?).to eq false
          expect(subject.errors[:zip_code]).to include "94606 is already routed to this partner."
        end
      end

      context "when it belongs to a different vita partner" do
        let(:other_vita_partner) { create :organization, name: "Oregano Org" }
        before do
          create :vita_partner_zip_code, vita_partner: other_vita_partner, zip_code: zip_code
        end

        it "is invalid with appropriate message" do
          expect(subject.valid?).to eq false
          expect(subject.errors[:zip_code]).to include "94606 is already routed to <a href=/en/hub/organizations/#{other_vita_partner.id}/edit#zip-code-routing-form>Oregano Org</a>."
        end
      end

    end

    context "when the zip code is not valid" do
      let(:zip_code) { "A2345"}
      it "is invalid" do
        expect(subject.valid?).to eq false
        expect(subject.errors[:zip_code]).to include "A2345 is not a valid US zip code."
      end
    end

    context "when the zip code is unique and valid" do
      it "is valid" do
        expect(subject.valid?).to eq true
      end
    end
  end

  describe "#save!" do
    it 'creates a new serviced zip code for the vita partner' do
      expect {
        subject.save!
      }.to change(vita_partner.serviced_zip_codes, :count).by 1
    end
  end
end