class MigrateMonetaryValues
  def migrate
    puts "Starting migration of monetary values"

    puts "Migrating StateFileAzIntake charitable_cash"
    StateFileAzIntake.where.not(charitable_cash: nil)
                     .where(charitable_cash_amount: nil)
                     .in_batches(of: 10_000) do |batch|
      batch.update_all('charitable_cash_amount = charitable_cash')
      puts "Completed a batch for charitable_cash"
    end

    puts "Migrating StateFileAzIntake charitable_noncash"
    StateFileAzIntake.where.not(charitable_noncash: nil)
                     .where(charitable_noncash_amount: nil)
                     .in_batches(of: 10_000) do |batch|
      batch.update_all('charitable_noncash_amount = charitable_noncash')
      puts "Completed a batch for charitable_noncash"
    end

    puts "Migrating StateFileAzIntake household_excise_credit_claimed_amt"
    StateFileAzIntake.where.not(household_excise_credit_claimed_amt: nil)
                     .where(household_excise_credit_claimed_amount: nil)
                     .in_batches(of: 10_000) do |batch|
      batch.update_all('household_excise_credit_claimed_amount = household_excise_credit_claimed_amt')
      puts "Completed a batch for household_excise_credit_claimed_amt"
    end

    puts "Migrating StateFileAzIntake tribal_wages"
    StateFileAzIntake.where.not(tribal_wages: nil)
                     .where(tribal_wages_amount: nil)
                     .in_batches(of: 10_000) do |batch|
      batch.update_all('tribal_wages_amount = tribal_wages')
      puts "Completed a batch for tribal_wages"
    end

    puts "Migrating StateFileAzIntake armed_forces_wages"
    StateFileAzIntake.where.not(armed_forces_wages: nil)
                     .where(armed_forces_wages_amount: nil)
                     .in_batches(of: 10_000) do |batch|
      batch.update_all('armed_forces_wages_amount = armed_forces_wages')
      puts "Completed a batch for armed_forces_wages"
    end

    puts "Migrating StateFile1099G unemployment_compensation"
    StateFile1099G.where.not(unemployment_compensation: nil)
                  .where(unemployment_compensation_amount: nil)
                  .in_batches(of: 10_000) do |batch|
      batch.update_all('unemployment_compensation_amount = unemployment_compensation')
      puts "Completed a batch for unemployment_compensation"
    end

    puts "Migrating StateFile1099G federal_income_tax_withheld"
    StateFile1099G.where.not(federal_income_tax_withheld: nil)
                  .where(federal_income_tax_withheld_amount: nil)
                  .in_batches(of: 10_000) do |batch|
      batch.update_all('federal_income_tax_withheld_amount = federal_income_tax_withheld')
      puts "Completed a batch for federal_income_tax_withheld"
    end

    puts "Migrating StateFile1099G state_income_tax_withheld"
    StateFile1099G.where.not(state_income_tax_withheld: nil)
                  .where(state_income_tax_withheld_amount: nil)
                  .in_batches(of: 10_000) do |batch|
      batch.update_all('state_income_tax_withheld_amount = state_income_tax_withheld')
      puts "Completed a batch for state_income_tax_withheld"
    end


    StateFileW2.where.not(state_wages_amt: nil)
               .where(state_wages_amount: nil)
               .in_batches(of: 10_000) do |batch|
      batch.update_all('state_wages_amount = state_wages_amt')
      puts "Completed a batch for state_wages_amt"
    end

    puts "Migrating StateFileW2 state_income_tax_amt"
    StateFileW2.where.not(state_income_tax_amt: nil)
               .where(state_income_tax_amount: nil)
               .in_batches(of: 10_000) do |batch|
      batch.update_all('state_income_tax_amount = state_income_tax_amt')
      puts "Completed a batch for state_income_tax_amt"
    end

    puts "Migrating StateFileW2 local_wages_and_tips_amt"
    StateFileW2.where.not(local_wages_and_tips_amt: nil)
               .where(local_wages_and_tips_amount: nil)
               .in_batches(of: 10_000) do |batch|
      batch.update_all('local_wages_and_tips_amount = local_wages_and_tips_amt')
      puts "Completed a batch for local_wages_and_tips_amt"
    end

    puts "Migrating StateFileW2 local_income_tax_amt"
    StateFileW2.where.not(local_income_tax_amt: nil)
               .where(local_income_tax_amount: nil)
               .in_batches(of: 10_000) do |batch|
      batch.update_all('local_income_tax_amount = local_income_tax_amt')
      puts "Completed a batch for local_income_tax_amt"
    end

    puts "Migration of monetary values completed."
  end
end

class BackfillNewDecimalColumns < ActiveRecord::Migration[7.1]
  def up
    MigrateMonetaryValues.new.migrate
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end