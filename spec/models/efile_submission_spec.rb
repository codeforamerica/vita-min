# == Schema Information
#
# Table name: efile_submissions
#
#  id                :bigint           not null, primary key
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  irs_submission_id :string
#  tax_return_id     :bigint
#
# Indexes
#
#  index_efile_submissions_on_tax_return_id  (tax_return_id)
#
require "rails_helper"

describe EfileSubmission do
  before do
    address_service_double = double
    allow(EnvironmentCredentials).to receive(:dig).with(:irs, :efin).and_return "111111"
    allow_any_instance_of(EfileSubmission).to receive(:generate_irs_address).and_return(address_service_double)
    allow(address_service_double).to receive(:valid?).and_return true
  end

  context "generating an irs_submission_id before create" do
    context "adhering to IRS format" do
      around do |example|
        Timecop.freeze(Date.new(2021, 1, 1))
        example.run
        Timecop.return
      end

      let(:submission) { create(:efile_submission, :ctc) }

      it "conforms to the IRS format [0-9]{13}[a-z0-9]{7}" do
        expect(submission.irs_submission_id).to match(/\A[0-9]{13}[a-z0-9]{7}\z/)
      end

      it "the first 6 digits are our 6 digit EFIN" do
        expect(submission.irs_submission_id[0..5]).to eq EnvironmentCredentials.dig(:irs, :efin)
      end

      it "the next 7 digits are a date in format ccyyddd" do
        expect(submission.irs_submission_id[6..12]).to eq "2021001"
      end

      context "dealing with duplicates" do
        before do
          allow(SecureRandom).to receive(:base36).with(7).and_return "111111"
        end
        context "after trying 5 times" do

          it "an error is raised" do
            expect {
              5.times do
                create :efile_submission
              end
            }.to raise_error StandardError, "Max irs_submission_id attempts exceeded. Too many submissions today?"
          end
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
      before do
        address_service_double = double
        allow_any_instance_of(EfileSubmission).to receive(:generate_irs_address).and_return(address_service_double)
        allow(address_service_double).to receive(:valid?).and_return true
        allow_any_instance_of(EfileSubmission).to receive(:submission_bundle).and_return "fake_zip"
      end

      context "can transition to" do
        it "queued" do
          expect { submission.transition_to!(:queued) }.not_to raise_error
        end
      end

      context "cannot transition to" do
        EfileSubmissionStateMachine.states.excluding("queued", "preparing", "failed").each do |state|
          it state.to_s do
            expect { submission.transition_to!(state) }.to raise_error(Statesman::TransitionFailedError)
          end
        end
      end

      context "after transition to" do
        let(:submission) { create(:efile_submission, :new) }

        it "queues a BuildSubmissionBundleJob" do
          expect do
            submission.transition_to!(:preparing)
          end.to have_enqueued_job(BuildSubmissionBundleJob).with(submission.id)
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

      context "after transition to" do
        let!(:submission) { create(:efile_submission, :preparing, submission_bundle: { filename: 'picture_id.jpg', io: File.open(Rails.root.join("spec", "fixtures", "attachments", "picture_id.jpg"), 'rb') }) }

        it "queues a GyrEfilerSendSubmissionJob" do
          expect do
            submission.transition_to!(:queued)
          end.to have_enqueued_job(GyrEfiler::SendSubmissionJob).with(submission)
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

  describe "#previously_transmitted_submission" do
    context "when there is a previous submission for the tax return that was transmitted to the IRS" do
      let(:submission) { create :efile_submission, :preparing }
      let(:previous_submission) { create(:efile_submission, :transmitted) }
      let!(:tax_return) { create :tax_return, efile_submissions: [previous_submission, create(:efile_submission, :failed), submission]}

      it "returns the transmitted submission object" do
        expect(submission.previously_transmitted_submission).to eq previous_submission
      end
    end

    context "when there is a previous submission for the tax return, but it was never transmitted" do
      let(:submission) { create :efile_submission, :preparing }
      let!(:tax_return) { create :tax_return, efile_submissions: [create(:efile_submission, :failed), submission]}
      it "returns nil" do
        expect(submission.previously_transmitted_submission).to eq nil
      end
    end
  end
end
