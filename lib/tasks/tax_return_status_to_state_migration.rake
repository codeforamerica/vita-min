namespace :tax_return_state do
  desc 'BulkTaxReturnUpdate status -> state'
  task bulk_update_migrate: [:environment] do
    BulkTaxReturnUpdate.find_each do |btru|
      btru.update(state: btru.status)
      prints "."
    end
  end
  
  task tax_return_2021_migrate: [:environment] do
    TaxReturnStateMachine.states.each do |state|
      puts "#{state}: #{TaxReturn.where(state: nil, year: 2021, status: state).count} records"
      TaxReturn.where(state: nil, year: 2021, status: state).in_batches do |batch|
        batch.update_all(state: state)
      end
    end
  end

  task tax_return_migrate: [:environment] do
    TaxReturnStateMachine.states.without("intake_before_consent").each do |state|
      puts "#{state}: #{TaxReturn.where(state: nil).where(status: state).count} records"
      TaxReturn.where(state: nil).where(status: state).in_batches do |batch|
        batch.update_all(state: state)
      end
    end
  end

  task tax_return_low_priority_migrate: [:environment] do
    puts "#{state}: #{TaxReturn.where(state: nil, status: "intake_before_consent")} records"
    TaxReturn.where(state: nil, status: "intake_before_consent").in_batches do |batch|
      batch.update_all(state: "intake_before_consent")
    end
  end
end