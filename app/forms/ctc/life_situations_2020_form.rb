module Ctc
  class LifeSituations2020Form < QuestionsForm
    # TBD
    set_attributes_for :intake, :street_address, :street_address2, :state, :city, :zip_code

    validates_presence_of :street_address
    validates_presence_of :city
    validates_presence_of :state
    validates :zip_code, zip_code: true


    def save
      @intake.update(attributes_for(:intake))
    end
  end
end