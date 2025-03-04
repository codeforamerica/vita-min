require 'rails_helper'

describe Efile::PollForAcknowledgmentsService do
  before do
    allow(Rails.application.config).to receive(:efile_environment).and_return("test")
    allow(DatadogApi).to receive(:gauge)
    allow(DatadogApi).to receive(:increment)
    allow(Efile::GyrEfilerService).to receive(:with_lock).and_yield(gyr_efiler_lock_available)
  end

  describe ".run" do
    context "when the gyr-efiler lock is available" do
      let(:gyr_efiler_lock_available) { true }

      context "when there are no EfileSubmissions" do
        before do
          allow(Efile::PollForAcknowledgmentsService).to receive(:transmitted_submission_ids).and_return([])
          allow(Efile::PollForAcknowledgmentsService).to receive(:transmitted_state_submission_ids).and_return([])
        end

        it "quietly runs and does nothing" do
          expect(EfileSubmission.count).to eq 0
          expect { Efile::PollForAcknowledgmentsService.run }.to_not raise_error
        end

        it "sends a metric to Datadog" do
          Efile::PollForAcknowledgmentsService.run
          expect(DatadogApi).to have_received(:increment).with("efile.poll_for_acks")
          expect(DatadogApi).to have_received(:increment).with("efile.poll_for_submissions_status")
        end
      end

      context "when there are 201 EfileSubmissions" do
        let(:efile_submission_ids) { (1..100).to_a.map(&:to_s) }
        let(:state_efile_submission_ids) { (101..201).to_a.map(&:to_s) }

        before do
          allow(Efile::GyrEfilerService).to receive(:run_efiler_command).and_return("")
          allow(Efile::PollForAcknowledgmentsService).to receive(:transmitted_submission_ids).and_return(efile_submission_ids)
          allow(Efile::PollForAcknowledgmentsService).to receive(:transmitted_state_submission_ids).and_return(state_efile_submission_ids)
        end

        it "polls the IRS for all of them" do
          Efile::PollForAcknowledgmentsService.run
          # since the submissions do not transition into the ready_for_ack, the acks endpoint is never hit
          # expect(Efile::GyrEfilerService).to have_received(:run_efiler_command).with("test", "acks", *efile_submission_ids.first(100)).once
          expect(Efile::GyrEfilerService).to have_received(:run_efiler_command).with("test", "submissions-status", *state_efile_submission_ids.first(100)).once
          expect(Efile::GyrEfilerService).to have_received(:run_efiler_command).with("test", "submissions-status", *state_efile_submission_ids.last(1)).once
        end

        it "sends metrics to Datadog" do
          Efile::PollForAcknowledgmentsService.run
          expect(DatadogApi).to have_received(:gauge).once.with("efile.poll_for_submissions_status.requested", 101)
          expect(DatadogApi).to have_received(:gauge).once.with("efile.poll_for_submissions_status.received", 0)
          expect(DatadogApi).to have_received(:gauge).once.with("efile.poll_for_acks.requested", 0)
          expect(DatadogApi).to have_received(:gauge).once.with("efile.poll_for_acks.received", 0)
          expect(DatadogApi).to have_received(:increment).with("efile.poll_for_submissions_status")
          expect(DatadogApi).to have_received(:increment).with("efile.poll_for_acks")
        end
      end

      context "with a state EfileSubmission that is in the transmitted state and a state EfileSubmission that is in the ready_for_ack state" do
        let!(:transmitted_state_efile_submission) { create(:efile_submission, :transmitted, :for_state, submission_bundle: { filename: "sensible-filename.zip", io: StringIO.new("i am a zip file") }) }
        let!(:ready_for_ack_state_efile_submission) { create(:efile_submission, :for_state, :ready_for_ack, submission_bundle: { filename: "sensible-filename.zip", io: StringIO.new("i am a zip file") }) }

        before do
          transmitted_state_efile_submission.update!(irs_submission_id: "9999992021197yrv4rvl")
          ready_for_ack_state_efile_submission.update!(irs_submission_id: "9999992021197yrv4rab")
        end

        context "when the IRS has no acknowledgement ready for this submission" do
          before do
            allow(Efile::GyrEfilerService).to receive(:run_efiler_command).and_return("")
          end
          it "does not change the state" do
            Efile::PollForAcknowledgmentsService.run
            expect(transmitted_state_efile_submission.reload.current_state).to eq("transmitted")
          end
        end

        # TODO: add state return here?
        # We look for acknowledgements for all in transmitted state, but IRS provides two acknowledgements. When we
        # loop through the first time, it can change the status. Second time, it should record a Sentry message and continue.
        context "when the IRS sends a duplicate acknowledgement for an efile submission" do
          let(:expected_irs_return_value) { file_fixture("irs_acknowledgement_acceptance.xml").read }

          before do
            transmitted_state_efile_submission.transition_to!(:accepted)
            allow(described_class).to receive(:ready_for_ack_submission_ids).and_return [transmitted_state_efile_submission.irs_submission_id]
            allow(Efile::GyrEfilerService).to receive(:run_efiler_command)
                                                .with("test", "acks", transmitted_state_efile_submission.irs_submission_id)
                                                .and_return expected_irs_return_value
            allow(Sentry).to receive(:capture_message)
          end

          it "records a message to Sentry but does not raise an error" do
            expect {
              Efile::PollForAcknowledgmentsService.run
            }.not_to raise_error
            expect(transmitted_state_efile_submission.current_state).to eq "accepted"
            expect(Sentry).to have_received :capture_message
          end
        end

        context "when the IRS has an acknowledgement ready for this submission" do
          before do
            allow(Efile::GyrEfilerService).to receive(:run_efiler_command)
                                                .with("test", "acks", ready_for_ack_state_efile_submission.irs_submission_id)
                                                .and_return expected_irs_return_value
            allow(Efile::GyrEfilerService).to receive(:run_efiler_command)
                                                .with("test", "submissions-status", transmitted_state_efile_submission.irs_submission_id)
                                                .and_return ""
          end

          let(:first_ack) do
            Nokogiri::XML(expected_irs_return_value).css("Acknowledgement").first.to_xml
          end
          let(:second_ack) do
            Nokogiri::XML(expected_irs_return_value).css("Acknowledgement").last.to_xml
          end

          context "and it is a rejection" do
            let(:expected_irs_return_value) { file_fixture("irs_acknowledgement_rejection.xml").read }
            before do
              allow(ClientPdfDocument).to receive(:create_or_update) # stub pdf creation in status change callback
            end

            it "changes the state from ready_for_ack to rejected" do
              Efile::PollForAcknowledgmentsService.run
              expect(transmitted_state_efile_submission.current_state).to eq("rejected")
              expect(transmitted_state_efile_submission.efile_submission_transitions.last.metadata['raw_response']).to eq(first_ack)
            end

            it "sends metrics to Datadog" do
              Efile::PollForAcknowledgmentsService.run

              expect(DatadogApi).to have_received(:gauge).with("efile.poll_for_submissions_status.requested", 1)
              expect(DatadogApi).to have_received(:gauge).with("efile.poll_for_submissions_status.received", 0)
              expect(DatadogApi).to have_received(:increment).with("efile.poll_for_submissions_status")
              expect(DatadogApi).to have_received(:gauge).with("efile.poll_for_acks.requested", 1)
              expect(DatadogApi).to have_received(:gauge).with("efile.poll_for_acks.received", 1)
              expect(DatadogApi).to have_received(:increment).with("efile.poll_for_acks")
            end

            it "updates the last_checked_for_ack_at" do
              freeze_time do
                expect(ready_for_ack_state_efile_submission.last_checked_for_ack_at).to eq(nil)
                Efile::PollForAcknowledgmentsService.run
                expect(ready_for_ack_state_efile_submission.reload.last_checked_for_ack_at).to eq(Time.now)
              end
            end
          end

          context "and it is an acceptance" do
            let(:expected_irs_return_value) { file_fixture("irs_acknowledgement_acceptance.xml").read }

            it "changes the federal submission's state from transmitted to accepted and the state submission's state from ready_for_ack to accepted" do
              transmitted_state_efile_submission.last_transition
              Efile::PollForAcknowledgmentsService.run
              expect(transmitted_state_efile_submission.current_state(force_reload: true)).to eq("accepted")
              expect(ready_for_ack_state_efile_submission.reload.current_state).to eq("accepted")
              expect(transmitted_state_efile_submission.efile_submission_transitions.last.metadata['raw_response']).to eq(first_ack)
              expect(ready_for_ack_state_efile_submission.efile_submission_transitions.last.metadata['raw_response']).to eq(second_ack)
            end
          end

          context "and it is an exception" do
            let(:expected_irs_return_value) { file_fixture("irs_acknowledgement_exception.xml").read }

            it "changes the state from transmitted to accepted, with imperfect return acceptance in metadata" do
              Efile::PollForAcknowledgmentsService.run
              expect(transmitted_state_efile_submission.current_state).to eq("accepted")
              expect(transmitted_state_efile_submission.efile_submission_transitions.last.metadata['raw_response']).to eq(first_ack)
              expect(transmitted_state_efile_submission.efile_submission_transitions.last.metadata['imperfect_return_acceptance']).to eq true
            end
          end
        end
      end

      context "with a state EfileSubmission that is in the transmitted state" do
        let!(:efile_submission) { create(:efile_submission, :for_state, :transmitted, submission_bundle: { filename: "sensible-filename.zip", io: StringIO.new("i am a zip file") }) }

        before do
          efile_submission.update!(irs_submission_id: "9999992021197yrv4rvl")
        end

        context "when the IRS has no acknowledgement ready for this submission" do
          before do
            allow(Efile::GyrEfilerService).to receive(:run_efiler_command).with("test", "submissions-status", efile_submission.irs_submission_id).and_return("")
          end

          it "does not change the state" do
            Efile::PollForAcknowledgmentsService.run
            expect(efile_submission.reload.current_state).to eq("transmitted")
          end
        end

        # TODO: handle this case?
        context "when the IRS sends a duplicate acknowledgement for an efile submission" do; end

        context "when the IRS has a status ready for this submission" do
          before do
            allow(Efile::GyrEfilerService).to receive(:run_efiler_command)
                                                .with("test", "submissions-status", efile_submission.irs_submission_id)
                                                .and_return expected_irs_return_value
            allow(Efile::GyrEfilerService).to receive(:run_efiler_command).with("test", "acks", efile_submission.irs_submission_id)
          end

          let(:first_status) do
            Nokogiri::XML(expected_irs_return_value).css("StatusRecordGrp").first.to_xml
          end

          context "and it is a rejection" do; end

          context "and it is ready for acknowledgement" do
            let(:expected_irs_return_value) { file_fixture("irs_submissions_status_ready_for_ack.xml").read }

            it "changes the state from transmitted to accepted" do
              Efile::PollForAcknowledgmentsService.run
              expect(efile_submission.current_state).to eq("ready_for_ack")
              expect(efile_submission.efile_submission_transitions.last.metadata['raw_response']).to eq(first_status)
            end
          end

          context "and it is an exception" do; end
        end
      end
    end

    context "when the gyr-efiler lock is busy" do
      let(:gyr_efiler_lock_available) { false }

      it "exits without polling for acks" do
        Efile::PollForAcknowledgmentsService.run
        expect(DatadogApi).not_to have_received(:increment).with("efile.poll_for_acks")
        expect(DatadogApi).to have_received(:increment).with("efile.poll_for_acks.lock_unavailable")
      end
    end

    context "when gyr-efiler reports a retryable error" do
      let(:gyr_efiler_lock_available) { true }

      before do
        allow(Efile::PollForAcknowledgmentsService).to receive(:ready_for_ack_submission_ids).and_return ["example_submission_id"]
        allow(Efile::GyrEfilerService).to receive(:run_efiler_command).and_raise(Efile::GyrEfilerService::RetryableError)
      end

      it "exits gracefully" do
        Efile::PollForAcknowledgmentsService.run
        expect(DatadogApi).not_to have_received(:increment).with("efile.poll_for_acks")
        expect(DatadogApi).to have_received(:increment).with("efile.poll_for_acks.retryable_error")
      end
    end
  end

  context "retrieving transmitted submission ids" do
    let(:gyr_efiler_lock_available) { true }
    let(:irs_submission_id1) { "9999992021197yrv4rva" }
    let(:irs_submission_id2) { "9999992021197yrv4rvb" }
    let(:irs_submission_id3) { "9999992021197yrv4rvc" }
    let(:irs_submission_id4) { "9999992021197yrv4rvd" }
    let!(:state_efile_submission1) { create(:efile_submission, :for_state, :transmitted, submission_bundle: { filename: "sensible-filename.zip", io: StringIO.new("i am a zip file") }) }
    let!(:state_efile_submission2) { create(:efile_submission, :for_state, :transmitted, submission_bundle: { filename: "sensible-filename.zip", io: StringIO.new("i am a zip file") }) }
    let!(:fed_efile_submission1) { create(:efile_submission, :transmitted, submission_bundle: { filename: "sensible-filename.zip", io: StringIO.new("i am a zip file") }) }
    let!(:fed_efile_submission2) { create(:efile_submission, :transmitted, submission_bundle: { filename: "sensible-filename.zip", io: StringIO.new("i am a zip file") }) }

    let(:correctly_ordered_statuses_multiple_submissions_transmitted) {
      Nokogiri::XML(
        <<~XML
          <?xml version='1.0' encoding='UTF-8'?>  
          <StatusRecordList xmlns="http://www.irs.gov/efile" xmlns:efile="http://www.irs.gov/efile">
              <Cnt>4</Cnt>
              <StatusRecordGrp>
                  <SubmissionId>4414662024003wte794o</SubmissionId>
                  <SubmissionStatusTxt>Received by State</SubmissionStatusTxt>
                  <SubmsnStatusAcknowledgementDt>2024-01-04</SubmsnStatusAcknowledgementDt>
              </StatusRecordGrp>
              <StatusRecordGrp>
                  <SubmissionId>abcdefghijklmnopqrst</SubmissionId>
                  <SubmissionStatusTxt>Received by State</SubmissionStatusTxt>
                  <SubmsnStatusAcknowledgementDt>2024-01-04</SubmsnStatusAcknowledgementDt>
              </StatusRecordGrp>
              <StatusRecordGrp>
                  <SubmissionId>abcdefghijklmnopqrst</SubmissionId>
                  <SubmissionStatusTxt>Sent to State</SubmissionStatusTxt>
                  <SubmsnStatusAcknowledgementDt>2024-01-04</SubmsnStatusAcknowledgementDt>
              </StatusRecordGrp>
              <StatusRecordGrp>
                  <SubmissionId>4414662024003wte794o</SubmissionId>
                  <SubmissionStatusTxt>Sent to State</SubmissionStatusTxt>
                  <SubmsnStatusAcknowledgementDt>2024-01-04</SubmsnStatusAcknowledgementDt>
              </StatusRecordGrp>
              <StatusRecordGrp>
                  <SubmissionId>abcdefghijklmnopqrst</SubmissionId>
                  <SubmissionStatusTxt>Ready for Pick-Up</SubmissionStatusTxt>
                  <SubmsnStatusAcknowledgementDt>2024-01-03</SubmsnStatusAcknowledgementDt>
              </StatusRecordGrp>
              <StatusRecordGrp>
                  <SubmissionId>abcdefghijklmnopqrst</SubmissionId>
                  <SubmissionStatusTxt>Received</SubmissionStatusTxt>
                  <SubmsnStatusAcknowledgementDt>2024-01-03</SubmsnStatusAcknowledgementDt>
              </StatusRecordGrp>
              <StatusRecordGrp>
                  <SubmissionId>4414662024003wte794o</SubmissionId>
                  <SubmissionStatusTxt>Ready for Pick-Up</SubmissionStatusTxt>
                  <SubmsnStatusAcknowledgementDt>2024-01-03</SubmsnStatusAcknowledgementDt>
              </StatusRecordGrp>
              <StatusRecordGrp>
                  <SubmissionId>4414662024003wte794o</SubmissionId>
                  <SubmissionStatusTxt>Received</SubmissionStatusTxt>
                  <SubmsnStatusAcknowledgementDt>2024-01-03</SubmsnStatusAcknowledgementDt>
              </StatusRecordGrp>
          </StatusRecordList>
        XML
      )
    }

    let(:correctly_ordered_statuses_transmitted) {
      Nokogiri::XML(
        <<~XML
          <?xml version='1.0' encoding='UTF-8'?>  
          <StatusRecordList xmlns="http://www.irs.gov/efile" xmlns:efile="http://www.irs.gov/efile">
              <Cnt>4</Cnt>
              <StatusRecordGrp>
                  <SubmissionId>4414662024003wte794o</SubmissionId>
                  <SubmissionStatusTxt>Received by State</SubmissionStatusTxt>
                  <SubmsnStatusAcknowledgementDt>2024-01-04</SubmsnStatusAcknowledgementDt>
              </StatusRecordGrp>
              <StatusRecordGrp>
                  <SubmissionId>4414662024003wte794o</SubmissionId>
                  <SubmissionStatusTxt>Sent to State</SubmissionStatusTxt>
                  <SubmsnStatusAcknowledgementDt>2024-01-04</SubmsnStatusAcknowledgementDt>
              </StatusRecordGrp>
              <StatusRecordGrp>
                  <SubmissionId>4414662024003wte794o</SubmissionId>
                  <SubmissionStatusTxt>Ready for Pick-Up</SubmissionStatusTxt>
                  <SubmsnStatusAcknowledgementDt>2024-01-03</SubmsnStatusAcknowledgementDt>
              </StatusRecordGrp>
              <StatusRecordGrp>
                  <SubmissionId>4414662024003wte794o</SubmissionId>
                  <SubmissionStatusTxt>Received</SubmissionStatusTxt>
                  <SubmsnStatusAcknowledgementDt>2024-01-03</SubmsnStatusAcknowledgementDt>
              </StatusRecordGrp>
          </StatusRecordList>
        XML
      )
    }

    let(:correctly_ordered_statuses_ready_for_ack) {
      Nokogiri::XML(
        <<~XML
          <?xml version='1.0' encoding='UTF-8'?>  
          <StatusRecordList xmlns="http://www.irs.gov/efile" xmlns:efile="http://www.irs.gov/efile">
              <Cnt>5</Cnt>
              <StatusRecordGrp>
                  <SubmissionId>4414662024003wte794o</SubmissionId>
                  <SubmissionStatusTxt>Acknowledgement Received from State</SubmissionStatusTxt>
                  <SubmsnStatusAcknowledgementDt>2024-01-04</SubmsnStatusAcknowledgementDt>
              </StatusRecordGrp>
              <StatusRecordGrp>
                  <SubmissionId>4414662024003wte794o</SubmissionId>
                  <SubmissionStatusTxt>Received by State</SubmissionStatusTxt>
                  <SubmsnStatusAcknowledgementDt>2024-01-04</SubmsnStatusAcknowledgementDt>
              </StatusRecordGrp>
              <StatusRecordGrp>
                  <SubmissionId>4414662024003wte794o</SubmissionId>
                  <SubmissionStatusTxt>Sent to State</SubmissionStatusTxt>
                  <SubmsnStatusAcknowledgementDt>2024-01-04</SubmsnStatusAcknowledgementDt>
              </StatusRecordGrp>
              <StatusRecordGrp>
                  <SubmissionId>4414662024003wte794o</SubmissionId>
                  <SubmissionStatusTxt>Ready for Pick-Up</SubmissionStatusTxt>
                  <SubmsnStatusAcknowledgementDt>2024-01-03</SubmsnStatusAcknowledgementDt>
              </StatusRecordGrp>
              <StatusRecordGrp>
                  <SubmissionId>4414662024003wte794o</SubmissionId>
                  <SubmissionStatusTxt>Received</SubmissionStatusTxt>
                  <SubmsnStatusAcknowledgementDt>2024-01-03</SubmsnStatusAcknowledgementDt>
              </StatusRecordGrp>
          </StatusRecordList>
        XML
      )
    }

    let(:out_of_order_statuses_ready_for_ack) {
      Nokogiri::XML(
        <<~XML
          <?xml version='1.0' encoding='UTF-8'?>  
          <StatusRecordList xmlns="http://www.irs.gov/efile" xmlns:efile="http://www.irs.gov/efile">
              <Cnt>5</Cnt>
              <StatusRecordGrp>
                  <SubmissionId>4414662024003wte794o</SubmissionId>
                  <SubmissionStatusTxt>Received by State</SubmissionStatusTxt>
                  <SubmsnStatusAcknowledgementDt>2024-01-04</SubmsnStatusAcknowledgementDt>
              </StatusRecordGrp>
              <StatusRecordGrp>
                  <SubmissionId>4414662024003wte794o</SubmissionId>
                  <SubmissionStatusTxt>Acknowledgement Received from State</SubmissionStatusTxt>
                  <SubmsnStatusAcknowledgementDt>2024-01-04</SubmsnStatusAcknowledgementDt>
              </StatusRecordGrp>
              <StatusRecordGrp>
                  <SubmissionId>4414662024003wte794o</SubmissionId>
                  <SubmissionStatusTxt>Sent to State</SubmissionStatusTxt>
                  <SubmsnStatusAcknowledgementDt>2024-01-04</SubmsnStatusAcknowledgementDt>
              </StatusRecordGrp>
              <StatusRecordGrp>
                  <SubmissionId>4414662024003wte794o</SubmissionId>
                  <SubmissionStatusTxt>Ready for Pick-Up</SubmissionStatusTxt>
                  <SubmsnStatusAcknowledgementDt>2024-01-03</SubmsnStatusAcknowledgementDt>
              </StatusRecordGrp>
              <StatusRecordGrp>
                  <SubmissionId>4414662024003wte794o</SubmissionId>
                  <SubmissionStatusTxt>Received</SubmissionStatusTxt>
                  <SubmsnStatusAcknowledgementDt>2024-01-03</SubmsnStatusAcknowledgementDt>
              </StatusRecordGrp>
          </StatusRecordList>
        XML
      )
    }

    before do
      fed_efile_submission1.update!(irs_submission_id: irs_submission_id1)
      fed_efile_submission2.update!(irs_submission_id: irs_submission_id2)
      state_efile_submission1.update!(irs_submission_id: irs_submission_id3)
      state_efile_submission2.update!(irs_submission_id: irs_submission_id4)
    end

    describe ".transmitted_submission_ids" do
      it "returns an array of IRS submission IDs" do
        expect(described_class.transmitted_submission_ids).to match_array([irs_submission_id1, irs_submission_id2])
      end
    end

    describe ".transmitted_state_submission_ids" do
      it "returns an array of IRS submission IDs" do
        expect(described_class.transmitted_state_submission_ids).to match_array([irs_submission_id3, irs_submission_id4])
      end
    end

    context "getting status from state" do
      it "interprets ready_for_ack successfully" do
        ["Denied by IRS", "Acknowledgement Received from State", "Acknowledgement Retrieved", "Notified"].each do |status|
          expect(described_class.submission_status_to_state(status)).to eq :ready_for_ack
        end
      end
      it "interprets transmitted successfully" do
        expect(described_class.submission_status_to_state("Received")).to eq :transmitted
      end
      it "interprets unknown states as failed" do
        expect(described_class.submission_status_to_state("My dog ate it")).to eq :failed
      end
    end

    describe ".group_status_records_by_submission_id" do
      it "groups statuses by submission_id, preserving their order" do
        result = described_class.group_status_records_by_submission_id(correctly_ordered_statuses_multiple_submissions_transmitted)
        expect(result.keys.length).to eq 2
        submission_ids = %w[4414662024003wte794o abcdefghijklmnopqrst]
        submission_ids.each do |submission_id|
          expect(result[submission_id].length).to eq 4
          expect(result[submission_id].first.css("SubmissionStatusTxt").text).to eq "Received by State"
          expect(result[submission_id].last.css("SubmissionStatusTxt").text).to eq "Received"
        end
      end
    end

    describe ".xml_node_with_most_recent_submission_status" do
      it "gets the most recent xml node indicating a transmitted state in a correctly ordered list of statuses" do
        xml_nodes = described_class.group_status_records_by_submission_id(correctly_ordered_statuses_transmitted)["4414662024003wte794o"]
        xml_node = described_class.xml_node_with_most_recent_submission_status(xml_nodes)
        expect(xml_node.css("SubmissionStatusTxt").text).to eq "Received by State"
      end

      it "gets the most recent xml node indicating a ready-for-ack state in a correctly ordered list of statuses" do
        xml_nodes = described_class.group_status_records_by_submission_id(correctly_ordered_statuses_ready_for_ack)["4414662024003wte794o"]
        xml_node = described_class.xml_node_with_most_recent_submission_status(xml_nodes)
        expect(xml_node.css("SubmissionStatusTxt").text).to eq "Acknowledgement Received from State"
      end

      it "gets the most recent xml node indicating a ready-for-ack state in an incorrectly ordered list of statuses" do
        xml_nodes = described_class.group_status_records_by_submission_id(out_of_order_statuses_ready_for_ack)["4414662024003wte794o"]
        xml_node = described_class.xml_node_with_most_recent_submission_status(xml_nodes)
        expect(xml_node.css("SubmissionStatusTxt").text).to eq "Acknowledgement Received from State"
      end
    end
  end
end
