class Ctc::Update::PrimaryFilerController < Ctc::Update::BaseIntakeRevisionController
  def edit
    super
    render "ctc/portal/primary_filer/edit"
  end

  private

  def form_class
    Ctc::Portal::PrimaryFilerForm
  end
end
