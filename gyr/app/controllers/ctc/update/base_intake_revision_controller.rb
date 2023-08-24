class Ctc::Update::BaseIntakeRevisionController < Ctc::Portal::BaseIntakeRevisionController
  def update
    @form = form_class.new(current_model, form_params)
    if @form.valid?
      @form.save
      redirect_to questions_confirm_information_path
    else
      render edit_template
    end
  end

  def prev_path
    questions_confirm_information_path
  end
  helper_method :prev_path
end
