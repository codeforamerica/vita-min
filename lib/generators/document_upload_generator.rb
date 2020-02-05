class DocumentUploadGenerator < Rails::Generators::Base
  source_root File.expand_path("templates", __dir__)
  class_option :document_type, type: :string,
    desc: 'Value of the `type` column for the Document model. (e.g. "W-2", "1099-R")',
    required: true
  class_option :title, type: :string, required: true
  class_option :help_text, type: :string

  def generate_document_upload
    @controller_name = "#{controller_prefix}Controller"
    @form_name = "#{controller_prefix}Form"

    generate_question_form
    generate_question_controller
    generate_question_view

    puts "\n\u{2728} Done generating the #{options.document_type.inspect} document upload!"
    puts "\u{1F6A8} Be sure to:"
    puts "   1. Add Questions::#{@controller_name} in `question_navigation.rb`"
    puts "   2. Add #{options.document_type.inspect} in `app/models/document.rb` DOCUMENT_TYPES array."
  end

  private

  def generate_question_form
    template "document_upload_form.template", "app/forms/#{@form_name.underscore}.rb"
  end

  def generate_question_controller
    template "document_upload_controller.template",
      "app/controllers/questions/#{@controller_name.underscore}.rb"
  end

  def generate_question_view
    template "document_upload_view.template",
      "app/views/questions/#{controller_prefix.underscore}/edit.html.erb"
  end

  # "W-2" => "FormW2"
  # "1099-R" => "Form1099r"
  def controller_prefix
    "Form#{options.document_type.capitalize.gsub("-", "").pluralize}"
  end
end
