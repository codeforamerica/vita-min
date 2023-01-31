class RemoveUnconsentedClientsJob < ApplicationJob
  def perform(created_before: 14.days.ago)
    clients_to_remove = Client
      .where("clients.created_at < ?", created_before)
      .joins(:intake)
      .where(consented_to_service_at: nil)
      .where.missing(:incoming_text_messages)
      .where.missing(:documents)

    clients_to_remove.find_in_batches do |clients|
      ActiveRecord::Base.connection.execute(ApplicationRecord.sanitize_sql([<<~SQL, clients.pluck('id')]))
        INSERT INTO abandoned_pre_consent_intakes(id, client_id, created_at, updated_at, source)
          (SELECT id, client_id, created_at, updated_at, source from intakes WHERE client_id IN (?))
        ON CONFLICT (id) DO
          UPDATE SET client_id=EXCLUDED.client_id, created_at=EXCLUDED.created_at, updated_at=EXCLUDED.updated_at, source=EXCLUDED.source
      SQL
      clients.each(&:destroy)
    end
  end
end