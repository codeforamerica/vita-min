class Efile::Nc::NcD400ScheduleS < Graph::Graph

  fact :line_18 do
    input :interest_reports, :interest_on_government_bonds do |val|
      val => 0..
    end

    proc do
      data in input: { interest_reports: }
      interest_reports.sum { |int_rep| int_rep[:interest_on_government_bonds] }.round
    end
  end

  fact :line_19 do
    input :fed_taxable_ssb

    proc do
      data in input: { fed_taxable_ssb: }
      fed_taxable_ssb || 0
    end
  end

  fact :line_20 do
    input :state_file_1099_rs, :income_source do |val|
      val => :bailey_settlement | :uniformed_services | :other | nil
    end
    input :state_file_1099_rs, :bailey_settlement_at_least_five_years do |val|
      val => true | false | nil
    end
    input :state_file_1099_rs, :bailey_settlement_from_retirement_plan do |val|
      val => true | false | nil
    end

    proc do
      data in input: { state_file_1099_rs: }
      state_file_1099_rs.sum do |state_file_1099_r|
        if state_file_1099_r[:income_source] == :bailey_settlement && (state_file_1099_r[:bailey_settlement_at_least_five_years] || state_file_1099_r[:bailey_settlement_from_retirement_plan])
          state_file_1099_r[:taxable_amount]
        else
          0
        end
      end
    end
  end

  fact :line_21 do
    input :state_file_1099_rs, :income_source do |val|
      val => :bailey_settlement | :uniformed_services | :other | nil
    end
    input :state_file_1099_rs, :uniformed_services_retired do |val|
      val => true | false | nil
    end
    input :state_file_1099_rs, :uniformed_services_qualifying_plan do |val|
      val => true | false | nil
    end

    proc do
      data in input: { state_file_1099_rs: }
      state_file_1099_rs.sum do |state_file_1099_r|
        if state_file_1099_r[:income_source] == :uniformed_services && (state_file_1099_r[:uniformed_services_retired] || state_file_1099_r[:uniformed_services_qualifying_plan])
          state_file_1099_r[:taxable_amount]
        else
          0
        end
      end
    end
  end

  fact :line_27 do
    input :tribal_wages_amount do |val|
      val => Numeric | nil
    end

    proc do
      data in input: { tribal_wages_amount: }
      tribal_wages_amount.to_i
    end
  end

  fact :line_41 do
    dependency :line_18
    dependency :line_19
    dependency :line_20
    dependency :line_21
    dependency :line_27

    proc do
      data in dependencies: { line_18:, line_19:, line_20:, line_21:, line_27: }
      line_18 + line_19 + line_20 + line_21 + line_27
    end
  end
end