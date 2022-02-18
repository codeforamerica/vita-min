class FaqController < ApplicationController
  QUESTIONS = {
    stimulus: [
      :how_many_stimulus_payments_were_there,
      :will_there_be_another_stimulus_payment
    ]
  }

  skip_before_action :check_maintenance_mode

  def include_analytics?
    true
  end

  def index

  end

  def section_index
    # validate that it is actually good, 404 if not

    @section_key = params[:section_key]
  end

  def show
    @section_key = params[:section_key]
    @question_key = params[:question_key].underscore
  end
end
