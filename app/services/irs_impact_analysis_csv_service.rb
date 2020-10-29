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
    Intake.where.not(primary_consented_to_service_at: nil).includes(:ticket_statuses)
  end

  def generate_csv
    CSV.generate(headers: csv_headers, write_headers: true) do |csv|
      intakes.find_each(batch_size: 100) do |intake|
        csv << csv_row(decorated_intake(intake))
      end
    end
  end

  def send_csv
    # TODO: Whats the best way to download this document?
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
      key = "online_intake_gathering_documents"
      ticket_statuses.where(verified_change: true, intake_status: key).present?
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

        ticket_statuses.where(verified_change: true, eip_status: key).present?
      else
        key = EitcZendeskInstance::RETURN_STATUS_COMPLETED_RETURNS
        ticket_statuses.where(verified_change: true, return_status: key).present?
      end
    end

    def return_status
      # TODO: Can we get the return status? Kelly said there is a status for this on Zendesk called "Status After Filing",
      # but I wasn't able to find it.
      "??"
    end

    def service_type
      eip_only ? "EIP" : "Full Service"
    end

  end
end
