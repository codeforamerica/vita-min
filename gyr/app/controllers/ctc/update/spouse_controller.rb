class Ctc::Update::SpouseController < Ctc::Update::BaseIntakeRevisionController
  private
  def edit_template
    "ctc/portal/spouse/edit"
  end

  def form_class
    Ctc::Portal::SpouseForm
  end
end
