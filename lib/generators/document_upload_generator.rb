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

    generate_document_controller
    generate_document_view

    puts "\n\u{2728} Done generating the #{options.document_type.inspect} document upload!"
    puts "\u{1F6A8} Be sure to:"
    puts "Add #{options.document_type.inspect} in `app/lib/document_navigator.rb` DOCUMENT_CONTROLLERS hash."
  end

  private

  def generate_document_controller
    template "document_upload_controller.template",
      "app/controllers/documents/#{@controller_name.underscore}.rb"
  end

  def generate_document_view
    template "document_upload_view.template",
      "app/views/documents/#{controller_prefix.underscore}/create.html.erb"
  end

  # "W-2" => "FormW2"
  # "1099-R" => "Form1099r"
  def controller_prefix
    "Form#{options.document_type.capitalize.gsub("-", "").camelcase.pluralize}"
  end
end
