require "rails_helper"

RSpec.describe StateFile::OctoberTransferReminderService do
  around do |example|
    Timecop.freeze(DateTime.parse("2025-10-02")) { example.run }
  end

  before do
    allow(StateFile::StateInformationService)
      .to receive(:active_state_codes).and_return(%w[AZ NC])
    allow(StateFile::StateInformationService)
      .to receive(:intake_class).with("AZ").and_return(StateFileAzIntake)
    allow(StateFile::StateInformationService)
      .to receive(:intake_class).with("NC").and_return(StateFileNcIntake)

    Flipper.enable(:prevent_duplicate_ssn_messaging)
  end

  it "excludes intakes when another intake with the same SSN already has a submission (and respects 24h cooldown)" do
    az_notify_none = create(
      :state_file_az_intake,
      df_data_import_succeeded_at: nil,
      created_at: Time.current,
      message_tracker: {}
    )

    az_recent = create(
      :state_file_az_intake,
      df_data_import_succeeded_at: nil,
      created_at: Time.current,
      message_tracker: { "messages.state_file.finish_return" => 2.hours.ago.utc.to_s }
    )

    nc_notify_old = create(
      :state_file_nc_intake,
      df_data_import_succeeded_at: nil,
      created_at: Time.current,
      message_tracker: { "messages.state_file.monthly_finish_return" => 3.days.ago.utc.to_s }
    )

    same_hash = "111443333"

    az_other_with_submission = create(
      :state_file_az_intake,
      df_data_import_succeeded_at: 1.minute.ago,   # exclude from selection
      created_at: Time.current,
      hashed_ssn: same_hash,
      message_tracker: {}
    )
    create(:efile_submission, :for_state, data_source: az_other_with_submission)

    az_duplicate_blocked = create(
      :state_file_az_intake,
      df_data_import_succeeded_at: nil,
      created_at: Time.current,
      hashed_ssn: same_hash,
      message_tracker: {}
    )

    messaging_service = spy("StateFile::MessagingService", send_message: true)
    allow(StateFile::MessagingService).to receive(:new).and_return(messaging_service)

    described_class.run

    expect(StateFile::MessagingService).to have_received(:new)
                                             .with(message: StateFile::AutomatedMessage::OctoberTransferReminder, intake: az_notify_none)
    expect(StateFile::MessagingService).to have_received(:new)
                                             .with(message: StateFile::AutomatedMessage::OctoberTransferReminder, intake: nc_notify_old)
    expect(StateFile::MessagingService).to have_received(:new).exactly(2).times
    expect(messaging_service).to have_received(:send_message).with(require_verification: false).twice

    expect(StateFile::MessagingService).not_to have_received(:new)
                                                 .with(message: StateFile::AutomatedMessage::OctoberTransferReminder, intake: az_recent)
    expect(StateFile::MessagingService).not_to have_received(:new)
                                                 .with(message: StateFile::AutomatedMessage::OctoberTransferReminder, intake: az_duplicate_blocked)
  end
end
