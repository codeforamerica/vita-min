require 'csv'

class AnonymizedIntakeCsvService
  CSV_FIELDS = Intake.defined_enums.keys + %w{
    external_id
    intake_ticket_id
    locale
    source
    referrer
    age_end_of_tax_year
    spouse_age_end_of_tax_year
    dependent_count
    had_dependents_under_6?
    had_earned_income?
    state_of_residence
    state
    zip_code
    city
    needs_help_with_backtaxes?
    zendesk_instance_domain
    vita_partner_group_id
    vita_partner_name
    routing_criteria
    routing_value
    job_count
    document_count
    first_document_uploaded_at
    last_document_uploaded_at
    refund_payment_method_direct_deposit?
    preferred_interview_language
    created_at
    primary_consented_to_service_at
    completed_at
  }.freeze

  CSV_HEADERS = CSV_FIELDS.map { |field| field.gsub(/\W/, "") }.freeze

  def initialize(intake_ids=nil)
    @intake_ids = intake_ids
  end

  def intakes
    if @intake_ids
      Intake.where(id: @intake_ids)
    else
      Intake.all
    end
  end

  def generate_csv
    CSV.generate(headers: csv_headers, write_headers: true) do |csv|
      intakes.find_each(batch_size: 100) do |intake|
        csv << csv_row(decorated_intake(intake))
      end
    end
  end

  def store_csv
    extract = AnonymizedIntakeCsvExtract.new(
      record_count: intakes.size,
      run_at: Time.now
    )
    extract.upload.attach(
      io: StringIO.new(csv),
      filename: "anonymized-intakes-#{extract.run_at.to_date}.csv",
      content_type: "text/csv",
      identify: false
    )
    extract.save
    extract
  end

  def csv
    @csv ||= generate_csv
  end

  def decorated_intake(intake)
    AnonymizedCSVIntake.new(intake)
  end

  private

  def csv_headers
    status_headers = EitcZendeskInstance::INTAKE_STATUS_LABELS.values.map { |label| "Intake Status - #{label}" } +
                     EitcZendeskInstance::RETURN_STATUS_LABELS.values.map { |label| "Return Status - #{label}" } +
                     EitcZendeskInstance::EIP_STATUS_LABELS.values.map { |label| "EIP Status - #{label}" }
    CSV_HEADERS + status_headers
  end

  def csv_row(intake)
    row = CSV_FIELDS.map { |field| intake.send(field) }

    # Add status transition times
    intake_status_timestamps = {}
    return_status_timestamps = {}
    eip_status_timestamps = {}
    intake.ticket_statuses.where(verified_change: true).order('created_at').each do |ticket_status|
      unless intake_status_timestamps.key?(ticket_status.intake_status)
        intake_status_timestamps[ticket_status.intake_status] = ticket_status.created_at
      end

      unless return_status_timestamps.key?(ticket_status.return_status)
        return_status_timestamps[ticket_status.return_status] = ticket_status.created_at
      end

      unless eip_status_timestamps.key?(ticket_status.eip_status)
        eip_status_timestamps[ticket_status.eip_status] = ticket_status.created_at
      end
    end

    row += EitcZendeskInstance::INTAKE_STATUS_LABELS.keys.map { |label| intake_status_timestamps.dig(label)&.to_s } +
           EitcZendeskInstance::RETURN_STATUS_LABELS.keys.map { |label| return_status_timestamps.dig(label)&.to_s } +
           EitcZendeskInstance::EIP_STATUS_LABELS.keys.map { |label| eip_status_timestamps.dig(label)&.to_s }

    row
  end

  class AnonymizedCSVIntake < SimpleDelegator
    def dependent_count
      dependents.count
    end

    def had_dependents_under_6?
      had_dependents_under?(6)
    end

    def document_count
      documents.count
    end

    def first_document_uploaded_at
      ordered_documents.first&.created_at
    end

    def last_document_uploaded_at
      ordered_documents.last&.created_at
    end

    private

    def ordered_documents
      @ordered_documents ||= documents.order(created_at: :asc)
    end
  end
end
