require 'csv'

class AnonymizedIntakeCsvService
  CSV_FIELDS = Intake.defined_enums.keys + %w{
    external_id
    locale
    source
    referrer
    dependent_count
    had_dependents_under_6?
    had_earned_income?
    state_of_residence
    state
    zip_code
    city
    needs_help_with_backtaxes?
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
    demographic_primary_american_indian_alaska_native
    demographic_primary_black_african_american
    demographic_primary_native_hawaiian_pacific_islander
    demographic_primary_asian
    demographic_primary_white
    demographic_primary_prefer_not_to_answer_race
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

    CSV_HEADERS
  end

  def csv_row(intake)
    row = CSV_FIELDS.map { |field| intake.send(field) }

    # Add status transition times.
    #
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
