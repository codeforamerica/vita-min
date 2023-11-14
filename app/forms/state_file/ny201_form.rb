module StateFile
  class Ny201Form < QuestionsForm
    include DateHelper

    set_attributes_for :intake,
                       :primary_email,
                       :date_electronic_withdrawal_year,
                       :date_electronic_withdrawal_month,
                       :date_electronic_withdrawal_day,
                       :residence_county,
                       :school_district,
                       :school_district_number,
                       :nyc_full_year_resident,
                       :ny_414h_retirement,
                       :ny_other_additions,
                       :amount_electronic_withdrawal,
                       :refund_choice,
                       :account_type,
                       :routing_number,
                       :account_number,
                       :amount_electronic_withdrawal

    validates :routing_number, length: { is: 9 }, allow_blank: true, routing_number: true

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