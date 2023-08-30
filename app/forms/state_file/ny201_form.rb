module StateFile
  class Ny201Form < QuestionsForm
    include DateHelper

    set_attributes_for :intake,
                       :primary_email,
                             :date_electronic_withdrawal_year,
                             :date_electronic_withdrawal_month,
                             :date_electronic_withdrawal_day

    def save
      exceptions = [:date_electronic_withdrawal_year, :date_electronic_withdrawal_month, :date_electronic_withdrawal_day]
      @intake.update(
        attributes_for(:intake)
          .except(*exceptions)
          .merge(
            date_electronic_withdrawal: parse_date_params(date_electronic_withdrawal_year, date_electronic_withdrawal_month, date_electronic_withdrawal_day),
          )
      )
    end

    def self.existing_attributes(intake)
      attributes = HashWithIndifferentAccess.new(intake.attributes)
      if attributes[:date_electronic_withdrawal].present?
        birth_date = attributes[:date_electronic_withdrawal]
        attributes.merge!(
          date_electronic_withdrawal_year: birth_date.year,
          date_electronic_withdrawal_month: birth_date.month,
          date_electronic_withdrawal_day: birth_date.day
        )
      end
      attributes
    end
  end
end