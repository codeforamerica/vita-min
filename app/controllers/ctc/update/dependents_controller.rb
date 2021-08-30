class Ctc::Update::DependentsController < Ctc::Portal::DependentsController
  def confirm_remove
    render 'ctc/portal/dependents/confirm_remove'
  end

  def destroy
    current_model.destroy!
    flash[:alert] = "Family member / dependent removed from your tax return."
    redirect_to questions_confirm_information_path
  end

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
