require 'rails_helper'

describe Efile::PollForSubmissionsStatusService do
  before do
    allow(Rails.application.config).to receive(:efile_environment).and_return("test")
    allow(DatadogApi).to receive(:gauge)
    allow(DatadogApi).to receive(:increment)
    allow(Efile::GyrEfilerService).to receive(:with_lock).and_yield(gyr_efiler_lock_available)
  end

  describe ".run" do
    context "when the gyr-efiler lock is available" do
      let(:gyr_efiler_lock_available) { true }

      context "polling for the right submissions" do
        context "when there are no state EfileSubmissions" do
          before do
            allow(Efile::PollForSubmissionsStatusService).to receive(:transmitted_state_submission_ids).and_return([])
          end

          it "quietly runs and does nothing" do
            expect(EfileSubmission.count).to eq 0
            expect { Efile::PollForSubmissionsStatusService.run }.to_not raise_error
          end

          it "sends a metric to Datadog" do
            Efile::PollForSubmissionsStatusService.run
            expect(DatadogApi).to have_received(:increment).with("efile.poll_for_submissions_status")
          end
        end

        context "when there are 101 state EfileSubmissions" do
          let(:efile_submission_ids) { (1..101).to_a.map(&:to_s) }

          before do
            allow(Efile::GyrEfilerService).to receive(:run_efiler_command).and_return("")
            allow(Efile::PollForSubmissionsStatusService).to receive(:transmitted_state_submission_ids).and_return(efile_submission_ids)
          end

          it "polls the IRS for all of them" do
            Efile::PollForSubmissionsStatusService.run
            expect(Efile::GyrEfilerService).to have_received(:run_efiler_command).with("test", "submissions-status", *efile_submission_ids.first(100)).once
            expect(Efile::GyrEfilerService).to have_received(:run_efiler_command).with("test", "submissions-status", *efile_submission_ids.last(1)).once
          end

          it "sends metrics to Datadog" do
            Efile::PollForSubmissionsStatusService.run

            expect(DatadogApi).to have_received(:gauge).with("efile.poll_for_submissions_status.requested", 101)
            expect(DatadogApi).to have_received(:gauge).with("efile.poll_for_submissions_status.received", 0)
            expect(DatadogApi).to have_received(:increment).with("efile.poll_for_submissions_status")
          end
        end
      end

      context "updating efile submission records" do
        let!(:efile_submission) { create(:efile_submission, :for_state, :transmitted, submission_bundle: { filename: "sensible-filename.zip", io: StringIO.new("i am a zip file") }) }

        before do
          efile_submission.update!(irs_submission_id: "9999992021197yrv4rvl")
        end

        context "when the IRS has no acknowledgement ready for this submission" do
          before do
            allow(Efile::GyrEfilerService).to receive(:run_efiler_command).with("test", "submissions-status", efile_submission.irs_submission_id).and_return("")
          end

          it "does not change the state" do
            Efile::PollForSubmissionsStatusService.run
            expect(efile_submission.reload.current_state).to eq("transmitted")
          end
        end

        # We look for acknowledgements for all in transmitted state, but IRS provides two acknowledgements. When we
        # loop through the first time, it can change the status. Second time, it should record a Sentry message and continue.
        context "when the IRS sends a duplicate acknowledgement for an efile submission" do
          let(:expected_irs_return_value) { file_fixture("irs_submissions_status_acceptance.xml").read }

          before do
            efile_submission.transition_to!(:accepted)
            allow(described_class).to receive(:transmitted_state_submission_ids).and_return [efile_submission.irs_submission_id]
            allow(Efile::GyrEfilerService).to receive(:run_efiler_command)
                                                 .with("test", "submissions-status", efile_submission.irs_submission_id)
                                                 .and_return expected_irs_return_value
            allow(Sentry).to receive(:capture_message)
          end

          xit "records a message to Sentry but does not raise an error" do
            expect {
              Efile::PollForSubmissionsStatusService.run
            }.not_to raise_error
            expect(efile_submission.current_state).to eq "accepted"
            expect(Sentry).to have_received :capture_message
          end
        end

        context "when the IRS has an acknowledgement ready for this submission" do
          before do
            allow(Efile::GyrEfilerService).to receive(:run_efiler_command)
                                                .with("test", "submissions-status", efile_submission.irs_submission_id)
                                                .and_return expected_irs_return_value
          end

          let(:first_ack) do
            Nokogiri::XML(expected_irs_return_value).css("Acknowledgement").first.to_xml
          end

          xcontext "and it is a rejection" do
            let(:expected_irs_return_value) { file_fixture("irs_acknowledgement_rejection.xml").read }
            before do
              allow(ClientPdfDocument).to receive(:create_or_update) # stub pdf creation in status change callback
            end

            it "changes the state from transmitted to rejected" do
              Efile::PollForSubmissionsStatusService.run
              expect(efile_submission.current_state).to eq("rejected")
              expect(efile_submission.efile_submission_transitions.last.metadata['raw_response']).to eq(first_ack)
            end

            it "sends metrics to Datadog" do
              Efile::PollForSubmissionsStatusService.run

              expect(DatadogApi).to have_received(:gauge).with("efile.poll_for_acks.requested", 1)
              expect(DatadogApi).to have_received(:gauge).with("efile.poll_for_acks.received", 1)
              expect(DatadogApi).to have_received(:increment).with("efile.poll_for_acks")
            end

            it "updates the last_checked_for_ack_at" do
              freeze_time do
                expect(efile_submission.last_checked_for_ack_at).to eq(nil)
                Efile::PollForSubmissionsStatusService.run
                expect(efile_submission.reload.last_checked_for_ack_at).to eq(Time.now)
              end
            end
          end

          context "and it is an acceptance" do
            let(:expected_irs_return_value) { file_fixture("irs_submissions_status_acceptance.xml").read }

            it "changes the state from transmitted to accepted" do
              Efile::PollForSubmissionsStatusService.run
              expect(efile_submission.current_state).to eq("accepted")
              expect(efile_submission.efile_submission_transitions.last.metadata['raw_response']).to eq(first_ack)
            end
          end

          xcontext "and it is an exception" do
            let(:expected_irs_return_value) { file_fixture("irs_acknowledgement_exception.xml").read }

            it "changes the state from transmitted to accepted, with imperfect return acceptance in metadata" do
              Efile::PollForSubmissionsStatusService.run
              expect(efile_submission.current_state).to eq("accepted")
              expect(efile_submission.efile_submission_transitions.last.metadata['raw_response']).to eq(first_ack)
              expect(efile_submission.efile_submission_transitions.last.metadata['imperfect_return_acceptance']).to eq true
            end
          end
        end
      end
    end

    xcontext "when the gyr-efiler lock is busy" do
      let(:gyr_efiler_lock_available) { false }

      it "exits without polling for acks" do
        Efile::PollForSubmissionsStatusService.run
        expect(DatadogApi).not_to have_received(:increment).with("efile.poll_for_acks")
        expect(DatadogApi).to have_received(:increment).with("efile.poll_for_acks.lock_unavailable")
      end
    end

    xcontext "when gyr-efiler reports a retryable error" do
      let(:gyr_efiler_lock_available) { true }

      before do
        allow(Efile::PollForSubmissionsStatusService).to receive(:transmitted_submission_ids).and_return ["example_submission_id"]
        allow(Efile::GyrEfilerService).to receive(:run_efiler_command).and_raise(Efile::GyrEfilerService::RetryableError)
      end

      it "exits gracefully" do
        Efile::PollForSubmissionsStatusService.run
        expect(DatadogApi).not_to have_received(:increment).with("efile.poll_for_acks")
        expect(DatadogApi).to have_received(:increment).with("efile.poll_for_acks.retryable_error")
      end
    end
  end

  describe ".transmitted_state_submission_ids" do
    let(:gyr_efiler_lock_available) { true }
    let(:irs_submission_id1) { "9999992021197yrv4rvl" }
    let(:irs_submission_id2) { "9999992021197yrv4rvx" }
    let(:irs_submission_id3) { "9999992021197yrv4rno" }
    let!(:state_efile_submission1) { create(:efile_submission, :for_state, :transmitted, submission_bundle: { filename: "sensible-filename.zip", io: StringIO.new("i am a zip file") }) }
    let!(:state_efile_submission2) { create(:efile_submission, :for_state, :transmitted, submission_bundle: { filename: "sensible-filename.zip", io: StringIO.new("i am a zip file") }) }
    let!(:fed_efile_submission) { create(:efile_submission, :transmitted, submission_bundle: { filename: "sensible-filename.zip", io: StringIO.new("i am a zip file") }) }

    before do
      state_efile_submission1.update!(irs_submission_id: irs_submission_id1)
      state_efile_submission2.update!(irs_submission_id: irs_submission_id2)
      fed_efile_submission.update!(irs_submission_id: irs_submission_id3)
    end

    it "returns an array of IRS submission IDs" do
      expect(described_class.transmitted_state_submission_ids).to match_array([irs_submission_id1, irs_submission_id2])
    end
  end
end
