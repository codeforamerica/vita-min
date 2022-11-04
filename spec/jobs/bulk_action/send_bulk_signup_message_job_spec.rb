require 'rails_helper'

describe BulkAction::SendBulkSignupMessageJob do
  describe '#perform' do
    let(:signup_1) { create :signup }
    let(:signup_2) { create :signup }
    let(:bulk_signup_message) { create(:bulk_signup_message, signup_selection: build(:signup_selection, id_array: [signup_1.id, signup_2.id]), message: "We are now open") }

    it 'enqueues one SendOneBulkSignupMessageJob per signup ID' do
      described_class.perform_now(bulk_signup_message)
      expect(BulkAction::SendOneBulkSignupMessageJob).to(have_been_enqueued.at_least(:once).with(signup_1, bulk_signup_message))
      expect(BulkAction::SendOneBulkSignupMessageJob).to(have_been_enqueued.at_least(:once).with(signup_2, bulk_signup_message))
    end
  end
end
