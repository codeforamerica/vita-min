namespace :backfill_triage_data do
  desc "Backfill data onto Triage that lived on Intake"
  task intake_triage_fields: :environment do
    Triage.includes(:intake).joins(:intake).where('intake_id IS NOT NULL').where('intakes.triage_filing_status = 0').find_in_batches(batch_size: 100) do |batch|
      batch.each do |triage|
        filing_frequency = [
          triage.filed_2018,
          triage.filed_2019,
          triage.filed_2020,
          triage.filed_2021,
        ]
        if filing_frequency.all?("yes")
          triage_filing_frequency = "every_year"
        elsif filing_frequency.any?("yes")
          triage_filing_frequency = "some_years"
        elsif filing_frequency.all?("no")
          triage_filing_frequency = "not_filed"
        else
          triage_filing_frequency = "unfilled"
        end

        if triage.income_type_rent_yes? || triage.income_type_farm_yes?
          triage_vita_income_ineligible = "yes"
        elsif triage.income_type_rent_no? && triage.income_type_farm_no?
          triage_vita_income_ineligible = "no"
        else
          triage_vita_income_ineligible = "unfilled"
        end

        attributes = {
          need_itin_help: triage.id_type_need_itin_help? ? "yes" : "no",
          triage_filing_status: triage.filing_status,
          triage_income_level: triage.income_level,
          triage_filing_frequency: triage_filing_frequency,
          triage_vita_income_ineligible: triage_vita_income_ineligible,
        }
        triage.intake.update(attributes)
      end
      print '.'
    end
  end
end
