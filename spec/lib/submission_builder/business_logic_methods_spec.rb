require 'rails_helper'

class DummyClass
  include SubmissionBuilder::BusinessLogicMethods
  attr_reader :submission

  def initialize(submission)
    @submission = submission
  end
end

describe SubmissionBuilder::BusinessLogicMethods do
  let(:dummy_instance) { DummyClass.new(submission) }
  let(:submission_created_at) { Time.now }
  let(:intake_created_at) { 40.minutes.ago }
  let(:intake) { create :state_file_ny_intake, created_at: intake_created_at }
  let(:submission) { create :efile_submission, :for_state, data_source: intake, created_at: submission_created_at }

  describe "#state_file_total_preparation_submission_minutes" do
    context "when intake was created 40 minutes ago" do
      it "returns 40 for state_file_total_preparation_submission_minutes" do
        expect(dummy_instance.state_file_total_preparation_submission_minutes).to eq 40
      end
    end

    context "when intake was created 2 days ago" do
      let(:intake_created_at) { 2.days.ago }

      it "returns 2880 for state_file_total_preparation_submission_minutes" do
        expect(dummy_instance.state_file_total_preparation_submission_minutes).to eq 2880
      end
    end
  end
end