# == Schema Information
#
# Table name: client_efforts
#
#  id              :bigint           not null, primary key
#  effort_type     :integer          not null
#  made_at         :datetime         not null
#  responded_to_at :datetime
#  response_type   :integer
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
    it do
      is_expected.to define_enum_for(:effort_type)
        .with_values({
          consented: 0,
          completed_intake_questions: 1,
          uploaded_docs: 2,
          uploaded_requested_docs: 3,
          completed_full_intake: 4,
          sent_sms: 5,
          returned_to_intake: 6,
          sent_email: 7,
          emailed_support: 8,
          opened_support_chat: 9,
        })
        .with_prefix(:effort_type)
    end
    it do
      is_expected.to define_enum_for(:response_type)
        .with_values({
          public_reply: 0,
          phone_call: 1,
          status_change: 2,
        })
        .with_prefix(:response_type)
    end

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
