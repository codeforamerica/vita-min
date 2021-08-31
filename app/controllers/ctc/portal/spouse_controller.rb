class Ctc::Portal::SpouseController < Ctc::Portal::BaseIntakeRevisionController
  private

  def edit_template
    "ctc/portal/spouse/edit"
  end

  def form_class
    Ctc::Portal::SpouseForm
  end
end
