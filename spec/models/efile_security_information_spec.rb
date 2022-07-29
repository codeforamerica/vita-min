# == Schema Information
#
# Table name: efile_security_informations
#
#  id                  :bigint           not null, primary key
#  browser_language    :string
#  client_system_time  :string
#  ip_address          :inet
#  platform            :string
#  recaptcha_score     :decimal(, )
#  timezone            :string
#  timezone_offset     :string
#  user_agent          :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  client_id           :bigint
#  device_id           :string
#  efile_submission_id :bigint
#
# Indexes
#
#  index_client_efile_security_informations_efile_submissions_id  (efile_submission_id)
#  index_efile_security_informations_on_client_id                 (client_id)
#
# Foreign Keys
#
#  fk_rails_...  (client_id => clients.id)
#  fk_rails_...  (efile_submission_id => efile_submissions.id)
#
require "rails_helper"

describe EfileSecurityInformation do
  describe "#client_system_datetime" do
    context "when there are special characters that cause an ArgumentError" do
      let(:efile_security_information) { create :efile_security_information, client: create(:client), client_system_time: "Thu Jul 28 2022 00:56:53 GMT-0400 (เวลาออมแสงทางตะวันออกในอเมริกาเหนือ)"}

      it "does not raise an error and returns a processable datetime" do
        expect {
          value = efile_security_information.client_system_datetime
          expect(value).to eq DateTime.parse("Thu Jul 28 2022 00:56:53 GMT-0400")
        }.not_to raise_error ArgumentError
      end
    end
  end
end
