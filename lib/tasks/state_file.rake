namespace :state_file do
  desc 'Tasks for state-file'

  task reminder_to_finish_state_return: :environment do
    StateFile::ReminderToFinishStateReturnService.run
  end

  task monthly_finish_state_return: :environment do
    if DateTime.now <= Rails.configuration.state_file_end_of_new_intakes && DateTime.now.year == 2025
      StateFile::MonthlyFinishStateReturnService.run
    end
  end

  task deadline_reminder_tomorrow: :environment do
    return unless DateTime.now.year == 2025
    StateFile::SendDeadlineReminderTomorrowService.run
  end

  task pre_deadline_reminder: :environment do
    return unless DateTime.now.year == 2025
    StateFile::SendPreDeadlineReminderService.run
  end

  task post_deadline_reminder: :environment do
    return unless DateTime.now.year == 2025
    StateFile::SendPostDeadlineReminderService.run
  end

  task send_marketing_email: :environment do
    StateFile::SendMarketingEmailService.run
  end

  task backfill_intake_submission_pdfs: :environment do
    batch_size = 5
    intake_types = StateFile::StateInformationService.state_intake_classes
    intake_types.find do |intake_type|
      sql = <<~SQL
        SELECT #{intake_type.table_name}.id 
        FROM #{intake_type.table_name}
        INNER JOIN efile_submissions ON (
          efile_submissions.data_source_type = '#{intake_type.name}'
          AND efile_submissions.data_source_id = #{intake_type.table_name}.id
        ) INNER JOIN efile_submission_transitions ON (
          efile_submission_transitions.efile_submission_id = efile_submissions.id
          AND efile_submission_transitions.to_state not in ('new', 'preparing', 'bundling', 'queued', 'cancelled')
          AND efile_submission_transitions.most_recent = true
        ) LEFT JOIN active_storage_attachments ON (
          active_storage_attachments.record_type = '#{intake_type.name}'
          AND active_storage_attachments.record_id = #{intake_type.table_name}.id
          AND active_storage_attachments.name = 'submission_pdf'
        ) WHERE active_storage_attachments.id IS NULL
        LIMIT #{batch_size}
      SQL
      ids = ActiveRecord::Base.connection.query(sql).flatten
      Rails.logger.info("backfill_intake_submission_pdfs: #{intake_type.name}: #{ids}") if ids.present?
      intake_type.includes(:efile_submissions, :dependents, :state_file_w2s, :state_file1099_gs).with_attached_submission_pdf.find(ids).each do |intake|
        submission = intake.efile_submissions.last
        intake.submission_pdf.attach(
          io: submission.generate_filing_pdf,
          filename: "#{submission.irs_submission_id}.pdf",
          content_type: 'application/pdf'
        )
      end
      ids.present?
    end
  end
end
