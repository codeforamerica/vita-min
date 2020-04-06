class YesNoQuestionGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)
  class_option :db_column, type: :string, default: name
  class_option :title, type: :string
  class_option :help_text, type: :string

  def generate_yes_no_question
    generate_question_form
    generate_question_controller
    generate_question_view

    puts "\nDone generating the #{name} question!"
    puts "Be sure to add #{name}Controller in the desired application order in `question_navigation.rb`"
  end

  private

  def generate_question_form
    template "question_form.template", "app/forms/#{name.underscore}_form.rb"
  end

  def generate_question_controller
    template "question_controller.template",
             "app/controllers/questions/#{name.underscore}_controller.rb"
  end

  def generate_question_view
    template "yes_no_question_view.template",
             "app/views/questions/#{name.underscore}/edit.html.erb"
  end
end