# == Schema Information
#
# Table name: vita_partner_zip_codes
#
#  id              :bigint           not null, primary key
#  zip_code        :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  vita_partner_id :bigint           not null
#
# Indexes
#
#  index_vita_partner_zip_codes_on_vita_partner_id  (vita_partner_id)
#  index_vita_partner_zip_codes_on_zip_code         (zip_code) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
require 'rails_helper'

RSpec.describe VitaPartnerZipCode, type: :model do
  describe "validations" do
    let!(:existing_record) { create :vita_partner_zip_code }

    context "record of zip code in helper/zip_codes ZIP_CODES hash and vita partner is present" do
      it "is valid" do
        vita_partner_zip_code = described_class.new(zip_code: "28806", vita_partner: create(:organization))
        expect(vita_partner_zip_code).to be_valid
      end
    end

    context "no vita partner" do
      it "is not valid" do
        vita_partner_zip_code = described_class.new(zip_code: "28806")

        expect(vita_partner_zip_code).not_to be_valid
        expect(vita_partner_zip_code.errors).to include :vita_partner
      end
    end

    context "no record of zip code in helper/zip_codes ZIP_CODES hash" do
      it "is not valid" do
        vita_partner_zip_code = described_class.new(zip_code: "1982379128738", vita_partner: create(:organization))

        expect(vita_partner_zip_code).not_to be_valid
        expect(vita_partner_zip_code.errors).to include :zip_code
      end
    end

    context "when a record already exists with same vita_partner and zipcode" do
      it "is not valid" do
        new_record = described_class.new(zip_code: existing_record.zip_code, vita_partner: existing_record.vita_partner)

        expect(existing_record).to be_valid
        expect(new_record).not_to be_valid
      end
    end

    context "when a record exists with duplicate zip code and different vita partner" do
      it "is not valid" do
        new_record = described_class.new(zip_code: existing_record.zip_code, vita_partner: create(:organization))

        expect(new_record).not_to be_valid
      end
    end

    context "when a record exists with different zip code and duplicate vita partner" do
      it "is valid" do
        new_record = described_class.new(zip_code: "94117", vita_partner: existing_record.vita_partner)

        expect(new_record).to be_valid
      end
    end
  end
end
