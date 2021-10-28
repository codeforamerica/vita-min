namespace :tax_return do
  desc "begins using state column and state machine to track statuses"
  task state_migration: [:environment] do
    TaxReturn.where("status > 100").find_each do |tax_return|
      if tax_return.tax_return_transitions.where(most_recent: true).count.zero?
        tax_return.tax_return_transitions.create(
          to_state: tax_return.status,
          sort_key: 0,
          most_recent: true
        )
      end
    end
  end
end