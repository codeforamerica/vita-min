# == Schema Information
#
# Table name: efile_submission_transitions
#
#  id                  :bigint           not null, primary key
#  metadata            :jsonb
#  most_recent         :boolean          not null
#  sort_key            :integer          not null
#  to_state            :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  efile_submission_id :integer          not null
#
# Indexes
#
#  index_efile_submission_transitions_parent_most_recent  (efile_submission_id,most_recent) UNIQUE WHERE most_recent
#  index_efile_submission_transitions_parent_sort         (efile_submission_id,sort_key) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (efile_submission_id => efile_submissions.id)
#
require "rails_helper"

describe EfileSubmissionTransition do
  describe "#initiated_by" do
    context "when a transition includes initiated_by metadata" do
      let(:user) { create :user }
      let(:transition) { EfileSubmissionTransition.new(metadata: { initiated_by_id: user.id })}
      it "returns the user associated with the initiated_by_id" do
        expect(transition.initiated_by).to eq user
      end
    end

    context "when a transition does not include initiated_by metadata" do
      let(:transition) { EfileSubmissionTransition.new }
      it "returns nil" do
        expect(transition.initiated_by).to eq nil
      end
    end
  end

  context "saving efile errors after create" do
    context "when only an error code is provided" do
      context "when a matching error does not already exist" do
        let(:transition) { build :efile_submission_transition, :preparing, metadata: { error_code: "IRS-1040" } }

        it "creates a new EfileError object" do
          transition.save
          expect(EfileError.count).to eq 1
          expect(transition.efile_errors.count).to eq 1
        end
      end

      context "when a matching error already exists" do
        before do
          EfileError.create(code: "IRS-1040-PROBS", message: "You have a problem.", source: "irs")
        end

        let(:transition) { build :efile_submission_transition, :preparing, metadata: { error_code: "IRS-1040-PROBS" } }

        it "does not create a new EfileError object, but associates the existing one with the transition" do
          transition.save
          expect(EfileError.count).to eq 1
          expect(transition.efile_errors.count).to eq 1
        end
      end
    end

    context "when a code and message and a source are provided" do
      context "when it matches an existing code/message/source" do
        before do
          EfileError.create(code: "IRS-1040-PROBS", message: "You have a problem.", source: "irs")
        end
        let(:transition) { build :efile_submission_transition, :preparing, metadata: { error_code: "IRS-1040-PROBS", error_message: "You have a problem.", error_source: "irs" } }
        it "does not create a new EfileError object" do
          transition.save
          expect(EfileError.count).to eq 1
          expect(transition.efile_errors.count).to eq 1
        end
      end

      context "when it does not match an existing code/message/source pair" do
        before do
          EfileError.create(code: "IRS-1040-PROBS", message: "You have a problem.", source: "irs")
        end

        let(:transition) { build :efile_submission_transition, :preparing, metadata: { error_code: "IRS-1040-PROBS", error_message: "You have a problem", error_source: "internal" } }

        it "creates a new EfileError object" do
          expect {
            transition.save
          }.to change(EfileError, :count).by(1)
          expect(transition.efile_errors.count).to eq 1
          expect(transition.efile_errors.first.message).to eq "You have a problem"
          expect(transition.efile_errors.first.source).to eq "internal"

        end
      end
    end

    context "when the to_state is rejected and there is raw_response metadata" do
      let(:reject_transition) { build :efile_submission_transition, :rejected, metadata: { raw_response: "something" } }

      before do
        allow(Efile::SubmissionRejectionParser).to receive(:persist_errors).and_return nil
      end

      it "calls the Efile::SubmissionRejectionParser" do
        reject_transition.save
        expect(Efile::SubmissionRejectionParser).to have_received(:persist_errors).with(reject_transition)
      end
    end
  end
end
