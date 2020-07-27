# == Schema Information
#
# Table name: client_efforts
#
#  id              :bigint           not null, primary key
#  effort_type     :string           not null
#  made_at         :datetime         not null
#  responded_to_at :datetime
#  response_type   :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  intake_id       :bigint           not null
#  ticket_id       :bigint           not null
#
# Indexes
#
#  index_client_efforts_on_intake_id  (intake_id)
#
# Foreign Keys
#
#  fk_rails_...  (intake_id => intakes.id)
#
require "rails_helper"

describe ClientEffort do
  describe "validations" do
    it { should belong_to(:intake) }
    it { should validate_presence_of(:made_at) }
    it { should validate_presence_of(:ticket_id) }
    it { should validate_presence_of(:effort_type) }
    it { should validate_inclusion_of(:effort_type).in_array(ClientEffort::EFFORT_TYPES) }
    it { should validate_inclusion_of(:response_type).in_array(ClientEffort::RESPONSE_TYPES) }

    it "is valid with only required fields" do
      expect(ClientEffort.new(
        intake: create(:intake),
        ticket_id: 12345678,
        effort_type: "emailed_support",
        made_at: DateTime.now
      )).to be_valid
    end
  end
end
