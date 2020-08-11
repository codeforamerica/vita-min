require 'csv'

class AnonymizedDiyIntakeCsvService
  CSV_FIELDS = %w[
    referrer
    source
    state_of_residence
    created_at
    updated_at
    requester_id
    ticket_id
    visitor_id
  ].freeze

  CSV_HEADERS = CSV_FIELDS.map { |field| field.gsub(/\W/, "") }.freeze

  def initialize(ids = nil)
    @ids = ids
  end

  def records
    if @ids
      DiyIntake.where(id: @ids)
    else
      DiyIntake.where.not(ticket_id: nil)
    end
  end

  def generate_csv
    CSV.generate(headers: CSV_HEADERS, write_headers: true) do |csv|
      records.find_each(batch_size: 100) do |record|
        csv << csv_row(record)
      end
    end
  end

  def store_csv
    extract = AnonymizedDiyIntakeCsvExtract.new(
      record_count: records.size,
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

  private

  def csv_row(record)
    CSV_FIELDS.map { |field| record.send(field) }
  end
end