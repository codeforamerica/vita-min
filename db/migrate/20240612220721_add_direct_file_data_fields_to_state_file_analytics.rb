class AddDirectFileDataFieldsToStateFileAnalytics < ActiveRecord::Migration[7.1]
  def change
    add_column :state_file_analytics, :fed_refund_amt, :integer
    add_column :state_file_analytics, :zip_code, :string
    backfill_models
  end

  def backfill_models
    begin
      # Using models in migrations is bad practice, but...
      #
      #  * In this case we are pulling data from an XML field with custom calculations - we would need
      #    to reproduce this logic
      #  * This migration is only used to back populate data to analytics - items created after this will
      #    use the logic from the model at the time of the db update.
      #  * The data in raw_direct_file_data is encrypted, so we need rails to decrypt it
      #
      StateFileAnalytics.find_each do |analytics|
        next unless analytics.record.raw_direct_file_data.present?
        direct_file_data = analytics.record.direct_file_data
        analytics.update(
          fed_refund_amt: direct_file_data.fed_refund_amt,
          zip_code: direct_file_data.mailing_zip
        )
      end
    rescue Exception => e
      puts e
    end
  end


  # def backfill_pure_sql
  #  This does not work because the raw_direct_file_data is encrypted
  #  ActiveRecord::Base.connection.execute(
  #    <<~SQL
  #      UPDATE state_file_analytics SET
  #        fed_refund_amt=xpath('./IRS1040/RefundAmt/text()', state_file_ny_intakes.raw_direct_file_data::xml)::text::integer,
  #        zip_code=xpath('./ReturnHeader/Filer/USAddress/ZIPCd/text()', state_file_ny_intakes.raw_direct_file_data::xml)
  #      FROM state_file_ny_intakes
  #      WHERE state_file_analytics.record_type='StateFileNyIntake' AND state_file_analytics.record_id = state_file_ny_intakes.id
  #  SQL
  #  )
  # end
end
