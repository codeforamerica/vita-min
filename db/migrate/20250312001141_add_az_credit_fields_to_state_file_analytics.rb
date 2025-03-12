class AddAzCreditFieldsToStateFileAnalytics < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_analytics, :az_credit_for_contributions_to_qcos, :integer
    add_column :state_file_analytics, :az_credit_for_contributions_to_public_schools, :integer
    reversible do |dir|
      dir.up { backfill_models }
    end
  end

  def backfill_models
    begin
      # Rationale (& code structure) is identical to that in 20240612220721_add_direct_file_data_fields_to_state_file_analytics.rb
      StateFileAnalytics.includes(:record).find_in_batches(batch_size: 100) do |batch|
        ids = []
        updates = []
        batch.each do |analytics|
          next unless analytics.record.raw_direct_file_data.present?
          ids << analytics.id
          intake = analytics.record
          updates << {
            az_credit_for_contributions_to_qcos: intake&.calculator&.line_or_zero(:AZ301_LINE_6a),
            az_credit_for_contributions_to_public_schools: intake&.calculator&.line_or_zero(:AZ301_LINE_7a)
          }
        end
        StateFileAnalytics.update(ids, updates) if ids.present?
      end
    rescue Exception => e
      puts e
    end
  end
end