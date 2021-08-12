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
    allow_any_instance_of(EfileSubmission).to receive(:generate_irs_address).and_return(address_service_double)
    allow(address_service_double).to receive(:valid?).and_return true
  end

  context "validation" do
    describe ".efile_security_information" do
      let(:tax_return) { build(:tax_return) }
      let(:efile_submission) { EfileSubmission.new(tax_return: tax_return, efile_security_information: efile_security_information) }

      context "without the field" do
        let(:efile_security_information) { nil }

        it "is invalid" do
          expect(efile_submission).not_to be_valid
          expect(efile_submission.errors).to include(:efile_security_information)
        end
      end

      context "with the field" do
        let(:efile_security_information) { build(:efile_security_information) }

        it "is valid" do
          expect(efile_submission).to be_valid
        end
      end
    end
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
          allow(SecureRandom).to receive(:base36).with(7).and_return "1234567"
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
    before do
      allow(ClientPdfDocument).to receive(:create_or_update)
    end
    context "new" do
      let(:submission) { create :efile_submission, :new }

      context "can transition to" do
        it "preparing" do
          expect { submission.transition_to!(:preparing) }.not_to raise_error
        end
      end

      context "when HOLD_OFF_NEW_EFILE_SUBMISSIONS is set" do
        around do |example|
          ENV['HOLD_OFF_NEW_EFILE_SUBMISSIONS'] = '1'
          example.run
          ENV.delete('HOLD_OFF_NEW_EFILE_SUBMISSIONS')
        end

        it "does not allow transitions from :new to :preparing" do
          expect { submission.transition_to!(:preparing) }.to raise_error(Statesman::GuardFailedError)
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
        allow(ClientPdfDocument).to receive(:create_or_update)
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

      end

      context "cannot transition to" do
        EfileSubmissionStateMachine.states.excluding("transmitted", "failed", "queued").each do |state|
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

      context "after transition to" do
        before { allow(MixpanelService).to receive(:send_event) }
        let!(:submission) { create(:efile_submission, :queued, submission_bundle: { filename: 'picture_id.jpg', io: File.open(Rails.root.join("spec", "fixtures", "attachments", "picture_id.jpg"), 'rb') }) }

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
        before { allow(MixpanelService).to receive(:send_event) }
        let!(:submission) { create(:efile_submission, :transmitted, submission_bundle: { filename: 'picture_id.jpg', io: File.open(Rails.root.join("spec", "fixtures", "attachments", "picture_id.jpg"), 'rb') }) }

        it "sends a mixpanel event" do
          submission.transition_to!(:accepted)

          expect(MixpanelService).to have_received(:send_event).with hash_including(
            distinct_id: submission.client.intake.visitor_id,
            event_name: "ctc_efile_return_accepted",
            subject: submission.intake,
          )
        end
      end
    end

    context "rejected" do
      context "after transition to" do
        before { allow(MixpanelService).to receive(:send_event) }
        let!(:submission) { create(:efile_submission, :transmitted, submission_bundle: { filename: 'picture_id.jpg', io: File.open(Rails.root.join("spec", "fixtures", "attachments", "picture_id.jpg"), 'rb') }) }

        it "sends a mixpanel event" do
          submission.transition_to!(:rejected)

          expect(MixpanelService).to have_received(:send_event).with hash_including(
            distinct_id: submission.client.intake.visitor_id,
            event_name: "ctc_efile_return_rejected",
            subject: submission.intake,
          )
        end
      end
    end
  end

  describe "#generate_form_1040_pdf" do
    let(:submission) { create :efile_submission, :ctc }
    let(:example_pdf) { File.open(Rails.root.join("spec", "fixtures", "attachments", "test-pdf.pdf"), "rb") }

    before do
      allow(AdvCtcIrs1040Pdf).to receive(:new).and_return(instance_double(AdvCtcIrs1040Pdf, output_file: example_pdf))
    end

    it "generates and stores the 1040 PDF" do
      expect { submission.generate_form_1040_pdf }.to change(Document, :count).by(1)
      doc = submission.client.documents.last
      expect(doc.display_name).to eq("IRS 1040 - TY 2020 - #{submission.irs_submission_id}.pdf")
      expect(doc.document_type).to eq(DocumentTypes::Form1040.key)
      expect(doc.tax_return).to eq(submission.tax_return)
      expect(doc.upload.blob.download).to eq(File.open(Rails.root.join("spec", "fixtures", "attachments", "test-pdf.pdf"), "rb").read)
    end
  end

  describe "#resubmission?" do
    context "when there was a previous submission to the irs" do
      let(:previous_submission) { create :efile_submission }
      let(:submission) { create :efile_submission }
      before do
        submission.transition_to!(:preparing, previous_submission_id: previous_submission.id)
      end

      it "returns true" do
        expect(submission.resubmission?).to eq true
      end
    end

    context "when there was a previous status transition of the existing submission to resubmitted" do
      let(:submission) { create :efile_submission, :rejected }
      before do
        submission.transition_to!(:resubmitted)
      end

      it "returns true" do
        expect(submission.resubmission?).to eq true
      end
    end

    context "when the submission is not a resubmission" do
      let(:submission) { create :efile_submission, :preparing }
      it "returns false" do
        expect(submission.resubmission?).to eq false
      end
    end
  end

  describe "#previously_transmitted_submission" do
    context "when the submission's preparing transition has a previous submission id stored" do
      let(:previous_submission) { create :efile_submission }
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

  describe "last_client_accessible_transition" do
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
end
