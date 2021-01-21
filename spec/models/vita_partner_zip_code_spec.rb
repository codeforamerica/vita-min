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
#
# Foreign Keys
#
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
require 'rails_helper'

RSpec.describe VitaPartnerZipCode, type: :model do
  describe "required fields" do
    context "record of zip code in helper/zip_codes ZIP_CODES hash and vita partner" do
      it "is valid" do
        vita_partner_zip_code = described_class.new(zip_code: "28806", vita_partner: create(:vita_partner))
        expect(vita_partner_zip_code).to be_valid
      end
    end

    context "no vita partner" do
      it "is not valid" do
        expect(described_class.new(zip_code: "28806")).not_to be_valid
      end
    end

    context "no record of zip code in helper/zip_codes ZIP_CODES hash" do
      it "is not valid" do
        vita_partner_zip_code = described_class.new(zip_code: "1982379128738", vita_partner: create(:vita_partner))

        expect(vita_partner_zip_code).not_to be_valid
        expect(vita_partner_zip_code.errors).to include :zip_code
      end
    end
  end
end
