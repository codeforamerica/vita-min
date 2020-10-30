require 'csv'

class IrsImpactAnalysisCsvService
  CSV_FIELDS = %w{
    legal_name
    last_four_ssn
    date_of_birth
    zip_code
    reached_gathering_docs
    uploaded_documents
    completed_intake
    filed
    service_type
  }.freeze

  CSV_HEADERS = CSV_FIELDS.map { |field| field.gsub(/\W/, "") }.freeze

  # only grab intakes where the user consented.
  def intakes
    Intake.includes(:ticket_statuses, :documents).where("ticket_statuses.verified_change": true).where.not(primary_consented_to_service_at: nil)
  end

  def generate_csv
    csv_string = CSV.generate(headers: csv_headers, write_headers: true) do |csv|
      intakes.find_each(batch_size: 100) do |intake|
        csv << csv_row(decorated_intake(intake))
      end
    end
    file = Tempfile.new("impact-analysis", "#{Rails.root.to_s}/tmp/")
    file.write(csv_string)
    file.rewind
    file
  end

  def csv
    @csv ||= generate_csv
  end

  def decorated_intake(intake)
    IRSImpactIntake.new(intake)
  end

  private

  def csv_headers
    CSV_HEADERS
  end

  def csv_row(intake)
    row = CSV_FIELDS.map { |field| intake.send(field) }
  end

  class IRSImpactIntake < SimpleDelegator
    def legal_name
      "#{primary_first_name} #{primary_last_name}"
    end

    def last_four_ssn
      primary_last_four_ssn
    end

    def date_of_birth
      primary_birth_date.strftime("%m/%d/%Y")
    end

    def reached_gathering_docs
      key = EitcZendeskInstance::INTAKE_STATUS_GATHERING_DOCUMENTS
      verified_ticket_statuses.detect { |ts| ts.intake_status == key }.present?
    end

    def uploaded_documents
      documents.count > 0
    end

    def completed_intake
      completed_at.present?
    end

    def filed
      if eip_only
        key = EitcZendeskInstance::EIP_STATUS_COMPLETED
        verified_ticket_statuses.detect { |ts| ts.eip_status == key }.present?
      else
        key = EitcZendeskInstance::RETURN_STATUS_COMPLETED_RETURNS
        verified_ticket_statuses.detect { |ts| ts.return_status == key }.present?
      end
    end

    def service_type
      eip_only ? "EIP" : "Full Service"
    end

    def verified_ticket_statuses
      @statuses ||= ticket_statuses.where(verified_change: true)
    end
  end
end
