module StateFile
  class AllInfoForm < QuestionsForm
    include DateHelper

    set_attributes_for :state_file_ny_intake,
                       :birth_date_year,
                       :birth_date_month,
                       :birth_date_day,
                       :city,
                       :primary_first_name,
                       :primary_last_name,
                       :ssn,
                       :street_address,
                       :tax_return_year,
                       :zip_code,
                       :tp_id

    def save
      @intake.update(
        attributes_for(:state_file_ny_intake)
          .except(:birth_date_year, :birth_date_month, :birth_date_day)
          .merge(
            birth_date: parse_date_params(birth_date_year, birth_date_month, birth_date_day)
          )
      )
    end

    def self.existing_attributes(intake)
      attributes = HashWithIndifferentAccess.new(intake.attributes)
      if attributes[:birth_date].present?
        birth_date = attributes[:birth_date]
        attributes.merge!(
          birth_date_year: birth_date.year,
          birth_date_month: birth_date.month,
          birth_date_day: birth_date.day,
        )
      end
      attributes
    end
  end
end