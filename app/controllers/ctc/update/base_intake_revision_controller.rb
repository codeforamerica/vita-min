class Ctc::Update::BaseIntakeRevisionController < Ctc::Portal::BaseIntakeRevisionController
  def update
    @form = form_class.new(current_model, form_params)
    if @form.valid?
      @form.save
      redirect_to questions_confirm_information_path
    else
      render :edit
    end
  end
end
