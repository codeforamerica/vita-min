# Backfills Zendesk `filing_years` on intake tickets. This can be removed
# once it is run once in a production console.
#
# Usage (in rails console):
# > ZendeskFilingYearsBackfill.update_db
# > ZendeskFilingYearsBackfill.update_zendesk_tickets
#
class ZendeskFilingYearsBackfill
  class << self
    def update_db
      never_answered = Intake.where(needs_help_2016: "unfilled", needs_help_2017: "unfilled", needs_help_2018: "unfilled", needs_help_2019: "unfilled")
      never_answered.each { |intake| intake.update(needs_help_2019: "yes") }
    end

    def update_zendesk_tickets
      Intake.find_each do |intake|
        service = ZendeskIntakeService.new(intake)
        service.update_filing_years
      end
    end
  end
end