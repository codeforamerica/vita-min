# == Schema Information
#
# Table name: efile_submissions
#
#  id                      :bigint           not null, primary key
#  last_checked_for_ack_at :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  irs_submission_id       :string
#  tax_return_id           :bigint
#
# Indexes
#
#  index_efile_submissions_on_created_at            (created_at)
#  index_efile_submissions_on_irs_submission_id     (irs_submission_id)
#  index_efile_submissions_on_tax_return_id         (tax_return_id)
#  index_efile_submissions_on_tax_return_id_and_id  (tax_return_id,id DESC)
#
require "rails_helper"

describe EfileSubmission do
  before do
    address_service_double = double
    allow(StandardizeAddressService).to receive(:new).and_return(address_service_double)
    allow(address_service_double).to receive(:valid?).and_return true
    allow(address_service_double).to receive(:zip_code).and_return "77494"
    allow(address_service_double).to receive(:street_address).and_return "23627 Hawkins Creek Ct"
    allow(address_service_double).to receive(:state).and_return "TX"
    allow(address_service_double).to receive(:city).and_return "Katy"
  end

  context "generating an irs_submission_id" do
    context "adhering to IRS format" do
      around do |example|
        Timecop.freeze(Date.new(2022, 1, 1))
        example.run
        Timecop.return
      end

      let(:submission) { create(:efile_submission, :ctc) }

      it "conforms to the IRS format [0-9]{13}[a-z0-9]{7}" do
        submission.generate_irs_submission_id!
        expect(submission.irs_submission_id).to match(/\A[0-9]{13}[a-z0-9]{7}\z/)
      end

      it "the first 6 digits are our 6 digit EFIN" do
        submission.generate_irs_submission_id!
        expect(submission.irs_submission_id[0..5]).to eq EnvironmentCredentials.dig(:irs, :efin)
      end

      it "the next 7 digits are a date in format ccyyddd" do
        submission.generate_irs_submission_id!
        expect(submission.irs_submission_id[6..12]).to eq "2022001"
      end

      context "dealing with duplicates" do
        before do
          allow(SecureRandom).to receive(:base36).with(7).and_return "1234567"
          create :efile_submission, irs_submission_id: "#{EnvironmentCredentials.dig(:irs, :efin)}20220011234567"
        end

        context "after trying 5 times" do
          it "an error is raised" do
            expect {
              submission.generate_irs_submission_id!
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
    before do
      allow(ClientPdfDocument).to receive(:create_or_update)
    end

    context "preparing" do
      let(:submission) { create :efile_submission, :preparing }

      context "with a fraud score relation" do
        before do
          Fraud::Score.create_from(submission)
        end

        it "can transition to bundling" do
          expect { submission.transition_to!(:bundling) }.not_to raise_error
        end

        context "when HOLD_OFF_NEW_EFILE_SUBMISSIONS is set" do
          around do |example|
            ENV['HOLD_OFF_NEW_EFILE_SUBMISSIONS'] = '1'
            example.run
            ENV.delete('HOLD_OFF_NEW_EFILE_SUBMISSIONS')
          end

          it "does not allow transitions from :preparing to :bundling" do
            expect { submission.transition_to!(:bundling) }.to raise_error(Statesman::GuardFailedError)
          end
        end

        context "cannot transition to" do
          EfileSubmissionStateMachine.states.excluding("new", "bundling", "fraud_hold").each do |state|
            it state.to_s do
              expect { submission.transition_to!(state) }.to raise_error(Statesman::TransitionFailedError)
            end
          end
        end
      end

      context "without a fraud score relationship" do
        it "cannot transition" do
          expect { submission.transition_to!(:bundling) }.to raise_error(Statesman::GuardFailedError)
        end
      end
    end

    context "bundling" do
      let(:submission) { create :efile_submission, :bundling }
      before do
        address_service_double = double
        allow(ClientPdfDocument).to receive(:create_or_update)
        allow_any_instance_of(EfileSubmission).to receive(:generate_verified_address).and_return(address_service_double)
        allow(address_service_double).to receive(:valid?).and_return true
        allow_any_instance_of(EfileSubmission).to receive(:submission_bundle).and_return "fake_zip"
      end

      context "can transition to" do
        it "queued" do
          expect { submission.transition_to!(:queued) }.not_to raise_error
        end

        it "failed" do
          expect { submission.transition_to!(:failed) }.not_to raise_error
        end
      end

      context "cannot transition to" do
        EfileSubmissionStateMachine.states.excluding("queued", "bundling", "fraud_hold", "failed").each do |state|
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

      end

      context "cannot transition to" do
        EfileSubmissionStateMachine.states.excluding("transmitted", "failed", "queued", "fraud_hold").each do |state|
          it state.to_s do
            expect { submission.transition_to!(state) }.to raise_error(Statesman::TransitionFailedError)
          end
        end
      end

      context "after transition to" do
        let!(:submission) { create(:efile_submission, :bundling, :with_fraud_score, submission_bundle: { filename: 'picture_id.jpg', io: File.open(Rails.root.join("spec", "fixtures", "files", "picture_id.jpg"), 'rb') }) }

        it "queues a GyrEfilerSendSubmissionJob" do
          expect do
            submission.transition_to!(:queued)
          end.to have_enqueued_job(GyrEfiler::SendSubmissionJob).with(submission)
        end
      end
    end

    context "fraud_hold" do
      let(:submission) { create :efile_submission, :fraud_hold }
      transitionable_states = [:investigating, :resubmitted, :waiting, :cancelled]
      context "can transition to " do
        transitionable_states.each do |state|
          it state.to_s do
            expect { submission.transition_to!(state) }.not_to raise_error
          end
        end
      end

      context "cannot transition to" do
        EfileSubmissionStateMachine.states.excluding(*transitionable_states.map(&:to_s)).each do |state|
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
        EfileSubmissionStateMachine.states.excluding("accepted", "rejected", "transmitted", "failed").each do |state|
          it state.to_s do
            expect { submission.transition_to!(state) }.to raise_error(Statesman::TransitionFailedError)
          end
        end
      end

      context "after transition to" do
        before { allow(MixpanelService).to receive(:send_event) }
        let!(:submission) { create(:efile_submission, :queued, submission_bundle: { filename: 'picture_id.jpg', io: File.open(Rails.root.join("spec", "fixtures", "files", "picture_id.jpg"), 'rb') }) }

        it "sends a mixpanel event" do
          submission.transition_to!(:transmitted)

          expect(MixpanelService).to have_received(:send_event).with hash_including(
            distinct_id: submission.client.intake.visitor_id,
            event_name: "ctc_efile_return_transmitted",
            subject: submission.intake,
          )
        end
      end
    end

    context "accepted" do
      context "after transition to" do
        before do
          allow(MixpanelService).to receive(:send_event)
          allow_any_instance_of(Efile::BenefitsEligibility).to receive(:ctc_amount).and_return(3600)
          allow_any_instance_of(Efile::BenefitsEligibility).to receive(:claimed_recovery_rebate_credit).and_return(1200)
          allow_any_instance_of(Efile::BenefitsEligibility).to receive(:eip3_amount).and_return(3000)
        end

        let!(:submission) { create(:efile_submission, :transmitted, submission_bundle: { filename: 'picture_id.jpg', io: File.open(Rails.root.join("spec", "fixtures", "files", "picture_id.jpg"), 'rb') }) }

        it "sends a mixpanel event" do
          submission.transition_to!(:accepted)

          expect(MixpanelService).to have_received(:send_event).with hash_including(
            distinct_id: submission.client.intake.visitor_id,
            event_name: "ctc_efile_return_accepted",
            subject: submission.intake,
            data: {
              child_tax_credit_advance: 1800,
              recovery_rebate_credit: 0,
              third_stimulus_amount: 3000
            }
          )
        end
      end
    end

    context "rejected" do
      context "after transition to" do
        let(:submission) { create(:efile_submission, :transmitted) }
        let(:efile_error) { create(:efile_error, code: "IRS-ERROR", expose: true, auto_wait: false, auto_cancel: false) }

        it "enqueues an AfterTransitionTasksForRejectedReturnJob" do
          submission.transition_to!(:rejected, error_code: efile_error.code)

          expect(AfterTransitionTasksForRejectedReturnJob).to have_been_enqueued.with(submission, submission.last_transition)
        end
      end
    end
  end

  describe "#generate_verified_address" do
    context "when there is an existing address" do
      let(:submission) { create :efile_submission, :preparing }
      let!(:address) { create :address, record: submission, skip_usps_validation: true }

      it "returns an object that we can call valid on and does not connect to USPS service" do

        expect(submission.generate_verified_address.valid?).to be true
        expect(StandardizeAddressService).not_to have_received(:new)
      end
    end
  end

  describe "#admin_resubmission?" do
    let(:submission) { create :efile_submission, :bundling }
    let(:user) { create :admin_user }

    context "when it is the only submission for the client" do
      it "is falsey" do
        expect(submission.admin_resubmission?).to eq false
      end
    end

    context "when the client has more than one submission" do
      context "when the previous submission was resubmitted" do
        let!(:previous_submission) { create :efile_submission, :failed }

        context "when the resubmission was by an admin user" do
          it "is true" do
            expect {
              previous_submission.transition_to!(:resubmitted, initiated_by_id: user.id)
            }.to change(EfileSubmission, :count).by 1
            latest_submission = previous_submission.client.efile_submissions.last
            expect(latest_submission.id).not_to eq previous_submission.id
            expect(latest_submission.admin_resubmission?).to eq true
          end
        end

        context "when the resubmission was not by a user" do
          let(:previous_submission) { create :efile_submission, :resubmitted, metadata: { initiated_by_id: nil } }


          it "is false" do
            submission = previous_submission.tax_return.efile_submissions.last
            expect(submission.admin_resubmission?).to eq false
          end
        end

        context "when the resubmission was not by an admin user" do
          let(:user) { create :team_member_user }
          let(:previous_submission) { create :efile_submission, :resubmitted, metadata: { initiated_by_id: user.id } }

          it "is false" do
            submission = previous_submission.tax_return.efile_submissions.last
            expect(submission.admin_resubmission?).to eq false
          end
        end
      end
    end
  end

  describe "#generate_filing_pdf" do
    let(:submission) { create :efile_submission, :ctc }
    let(:example_pdf) { File.open(Rails.root.join("spec", "fixtures", "files", "test-pdf.pdf"), "rb") }

    before do
      allow(Irs1040Pdf).to receive(:new).and_return(instance_double(Irs1040Pdf, output_file: example_pdf))
      allow(Irs8812Ty2021Pdf).to receive(:new).and_return(instance_double(Irs8812Ty2021Pdf, output_file: example_pdf))
      allow(Irs1040ScheduleLepPdf).to receive(:new).and_return(instance_double(Irs1040ScheduleLepPdf, output_file: example_pdf))
    end

    context "the filer is claiming CTC (line 28 is greater than $0)" do
      before do
        create(:qualifying_child, intake: submission.intake)
        submission.create_qualifying_dependents
        submission.reload
      end

      it "generates and stores the 1040 and 8812 combined PDF" do
        expect { submission.generate_filing_pdf }.to change(Document, :count).by(1)
        doc = submission.client.documents.last
        expect(doc.display_name).to eq("IRS 1040 - TY#{TaxReturn.current_tax_year}.pdf")
        expect(Irs8812Ty2021Pdf).to have_received(:new)
        expect(doc.document_type).to eq(DocumentTypes::Form1040.key)
        expect(doc.tax_return).to eq(submission.tax_return)
        expect(doc.upload.blob.download).not_to be_nil
      end
    end

    context "the filer is not claiming CTC (line 28 = $0 or missing)" do
      before do
        allow(submission).to receive(:irs_submission_id).and_return "123456789"
      end

      it "generates and stores just the 1040 (does not generate the 8812)" do
        expect { submission.generate_filing_pdf }.to change(Document, :count).by(1)
        expect(Irs1040Pdf).to have_received(:new)
        expect(Irs8812Ty2021Pdf).not_to have_received(:new)
        doc = submission.client.documents.last
        expect(doc.display_name).to eq("IRS 1040 - TY#{TaxReturn.current_tax_year} - 789.pdf")
        expect(doc.document_type).to eq(DocumentTypes::Form1040.key)
        expect(doc.tax_return).to eq(submission.tax_return)
        expect(doc.upload.blob.download).not_to be_nil
      end
    end

    context "the filer requested a language change" do
      before do
        submission.intake.update(irs_language_preference: "spanish")
      end

      it "attaches the schedule lep" do
        expect { submission.generate_filing_pdf }.to change(Document, :count).by(1)
        expect(Irs1040Pdf).to have_received(:new)
        expect(Irs1040ScheduleLepPdf).to have_received(:new)
        expect(Irs8812Ty2021Pdf).not_to have_received(:new)
        doc = submission.client.documents.last
        expect(doc.display_name).to eq("IRS 1040 - TY#{TaxReturn.current_tax_year}.pdf")
        expect(doc.document_type).to eq(DocumentTypes::Form1040.key)
        expect(doc.tax_return).to eq(submission.tax_return)
        expect(doc.upload.blob.download).not_to be_nil
      end
    end
  end

  describe "#previously_transmitted_submission" do
    context "when the submission's preparing transition has a previous submission id stored" do
      let(:previous_submission) { create :efile_submission, :transmitted }
      let(:submission) { create :efile_submission }
      before do
        submission.transition_to!(:preparing, previous_submission_id: previous_submission.id)
      end

      it "returns the submission object" do
        expect(submission.previously_transmitted_submission).to eq previous_submission
      end
    end

    context "when the submissions preparing transition does not have a previous submission id stored" do
      let(:submission) { create :efile_submission, :preparing }

      it "returns the submission object" do
        expect(submission.previously_transmitted_submission).to eq nil
      end
    end
  end

  describe "#accepted_as_imperfect_return?" do
    context "when not accepted status" do
      let(:efile_submission) { create :efile_submission, :rejected }
      it "returns false" do
        expect(efile_submission.accepted_as_imperfect_return?).to eq false
      end
    end

    context "when current status is accepted but was not an imperfect return acceptance on metadata" do
      let(:efile_submission) { create :efile_submission, :accepted }

      it "returns false" do
        expect(efile_submission.accepted_as_imperfect_return?).to eq false

      end
    end

    context "when current status is accepted and imperfect return acceptance is present on metadata" do
      let(:efile_submission) { create :efile_submission, :accepted, metadata: { imperfect_return_acceptance: true } }

      it "returns true" do
        expect(efile_submission.accepted_as_imperfect_return?).to eq true
      end
    end
  end

  describe "#imperfect_return_resubmission?" do
    context "when the submission's preparing transition has a previous submission id stored" do
      let(:previous_submission) { create(:efile_submission, :transmitted) }
      let(:efile_error) { create(:efile_error, code: "SOMETHING-WRONG") }
      let(:submission) { create :efile_submission }

      before do
        create(:efile_submission_transition, :rejected, efile_submission: previous_submission, efile_error_ids: [efile_error.id], most_recent: false, sort_key: 1000)
        submission.transition_to!(:preparing, previous_submission_id: previous_submission.id)
      end

      context "and the previous submission had an inapplicable error" do
        it "returns false" do
          expect(submission.imperfect_return_resubmission?).to eq(false)
        end
      end

      context "and the previous submission had a R0000-504-02 error" do
        let!(:efile_error) { create(:efile_error, code: "R0000-504-02") }

        it "returns true" do
          expect(submission.imperfect_return_resubmission?).to eq(true)
        end
      end
    end
  end

  describe "#last_client_accessible_transition" do
    context "when the status of the last_transition is investigating" do
      let(:efile_submission) { create :efile_submission, :rejected }

      before do
        efile_submission.transition_to!(:investigating)
      end

      it "returns last_transition" do
        expect(efile_submission.last_client_accessible_transition).to eq (efile_submission.efile_submission_transitions.where(to_state: 'rejected').last)
      end
    end

    context "when the status of the last_transition is waiting" do
      let(:efile_submission) { create :efile_submission, :rejected }

      before do
        efile_submission.transition_to!(:waiting)
      end

      it "returns last_transition" do
        expect(efile_submission.last_client_accessible_transition).to eq (efile_submission.efile_submission_transitions.where(to_state: 'rejected').last)
      end
    end

    context "when the last several statuses are things that should not be shown to clients" do
      let(:efile_submission) { create :efile_submission, :rejected }

      before do
        efile_submission.transition_to!(:waiting)
        efile_submission.transition_to!(:investigating)
      end

      it "returns the last transition suitable for showing to clients" do
        expect(efile_submission.last_client_accessible_transition).to eq (efile_submission.efile_submission_transitions.where(to_state: 'rejected').last)
      end
    end

    context "when the status of the last_transition is not investigating" do
      let(:efile_submission) { create :efile_submission, :preparing }
      it "returns last_transition" do
        expect(efile_submission.last_client_accessible_transition).to eq (efile_submission.last_transition)
      end
    end

    context "when there is no last_transition" do
      let(:efile_submission) { create :efile_submission }
      it "returns nil" do
        expect(efile_submission.last_client_accessible_transition).to eq nil
      end
    end
  end

  describe "#retry_send_submission" do
    before do
      allow(SecureRandom).to receive(:rand).with(30).and_return(4)
    end

    context "when the submission was queued fairly recently" do
      it "enqueues the SendSubmission job with exponential backoff plus jitter", active_job: true do
        freeze_time do
          submission = create(:efile_submission, :queued)
          submission.efile_submission_transitions.where(to_state: "queued").update(created_at: 1.minute.ago)
          clear_enqueued_jobs
          expected_delay = (1.minute ** 1.25) + 4

          expect {
            submission.retry_send_submission
          }.to have_enqueued_job(GyrEfiler::SendSubmissionJob).at(Time.now.utc + expected_delay).with(submission)
        end
      end
    end

    context "when the submission was queued more than one hour ago" do
      it "enqueues the SendSubmission job with 60 minute delay plus jitter", active_job: true do
        freeze_time do
          submission = create(:efile_submission, :queued)
          submission.efile_submission_transitions.where(to_state: "queued").update(created_at: 61.minutes.ago)
          clear_enqueued_jobs
          expected_delay = 60.minutes + 4

          expect {
            submission.retry_send_submission
          }.to have_enqueued_job(GyrEfiler::SendSubmissionJob).at(Time.now.utc + expected_delay).with(submission)
        end
      end
    end

    context "when the submission was queued more than one day ago" do
      it "marks the submission as failed", active_job: true do
        freeze_time do
          submission = create(:efile_submission, :queued)
          submission.efile_submission_transitions.where(to_state: "queued").update(created_at: (1.01).days.ago)
          clear_enqueued_jobs

          expect {
            submission.retry_send_submission
          }.not_to have_enqueued_job(GyrEfiler::SendSubmissionJob)
          expect(submission.current_state).to eq("failed")
        end
      end

      context "and there is a resubmission initiated by a user very recently" do
        it "enqueues the SendSubmission job with exponential backoff plus jitter", active_job: true do
          freeze_time do
            submission = create(:efile_submission, :queued)
            submission.efile_submission_transitions.where(to_state: "queued").last.update(created_at: 1.minute.ago)
            clear_enqueued_jobs
            expected_delay = (1.minute ** 1.25) + 4

            expect {
              submission.retry_send_submission
            }.to have_enqueued_job(GyrEfiler::SendSubmissionJob).at(Time.now.utc + expected_delay).with(submission)
          end
        end
      end
    end
  end
end
