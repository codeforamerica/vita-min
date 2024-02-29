require 'rails_helper'

describe EfileSubmissionStateMachine do
  before do
    allow(ClientPdfDocument).to receive(:create_or_update)
    allow(ClientMessagingService).to receive(:send_system_message_to_all_opted_in_contact_methods)
    create :fraud_indicator
  end

  describe "after_transition" do
    context "to preparing" do
      let(:submission) { create(:efile_submission, :new) }

      context "EfileSubmissionDependent creation" do
        before do
          submission.intake.dependents.delete_all
          create :qualifying_child, intake: submission.intake # creates object
          create :qualifying_relative, intake: submission.intake # creates object
          create :dependent, intake: submission.intake # does not qualify, does not create object
        end

        it "creates EfileSubmissionDependent objects for each qualifying dependent" do
          expect(submission.intake.dependents.length).to eq 3
          expect {
            submission.transition_to(:preparing)
          }.to change(EfileSubmissionDependent, :count).by 2
        end

        context "when objects already exist for some dependents" do
          before do
            EfileSubmissionDependent.create(dependent: submission.intake.dependents.first, efile_submission: submission)
          end

          it "does not create duplicated objects" do
            expect(submission.intake.dependents.length).to eq 3
            expect(EfileSubmissionDependent.where(efile_submission: submission).count).to eq 1
            submission.transition_to(:preparing)
            expect(submission.qualifying_dependents.count).to eq 2 # there is still only one entry for each qualifying dependent
          end
        end
      end

      context "calculating spouse agi" do
        context "when the filer is not married_filing_jointly" do
          it "does not do any calculations" do
            expect {
              submission.transition_to!(:preparing)
            }.not_to change(submission.intake, :spouse_prior_year_agi_amount)
          end
        end

        context "when the filer is married_filing_jointly" do
          before do
            submission.tax_return.update(filing_status: "married_filing_jointly")
          end


          context "when it is the first submission" do
            before do
              allow(submission.intake).to receive(:spouse_prior_year_agi_amount_computed).and_return 501
              submission.intake.update(spouse_prior_year_agi_amount: nil, spouse_filed_prior_tax_year: 'filed_non_filer_separate')
            end

            it "calculates the AGI based on previous year filing" do
              expect {
                submission.transition_to!(:preparing)
              }.to change(submission.intake, :spouse_prior_year_agi_amount).to 501

              expect(submission.intake).to have_received(:spouse_prior_year_agi_amount_computed)
            end
          end

          context "when it is not the first submission" do
            let(:previous_submission) { create :efile_submission }
            it "does not do any calculations" do
              expect {
                submission.transition_to!(:preparing, previous_submission_id: previous_submission.id)
              }.not_to change(submission.intake, :spouse_prior_year_agi_amount)
            end
          end
        end
      end

      context "without blocking fraud characteristics" do
        it "enqueues a BuildSubmissionBundleJob" do
          expect {
            submission.transition_to!(:preparing)
          }.to have_enqueued_job(BuildSubmissionBundleJob)
        end

        it "updates the tax return status" do
          submission.transition_to!(:preparing)
          expect(ClientMessagingService).to have_received(:send_system_message_to_all_opted_in_contact_methods).with(
            client: submission.client.reload,
            message: AutomatedMessage::EfilePreparing,
          )
        end
      end

      context "when the client has had their identity verified" do
        before do
          submission.client.touch(:identity_verified_at)
        end

        it "does not check for fraud indicators" do
          submission.transition_to!(:preparing)
        end

        it "transitions to the next status to build the bundle" do
          submission.transition_to!(:preparing)
          expect(submission.current_state).to eq("bundling")
        end
      end

      context "with blocking fraud characteristics" do
        before do
          stub_const("Fraud::Score::HOLD_THRESHOLD", Fraud::Score::HOLD_THRESHOLD)
          stub_const("Fraud::Score::RESTRICT_THRESHOLD", Fraud::Score::RESTRICT_THRESHOLD)
          allow_any_instance_of(Fraud::Score).to receive(:score).and_return (Fraud::Score::HOLD_THRESHOLD + 100)
        end

        it "transitions the tax return status and submission status to hold" do
          submission.transition_to!(:preparing)
          expect(submission.current_state).to eq "fraud_hold"
          expect(submission.tax_return.current_state).to eq("file_fraud_hold")
        end
      end

      context "with blocking fraud characteristics that restrict" do
        before do
          stub_const("Fraud::Score::HOLD_THRESHOLD", Fraud::Score::HOLD_THRESHOLD)
          stub_const("Fraud::Score::RESTRICT_THRESHOLD", Fraud::Score::RESTRICT_THRESHOLD)
          allow_any_instance_of(Fraud::Score).to receive(:score).and_return (Fraud::Score::RESTRICT_THRESHOLD)
        end

        it "transitions the tax return status and submission status to hold" do
          submission.transition_to!(:preparing)
          expect(submission.current_state).to eq "fraud_hold"
          expect(submission.client.restricted_at).not_to be_nil
          expect(submission.tax_return.current_state).to eq("file_fraud_hold")
        end
      end
    end

    context "to bundling" do
      let!(:submission) { create(:efile_submission, :preparing, :with_fraud_score) }

      it "messages the client and changes their tax return status" do
        submission.transition_to!(:bundling)
        expect(ClientMessagingService).to have_received(:send_system_message_to_all_opted_in_contact_methods).with(
          client: submission.client.reload,
          message: AutomatedMessage::EfilePreparing,
        )
        expect(submission.tax_return.current_state).to eq("file_ready_to_file")

      end
    end

    context "to transmitted" do
      let(:submission) { create(:efile_submission, :queued) }

      it "updates the tax return status" do
        submission.transition_to!(:transmitted)
        expect(submission.tax_return.current_state).to eq("file_efiled")
      end

      context "state file intakes" do
        before do
          submission.update(data_source: create(:state_file_az_intake))
        end

        it "creates a record to store the analytics data" do
          expect {
            submission.transition_to(:transmitted)
          }.to change(StateFileAnalytics, :count).by 1

          expect(submission.data_source.state_file_analytics.fed_eitc_amount).to eq 1776
          expect(submission.data_source.state_file_analytics.filing_status).to eq 1
          expect(submission.data_source.state_file_analytics.refund_or_owed_amount).to eq -2011
        end

        context "when state is already transmitted" do
          let(:submission) { create(:efile_submission, :queued) }
          before { submission.transition_to(:transmitted) }

          it "sucessfully transitions to transmitted" do
            expect {
              submission.transition_to(:transmitted)
            }.not_to change(StateFileAnalytics, :count)
          end
        end
      end
    end

    context "to failed" do
      let(:submission) { create(:efile_submission, :queued) }
      let(:efile_error) { create(:efile_error, code: "USPS", expose: true, auto_wait: false, auto_cancel: false) }

      before do
        allow(ClientMessagingService).to receive(:send_system_message_to_all_opted_in_contact_methods)
      end

      it "updates the tax return status" do
        submission.transition_to!(:failed, error_code: efile_error.code)
        expect(submission.tax_return.current_state).to eq("file_needs_review")
      end

      context "with an exposed error" do
        it "sends the client a message" do
          submission.transition_to!(:failed, error_code: efile_error.code)
          expect(ClientMessagingService).to have_received(:send_system_message_to_all_opted_in_contact_methods).with(
            client: submission.client.reload,
            message: AutomatedMessage::EfileFailed,
          )
        end
      end

      context "without an exposed error" do
        let(:efile_error) { create(:efile_error, code: "USPS", expose: false) }

        it "does not send a message" do
          submission.transition_to!(:failed)
          expect(ClientMessagingService).not_to have_received(:send_system_message_to_all_opted_in_contact_methods)
        end
      end
    end

    context "to rejected" do
      let(:submission) { create(:efile_submission, :transmitted) }
      let(:efile_error) { create(:efile_error, code: "IRS-ERROR", expose: true, auto_wait: false, auto_cancel: false) }

      it "enqueues an AfterTransitionTasksForRejectedReturnJob" do
        submission.transition_to!(:rejected, error_code: efile_error.code)

        expect(AfterTransitionTasksForRejectedReturnJob).to have_been_enqueued.with(submission, submission.last_transition)
      end
    end

    context "to notified_of_rejection" do
      let(:submission) { create(:efile_submission, :rejected) }

      it "enqueues an AfterTransitionTasksForRejectedReturnJob" do
        after_transition_messaging_service = instance_double(StateFile::AfterTransitionMessagingService)
        allow(StateFile::AfterTransitionMessagingService)
          .to receive(:new)
          .and_return(after_transition_messaging_service)
        allow(after_transition_messaging_service)
          .to receive(:send_efile_submission_rejected_message)
        submission.transition_to!(:notified_of_rejection)

      end
    end

    context "to investigating" do
      let(:submission) { create(:efile_submission, :rejected) }
      it "transitions the tax return status to on hold" do
        expect {
          submission.transition_to!(:investigating)
        }.to change(submission.tax_return, :current_state).to("file_hold")
      end
    end

    context "to waiting" do
      let(:submission) { create(:efile_submission, :rejected) }
      it "transitions the tax return status to on hold" do
        expect {
          submission.transition_to!(:waiting)
        }.to change(submission.tax_return, :current_state).to("file_hold")
      end
    end

    context "to accepted" do
      let(:submission) { create(:efile_submission, :transmitted) }

      before do
        allow(ClientMessagingService).to receive(:send_system_message_to_all_opted_in_contact_methods)
        allow_any_instance_of(Efile::BenefitsEligibility).to receive(:eip1_amount).and_return(1000)
        allow_any_instance_of(Efile::BenefitsEligibility).to receive(:eip2_amount).and_return(1300)
        allow_any_instance_of(Efile::BenefitsEligibility).to receive(:eip3_amount).and_return(2400)
        allow_any_instance_of(Efile::BenefitsEligibility).to receive(:eip3_amount_received).and_return(2350)

        allow_any_instance_of(Efile::BenefitsEligibility).to receive(:ctc_amount).and_return(2450)
        allow_any_instance_of(Efile::BenefitsEligibility).to receive(:advance_ctc_amount_received).and_return(1500)
        allow_any_instance_of(Efile::BenefitsEligibility).to receive(:outstanding_ctc_amount).and_return(900)
        allow_any_instance_of(Efile::BenefitsEligibility).to receive(:outstanding_recovery_rebate_credit).and_return(2400)
      end

      it "sends a message to the client" do
        submission.transition_to!(:accepted)
        expect(ClientMessagingService).to have_received(:send_system_message_to_all_opted_in_contact_methods).with(
          client: submission.client.reload,
          message: AutomatedMessage::EfileAcceptance,
        )
      end

      it "updates the tax return status" do
        submission.transition_to!(:accepted)
        expect(submission.tax_return.current_state).to eq("file_accepted")
      end

      it "creates a record to store the tax return data" do
        expect {
          submission.transition_to(:accepted)
        }.to change(AcceptedTaxReturnAnalytics, :count).by 1
        expect(submission.tax_return.accepted_tax_return_analytics.outstanding_ctc_amount_cents).to eq 90000
        expect(submission.tax_return.accepted_tax_return_analytics.ctc_amount_cents).to eq 245000
        expect(submission.tax_return.accepted_tax_return_analytics.advance_ctc_amount_cents).to eq 150000

        expect(submission.tax_return.accepted_tax_return_analytics.eip1_and_eip2_amount_cents).to eq 230000

        expect(submission.tax_return.accepted_tax_return_analytics.eip3_amount_cents).to eq 240000
        expect(submission.tax_return.accepted_tax_return_analytics.eip3_amount_received_cents).to eq 235000

        expect(submission.tax_return.accepted_tax_return_analytics.total_refund_amount_cents).to eq 330000
      end
    end

    context "to resubmitted" do
      let!(:efile_submission) { create :efile_submission, :transmitted }


      before do
        efile_submission.transition_to!(:rejected)
        create :qualifying_child, intake: efile_submission.intake
      end

      it "creates a new efile submission" do
        expect {
          efile_submission.transition_to!(:resubmitted)
        }.to change(EfileSubmission, :count).by 1
        expect(efile_submission.current_state).to eq "resubmitted"
        new_submission = EfileSubmission.last
        expect(new_submission.current_state).to eq "bundling"
        expect(new_submission.qualifying_dependents).to be_present
        expect(new_submission.last_transition_to("preparing").metadata["previous_submission_id"]).to eq efile_submission.id
      end
    end
  end
end
