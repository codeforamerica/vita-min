module Ctc
  class Filed2020Form < QuestionsForm
    set_attributes_for :eligibility, :filed_2020

    def save; end

    def filed_2020?
      filed_2020 == "yes"
    end
  end
end