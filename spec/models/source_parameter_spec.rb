# == Schema Information
#
# Table name: source_parameters
#
#  id              :bigint           not null, primary key
#  code            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  vita_partner_id :bigint           not null
#
# Indexes
#
#  index_source_parameters_on_code             (code) UNIQUE
#  index_source_parameters_on_vita_partner_id  (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
require 'rails_helper'

RSpec.describe SourceParameter, type: :model do
  it { should validate_presence_of(:vita_partner_id) }
  it { should validate_presence_of(:code) }

  describe ".find_vita_partner_by_code" do
    let(:vita_partner) { create :vita_partner, name: "Oregano Organization" }
    let!(:source_parameter) { create :source_parameter, code: "oregorg", vita_partner: vita_partner }

    context "when the source string matches a source parameter exactly" do
      let(:code) { "oregorg" }

      it "returns the corresponding vita partner" do
        expect(described_class.find_vita_partner_by_code(code)).to eq vita_partner
      end
    end

    context "when the source is cased differently but still matches a source parameter" do
      let(:code) { "OREGorg" }

      it "returns the corresponding vita partner" do
        expect(described_class.find_vita_partner_by_code(code)).to eq vita_partner
      end
    end

    context "when the source string is something random" do
      let(:code) { "cookiemonster" }

      it "returns nil" do
        expect(described_class.find_vita_partner_by_code(code)).to eq nil
      end
    end
  end
end
