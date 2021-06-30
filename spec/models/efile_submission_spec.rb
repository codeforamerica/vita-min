# == Schema Information
#
# Table name: efile_submissions
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  tax_return_id :bigint
#
# Indexes
#
#  index_efile_submissions_on_tax_return_id  (tax_return_id)
#
require "rails_helper"

describe EfileSubmission do
  describe "#irs_submission_id" do
    let(:submission) { create :efile_submission, :ctc }
    it "conforms to the IRS format [0-9]{13}[a-z0-9]{7}" do
      expect(/[0-9]{13}[a-z0-9]{7}\z/.match?(submission.irs_submission_id)).to eq true
    end

    context "including the efile submission id" do
      context "control character" do
        it "uses the first digit as a control character (0) that can be incremented later if needed" do
          expect(submission.irs_submission_id.chars.first).to eq "0"
        end
      end

      context "when the id is less than 12 characters" do
        before do
          submission.update(id: 101)
        end

        it "prepends 0s to make the string 13 characters" do
          expect(submission.irs_submission_id.chars.first(13).join("")).to eq "0000000000101"
        end
      end

      context "when the id is 11+ characters" do
        before do
          submission.update(id: 1234567891234)
          allow(Rails.logger).to receive(:warn)
        end

        it "truncates the id and logs a warning" do
          expect(submission.irs_submission_id.chars.first(13).join("")).to eq "0123456789123"
          expect(Rails.logger).to have_received(:warn)
        end
      end
    end

    context "including primary last name (last 7 chars)" do
      context "with a 7 character name" do
        before do
          submission.intake.update(primary_last_name: "BANANAS")
        end

        it "downcases the last name" do
          expect(submission.irs_submission_id.chars.last(7).join("")).to eq "bananas"
        end
      end

      context "when the last name is more than 7 chars" do
        before do
          submission.intake.update(primary_last_name: "Persimmon")
        end

        it "truncates the name to the first 7 chars" do
          expect(submission.irs_submission_id.chars.last(7).join("")).to eq "persimm"
        end
      end

      context "when the last name is less than 7 chars" do
        before do
          submission.intake.update(primary_last_name: "Apple")
        end

        it "pads the name in the submission with x" do
          expect(submission.irs_submission_id.chars.last(7).join("")).to eq "xxapple"
        end
      end
    end
  end

  context 'a newly created submission' do
    let(:submission) { create :efile_submission }
    it 'has an initial current_state of new' do
      expect(submission.current_state).to eq "new"
    end
  end

  context "transitions" do
    context "new" do
      let(:submission) { create :efile_submission }
      context "can transition to" do
        it "preparing" do
          expect { submission.transition_to!(:preparing) }.not_to raise_error
        end
      end

      context "cannot transition to" do
        EfileSubmissionStateMachine.states.excluding("new", "preparing").each do |state|
          it state.to_s do
            expect { submission.transition_to!(state) }.to raise_error(Statesman::TransitionFailedError)
          end
        end
      end
    end

    context "preparing" do
      let(:submission) { create :efile_submission, :preparing }
      context "can transition to" do
        it "queued" do
          expect { submission.transition_to!(:queued) }.not_to raise_error
        end
      end

      context "cannot transition to" do
        EfileSubmissionStateMachine.states.excluding("queued", "preparing").each do |state|
          it state.to_s do
            expect { submission.transition_to!(state) }.to raise_error(Statesman::TransitionFailedError)
          end
        end
      end
    end

    context "queued" do
      let(:submission) { create :efile_submission, :queued }
      context "can transition to" do
        it "transmitted" do
          expect { submission.transition_to!(:transmitted) }.not_to raise_error
        end

        it "failed" do
          expect { submission.transition_to!(:failed) }.not_to raise_error
        end

        it "rejected" do
          expect { submission.transition_to!(:rejected) }.not_to raise_error
        end
      end

      context "cannot transition to" do
        EfileSubmissionStateMachine.states.excluding("transmitted", "failed", "rejected", "queued").each do |state|
          it state.to_s do
            expect { submission.transition_to!(state) }.to raise_error(Statesman::TransitionFailedError)
          end
        end
      end
    end

    context "transmitted" do
      let(:submission) { create :efile_submission, :transmitted }
      context "can transition to" do
        it "accepted" do
          expect { submission.transition_to!(:accepted) }.not_to raise_error
        end

        it "rejected" do
          expect { submission.transition_to!(:rejected) }.not_to raise_error
        end
      end

      context "cannot transition to" do
        EfileSubmissionStateMachine.states.excluding("accepted", "rejected", "transmitted").each do |state|
          it state.to_s do
            expect { submission.transition_to!(state) }.to raise_error(Statesman::TransitionFailedError)
          end
        end
      end
    end
  end
end
