require "csv"

module Zendesk
  class DuplicateIntakeMatcher
    AREL = Intake.arel_table

    def strong_matches
      return @strong_matches if @strong_matches
      subquery = Intake.select(
        Arel::Nodes::NamedFunction.new("ARRAY_AGG", [AREL[:id]]).as("intake_ids"),
        Arel::Nodes::NamedFunction.new("ARRAY_AGG", [AREL[:intake_ticket_id]])
          .as("ticket_ids"),
        AREL[:id].count.as("match_count"),
        AREL[:preferred_name].lower.as("lower_name"),
        AREL[:email_address].lower.as("lower_email"),
        :phone_number,
        :needs_help_2019,
        :needs_help_2018,
        :needs_help_2017,
        :needs_help_2016
      ).group(:lower_name,
              :lower_email,
              :phone_number,
              :needs_help_2019,
              :needs_help_2018,
              :needs_help_2017,
              :needs_help_2016)

      @strong_matches = Intake.from(subquery, :intakes).where(AREL[:match_count].gt(1))
    end

    def run(dry_run = true)
      headers = ["name", "email", "phone", "filing years", "intake ticket mapping", "primary ticket id"]
      with_primaries = strong_matches.map do |matches|
        mapping = matches.intake_ids.zip(matches.ticket_ids).to_h
        primary = merging_service.find_primary_ticket(matches.ticket_ids.compact).id
        [
          matches.lower_name,
          matches.lower_email,
          matches.phone_number,
          matches.filing_years.join(", "),
          mapping,
          primary,
        ]
      end
      csv = ::CSV.generate do |csv|
        csv << headers
        with_primaries.each { |row| csv << row }
      end
      merge_duplicates unless dry_run
      csv
    end

    private

    def merge_duplicates
      strong_matches.each do |matches|
        merging_service.merge_duplicate_tickets(matches.intake_ids)
      end
    end

    def merging_service
      @merging_service ||= TicketMergingService.new
    end
  end
end
