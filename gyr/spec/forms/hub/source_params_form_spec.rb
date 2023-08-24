require "rails_helper"

describe Hub::SourceParamsForm do
  subject { described_class.new(vita_partner, params) }

  let(:vita_partner) { create :organization }
  let(:code) { "my_code" }
  let(:params) do
    {
        code: code
    }
  end
  describe "#valid?" do
    context "when the source parameter is already in use" do
      context "when the source parameter is" do
        before do
          create :source_parameter, vita_partner: vita_partner, code: code
        end

        it "is invalid with appropriate message" do
          expect(subject.valid?).to eq false
          expect(subject.errors[:code]).to include "my_code is already applied to this partner."
        end
      end

      context "when it belongs to a different vita partner" do
        let(:other_vita_partner) { create :organization, name: "Oregano Org" }
        before do
          create :source_parameter, vita_partner: other_vita_partner, code: code
        end

        it "is invalid with appropriate message" do
          expect(subject.valid?).to eq false
          expect(subject.errors[:code]).to include "my_code is already in use by <a href=/en/hub/organizations/#{other_vita_partner.id}/edit#source-params-form>Oregano Org</a>."
        end
      end
    end

    context "when the source parameter is unique and valid" do
      it "is valid" do
        expect(subject.valid?).to eq true
      end
    end

    context "when no parameter is provided" do
      let(:code) { nil }

      it "is not valid" do
        expect(subject).not_to be_valid
      end
    end
  end

  describe "#save!" do
    it "creates a new source parameter for the vita partner" do
      expect {
        subject.save!
      }.to change(vita_partner.source_parameters, :count).by 1
    end
  end
end
