# frozen_string_literal: true

class BackfillStateFileAnalyticsColumns < ActiveRecord::Migration[7.1]
  def up
    StateFileAnalytics.includes(:record).find_each(batch_size: 100) do |analytics|
      intake = analytics.record
      next unless intake.raw_direct_file_data.present?
      analytics.update(intake.calculator&.analytics_attrs || {})
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
