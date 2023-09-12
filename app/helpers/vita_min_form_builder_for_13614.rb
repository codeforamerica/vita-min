class VitaMinFormBuilderFor13614 < VitaMinFormBuilder
  def cfa_select(
    method,
    label_text,
    collection,
    options = {},
    &block
  )
    if object.respond_to?(:client)
      gating_question_columns = PdfFiller::F13614cPdf::GATES.select do |_gating_question, gated_values|
        gated_values.any?(method)
      end.map(&:first)

      gating_question_values = gating_question_columns.map { |c| object.client.intake.send(c) }
      gated_question_value = object.client.intake.send(method)
      if gating_question_values.any?("no") && gated_question_value == "unfilled"
        collection[0][0] = "[No]"
      end
    end

    super
  end
end
