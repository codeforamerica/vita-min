module Ctc
  class Filed2020Form < QuestionsForm
    set_attributes_for :intake, :filed2020

    def save
      @intake.update(transform_attributes(attributes_for(:intake)))
    end

    private

    def transform_attributes(attributes)
      { filed_2020: attributes[:filed2020] }
    end
  end
end