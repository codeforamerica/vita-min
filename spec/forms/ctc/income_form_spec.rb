require "rails_helper"

describe Ctc::IncomeForm, requires_default_vita_partners: true do
  it_behaves_like :initial_ctc_form
end
