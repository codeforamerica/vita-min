module Ctc
  class Filed2019Form < QuestionsForm
    set_attributes_for :intake, :filed2019

    def save
      @intake.update(transform_attributes(attributes_for(:intake)))
    end

    private

    def transform_attributes(attributes)
      { filed_2019: attributes[:filed2019] }
    end
  end
end