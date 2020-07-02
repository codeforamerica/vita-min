require 'csv'

class AnonymizedIntakeCsvService
  CSV_FIELDS = [
    "completed_at",
    "locale",
    "intake_source"
  ]

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
    CSV.generate(headers: CSV_FIELDS, write_headers: true) do |csv|
      intakes.find_each(batch_size: 100) do |intake|
        csv << csv_row(intake)
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

  private

  def csv_row(intake)
    [
      intake.completed_at,
      intake.locale,
      intake.source,
    ]
  end
end
