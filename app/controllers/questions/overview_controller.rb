module Questions
  class OverviewController < QuestionsController
    layout "application"

    def edit
      is_new_user = (current_user.sign_in_count == 1)
      if is_new_user
        @greeting_text = "Welcome #{current_intake.greeting_name}!"
        @overview_text = "Here's what to expect."
        @help_text = "We will ask a series of questions for each section. It should take you about 30 minutes to complete. Once your form is submitted, we’ll review and connect you to a tax preparer. We automatically save your answers throughout the process."
      else
        @greeting_text = "Welcome back #{current_intake.greeting_name}!"
        @overview_text = "Let's jump back in!"
        @help_text = "Remember, we can only finish filing your taxes when all of these steps are completed."
      end
    end

    def self.form_class
      NullForm
    end
  end
end
