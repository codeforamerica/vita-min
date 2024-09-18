class BackfillNewDecimalColumnsWithIntegerValues
  def migrate
    # StateFileAzIntake
    StateFileAzInake.where.not(charitable_cash: nil)
                     .where(charitable_cash_amount: nil)
                     .in_batches(of: 10_000) do |batch|
      batch.update_all('charitable_cash_amount = charitable_cash')
    end

    StateFileAzIntake.where.not(charitable_noncash: nil)
                     .where(charitable_noncash_amount: nil)
                     .in_batches(of: 10_000) do |batch|
      batch.update_all('charitable_noncash_amount = charitable_noncash')
    end

    StateFileAzIntake.where.not(household_excise_credit_claimed_amt: nil)
                     .where(household_excise_credit_claimed_amount: nil)
                     .in_batches(of: 10_000) do |batch|
      batch.update_all('household_excise_credit_claimed_amount = household_excise_credit_claimed_amt')
    end

    StateFileAzIntake.where.not(tribal_wages: nil)
                     .where(tribal_wages_amount: nil)
                     .in_batches(of: 10_000) do |batch|
      batch.update_all('tribal_wages_amount = tribal_wages')
    end

    StateFileAzIntake.where.not(armed_forces_wages: nil)
                     .where(armed_forces_wages_amount: nil)
                     .in_batches(of: 10_000) do |batch|
      batch.update_all('armed_forces_wages_amount = armed_forces_wages')
    end

    # StateFile1099G
    StateFile1099G.where.not(unemployment_compensation: nil)
                  .where(unemployment_compensation_amount: nil)
                  .in_batches(of: 10_000) do |batch|
      batch.update_all('unemployment_compensation_amount = unemployment_compensation')
    end

    StateFile1099G.where.not(federal_income_tax_withheld: nil)
                  .where(federal_income_tax_withheld_amount: nil)
                  .in_batches(of: 10_000) do |batch|
      batch.update_all('federal_income_tax_withheld_amount = federal_income_tax_withheld')
    end

    StateFile1099G.where.not(state_income_tax_withheld: nil)
                  .where(state_income_tax_withheld_amount: nil)
                  .in_batches(of: 10_000) do |batch|
      batch.update_all('state_income_tax_withheld_amount = state_income_tax_withheld')
    end

    # StateFileW2
    StateFileW2.where.not(state_wages_amt: nil)
               .where(state_wages_amount: nil)
               .in_batches(of: 10_000) do |batch|
      batch.update_all('state_wages_amount = state_wages_amt')
    end

    StateFileW2.where.not(state_income_tax_amt: nil)
               .where(state_income_tax_amount: nil)
               .in_batches(of: 10_000) do |batch|
      batch.update_all('state_income_tax_amount = state_income_tax_amt')
    end

    StateFileW2.where.not(local_wages_and_tips_amt: nil)
               .where(local_wages_and_tips_amount: nil)
               .in_batches(of: 10_000) do |batch|
      batch.update_all('local_wages_and_tips_amount = local_wages_and_tips_amt')
    end

    StateFileW2.where.not(local_income_tax_amt: nil)
               .where(local_income_tax_amount: nil)
               .in_batches(of: 10_000) do |batch|
      batch.update_all('local_income_tax_amount = local_income_tax_amt')
    end
  end
end

class BackfillNewDecimalColumnsWithIntegerValues < ActiveRecord::Migration[7.1]
  def up
    BackfillNewDecimalColumnsWithIntegerValues.new.migrate
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end