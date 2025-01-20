# == Schema Information
#
# Table name: state_file_archived_intake_requests
#
#  id                            :bigint           not null, primary key
#  email_address                 :string
#  failed_attempts               :integer          default(0), not null
#  ip_address                    :string
#  locked_at                     :datetime
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  state_file_archived_intake_id :bigint
#
# Indexes
#
#  idx_on_state_file_archived_intake_id_7dd0f99380  (state_file_archived_intake_id)
#
require "rails_helper"

describe StateFileArchivedIntakeRequest do
  describe "#increment_failed_attempts" do
    let!(:request_instance) { create :state_file_archived_intake_request, failed_attempts: 1 }
    it "locks access when failed attempts is incremented to 2" do
      expect(request_instance.access_locked?).to eq(false)

      request_instance.increment_failed_attempts

      expect(request_instance.access_locked?).to eq(true)
    end
  end
end
