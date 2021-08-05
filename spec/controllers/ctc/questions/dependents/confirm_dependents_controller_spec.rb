require 'rails_helper'

describe Ctc::Questions::Dependents::ConfirmDependentsController do
  let(:intake) { create :ctc_intake }
  let(:dependent) { create :dependent, intake: intake }

  before do
    sign_in intake.client
  end

  # TODO: should redirect page to next path if there are no dependents
end
