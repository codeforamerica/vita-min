class Ctc::Update::PrimaryFilerController < Ctc::Update::BaseIntakeRevisionController
  private

  def edit_template
    "ctc/portal/primary_filer/edit"
  end

  def form_class
    Ctc::Portal::PrimaryFilerForm
  end
end
