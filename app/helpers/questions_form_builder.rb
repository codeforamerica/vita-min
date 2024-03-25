class QuestionsFormBuilder < VitaMinFormBuilder

  def submit(value, options = {})
    current_intake_input.html_safe + super(value, **options)
  end

  private

  def current_intake_input
    # A hidden element containing the identified for the current_intake
    return "" unless @object.respond_to?(:intake) && @object.intake && @object.intake.id
    @template.hidden_field_tag(:current_intake, @object.intake.to_signed_global_id)
  end

end
