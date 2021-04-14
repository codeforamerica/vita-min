class TriageTaxNeedsForm < QuestionsForm
  set_attributes_for :triage, :file_this_year, :file_previous_years, :collect_stimulus
  validate :at_least_one_selection

  def initialize(form_params = {})
    super(nil, form_params)
  end

  def stimulus_only?
    collect_stimulus == "yes" && [file_this_year, file_previous_years].all?("no")
  end

  def at_least_one_selection
    if [file_this_year, file_previous_years, collect_stimulus].all?("no")
      errors.add(:at_least_one_selection, "Please select at least one option to continue.")
    end
  end
end