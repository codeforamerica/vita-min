# == Schema Information
#
# Table name: clients
#
#  id               :bigint           not null, primary key
#  email_address    :string
#  phone_number     :string
#  preferred_name   :string
#  sms_phone_number :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  vita_partner_id  :bigint
#
# Indexes
#
#  index_clients_on_vita_partner_id  (vita_partner_id)
#
# Foreign Keys
#
#  fk_rails_...  (vita_partner_id => vita_partners.id)
#
require "rails_helper"

RSpec.describe Client, type: :model do
  describe "#formatted_phone_number" do
    let(:client) { build :client, phone_number: "14158161286" }

    it "returns a locally formatted phone number" do
      expect(client.formatted_phone_number).to eq "(415) 816-1286"
    end
  end
end
