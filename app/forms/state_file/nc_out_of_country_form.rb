module StateFile
  class NcOutOfCountryForm < QuestionsForm
    set_attributes_for :intake, :out_of_country

    validates :out_of_country, inclusion: { in: %w[yes no], message: :blank }

    def save
      @intake.update!(attributes_for(:intake))
    end
  end
end