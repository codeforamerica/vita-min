class TaxFormGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  def create_tax_controller
    template "controllers/form_controller.rb", File.join(
      "app/controllers/state_file/questions", "#{file_name}_controller.rb"
    )
  end

  def create_erb
    template "erb/edit.html.erb", File.join(
      "app/views/state_file/questions/#{file_name}", "edit.html.erb"
    )
  end

  def create_form
    template "forms/form.rb", File.join(
      "app/forms/state_file/questions", "#{file_name}_form.rb"
    )
  end

  def create_specs
    template "specs/controller_spec.rb", File.join(
      "specs/controllers/state_file/questions/#{file_name}_controller_spec.rb"
    )

    template "specs/form_spec.rb", File.join(
      "specs/forms/state_file/#{file_name}_form_spec.rb"
    )
  end

  def remind_to_add_to_navigation
    say "Don't forget to adjust the appropriate FormNavigation class!"
  end
end
