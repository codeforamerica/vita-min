module StateFile
  class NyPermanentAddressForm < QuestionsForm
    set_attributes_for :intake, :confirmed_permanent_address

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end