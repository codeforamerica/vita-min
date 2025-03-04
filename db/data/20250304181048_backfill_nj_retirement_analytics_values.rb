# frozen_string_literal: true

class BackfillNjRetirementAnalyticsValues < ActiveRecord::Migration[7.1]
  def up
    puts "Starting backfill of retirement analytics values"

    puts "Backfill records without NJ1040_LINE_20A"
    StateFileNjAnalytics.where(NJ1040_LINE_20A: nil)
    .in_batches(of: 10_000) do |batch|
      batch.update_all('NJ1040_LINE_20A = 0')
    end

    puts "Backfill records without NJ1040_LINE_20B"
    StateFileNjAnalytics.where(NJ1040_LINE_20B: nil)
    .in_batches(of: 10_000) do |batch|
      batch.update_all('NJ1040_LINE_20B = 0')
    end

    puts "Backfill records without NJ1040_LINE_28A"
    StateFileNjAnalytics.where(NJ1040_LINE_28A: nil)
    .in_batches(of: 10_000) do |batch|
      batch.update_all('NJ1040_LINE_28A = 0')
    end

    puts "Backfill records without NJ1040_LINE_28B"
    StateFileNjAnalytics.where(NJ1040_LINE_28B: nil)
    .in_batches(of: 10_000) do |batch|
      batch.update_all('NJ1040_LINE_28B = 0')
    end

    puts "Backfill records without NJ1040_LINE_28C"
    StateFileNjAnalytics.where(NJ1040_LINE_28C: nil)
    .in_batches(of: 10_000) do |batch|
      batch.update_all('NJ1040_LINE_28C = 0')
    end

    puts "Backfill of retirement analytics values complete"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
