class Ctc::Update::SpouseController < Ctc::Update::BaseIntakeRevisionController
  def edit
    super
    render "ctc/portal/spouse/edit"
  end

  private

  def form_class
    Ctc::Portal::SpouseForm
  end
end
