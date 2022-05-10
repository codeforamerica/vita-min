# == Schema Information
#
# Table name: addresses
#
#  id                   :bigint           not null, primary key
#  city                 :string
#  record_type          :string
#  skip_usps_validation :boolean          default(FALSE)
#  state                :string
#  street_address       :string
#  street_address2      :string
#  zip_code             :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  record_id            :bigint
#
# Indexes
#
#  index_addresses_on_record_type_and_record_id  (record_type,record_id)
#
require 'rails_helper'

describe Address do
  describe "validations" do
    let(:record) { create(:intake) }
    context "with zip_code" do
      it "is valid" do
        expect(described_class.new(zip_code: "12345", record: record)).to be_valid
      end
    end

    context "without zip_code" do
      it "is invalid" do
        expect(described_class.new(record: record)).to be_invalid
      end
    end
  end
end
