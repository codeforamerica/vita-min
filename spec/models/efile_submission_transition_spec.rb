# == Schema Information
#
# Table name: efile_submission_transitions
#
#  id                    :bigint           not null, primary key
#  efile_submission_type :string           default("EfileSubmission"), not null
#  metadata              :jsonb
#  most_recent           :boolean          not null
#  sort_key              :integer          not null
#  to_state              :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  efile_submission_id   :integer          not null
#
# Indexes
#
#  index_efile_sub_transitions_on_efile_sub_type_and_efile_sub_id  (efile_submission_type,efile_submission_id)
#  index_efile_submission_transitions_on_created_at                (created_at)
#  index_efile_submission_transitions_parent_most_recent           (efile_submission_id,most_recent) UNIQUE WHERE most_recent
#  index_efile_submission_transitions_parent_sort                  (efile_submission_id,sort_key) UNIQUE
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
end
