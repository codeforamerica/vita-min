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