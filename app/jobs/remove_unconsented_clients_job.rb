class RemoveUnconsentedClientsJob < ApplicationJob
  def perform(created_before: 14.days.ago)
    result = ActiveRecord::Base.connection.execute("SELECT pg_try_advisory_lock(1675448731) as lock_acquired")
    raise "#{self.class.name} lock already held" unless result[0]["lock_acquired"]

    loop do
      client_batch = clients_to_remove(created_before).order(created_at: :desc).limit(1000)
      break if client_batch.length.zero?

      ActiveRecord::Base.connection.execute(ApplicationRecord.sanitize_sql([<<~SQL, client_batch.pluck('id')]))
        INSERT INTO abandoned_pre_consent_intakes(id, client_id, created_at, updated_at, source, visitor_id, referrer, intake_type, triage_filing_frequency, triage_filing_status, triage_income_level, triage_vita_income_ineligible)
          (SELECT id, client_id, created_at, updated_at, source, visitor_id, referrer, type as intake_type, triage_filing_frequency, triage_filing_status, triage_income_level, triage_vita_income_ineligible from intakes WHERE client_id IN (?))
        ON CONFLICT (id) DO
          UPDATE SET
            client_id=EXCLUDED.client_id,
            created_at=EXCLUDED.created_at,
            updated_at=EXCLUDED.updated_at,
            source=EXCLUDED.source,
            visitor_id=EXCLUDED.visitor_id,
            referrer=EXCLUDED.referrer,
            intake_type=EXCLUDED.intake_type,
            triage_filing_frequency=EXCLUDED.triage_filing_frequency,
            triage_filing_status=EXCLUDED.triage_filing_status,
            triage_income_level=EXCLUDED.triage_income_level,
            triage_vita_income_ineligible=EXCLUDED.triage_vita_income_ineligible
      SQL
      client_batch.each(&:destroy)
    end
  ensure
    ActiveRecord::Base.connection.execute("SELECT pg_advisory_unlock(1675448731)")
  end

  private

  def clients_to_remove(created_before)
    base_query = Client
      .where("clients.created_at < ?", created_before)
      .joins(:intake)
      .where(consented_to_service_at: nil)
      .where.missing(:incoming_text_messages)
      .where.missing(:incoming_emails)
      .where.missing(:documents)

    base_query.where('jsonb_array_length(filterable_tax_return_properties) = 0').or(
      base_query.where('jsonb_array_length(filterable_tax_return_properties) = 1').where("filterable_tax_return_properties @> ?::jsonb", [{current_state: 'intake_before_consent'}].to_json)
    )
  end
end