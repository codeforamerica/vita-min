# == Schema Information
#
# Table name: access_logs
#
#  id          :bigint           not null, primary key
#  event_type  :string           not null
#  ip_address  :inet
#  record_type :string
#  user_agent  :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  client_id   :bigint
#  record_id   :bigint
#  user_id     :bigint           not null
#
# Indexes
#
#  index_access_logs_on_client_id                  (client_id)
#  index_access_logs_on_record_type_and_record_id  (record_type,record_id)
#  index_access_logs_on_user_id                    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

describe AccessLog do
  describe "validations" do
    context "event_type" do
      let(:access_log) { build :access_log, event_type: event_type }
      before { access_log.valid? }

      context "with valid event type" do
        let(:event_type) { "read_bank_account_info" }

        it "is valid" do
          expect(access_log.errors).not_to include :event_type
        end
      end

      context "with invalid event type" do
        let(:event_type) { "intake_form_souffled" }

        it "is not valid" do
          expect(access_log.errors).to include :event_type
        end
      end
    end
  end
end
