require 'rails_helper'

describe BulkAction::SendBulkSignupMessageJob do
  describe '#perform' do
    let(:bulk_signup_message) { create(:bulk_signup_message, signup_selection: build(:signup_selection, id_array: [signup_1.id, signup_2.id], signup_type: signup_type), message: "We are now open") }

    context "for GYR signups" do
      let(:signup_type) { "GYR" }
      let(:signup_1) { create :signup }
      let(:signup_2) { create :signup }

      it 'enqueues one SendOneBulkSignupMessageJob per signup ID' do
        described_class.perform_now(bulk_signup_message)
        expect(BulkAction::SendOneBulkSignupMessageJob).to(have_been_enqueued.at_least(:once).with(signup_1, bulk_signup_message))
        expect(BulkAction::SendOneBulkSignupMessageJob).to(have_been_enqueued.at_least(:once).with(signup_2, bulk_signup_message))
      end
    end

    context "for GetCTC signups" do
      let(:signup_type) { "GetCTC" }
      let(:signup_1) { create :ctc_signup }
      let(:signup_2) { create :ctc_signup }

      it 'enqueues one SendOneBulkSignupMessageJob per signup ID' do
        described_class.perform_now(bulk_signup_message)
        expect(BulkAction::SendOneBulkSignupMessageJob).to(have_been_enqueued.at_least(:once).with(signup_1, bulk_signup_message))
        expect(BulkAction::SendOneBulkSignupMessageJob).to(have_been_enqueued.at_least(:once).with(signup_2, bulk_signup_message))
      end
    end
  end
end
