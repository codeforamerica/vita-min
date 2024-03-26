module QuestionsFormHelper

  def questions_form(*args, **options, &block)
    # Custom form with a hidden element containing the current intake id to match with the session
    # in case multiple tabs are in use
    options[:builder] = VitaMinFormBuilder unless options[:builder].present?
    result = form_with(*args, **options) do |f|
      if current_intake.present? && current_intake.persisted?
        output_buffer << "<input type=\"hidden\" name=\"current_intake\" value=\"#{current_intake.to_signed_global_id}\" />".html_safe
      end
      block.call(f)
    end
    result
  end
end
