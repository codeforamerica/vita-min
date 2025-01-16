# == Schema Information
#
# Table name: state_file_archived_intake_requests
#
#  id                             :bigint           not null, primary key
#  email_address                  :string
#  failed_attempts                :integer          default(0), not null
#  ip_address                     :string
#  locked_at                      :datetime
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  state_file_archived_intakes_id :bigint
#
# Indexes
#
#  idx_on_state_file_archived_intakes_id_31501c23f8  (state_file_archived_intakes_id)
#
# Foreign Keys
#
#  fk_rails_...  (state_file_archived_intakes_id => state_file_archived_intakes.id)
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
