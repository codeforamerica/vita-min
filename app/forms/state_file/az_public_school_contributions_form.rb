module StateFile
  class AzPublicSchoolContributionsForm < QuestionsForm
    include DateHelper

    set_attributes_for :az322_contribution,
                       :school_name,
                       :ctds_code,
                       :district_name,
                       :amount,
                       :made_contribution, :date_of_contribution_day,
                       :date_of_contribution_month,
                       :date_of_contribution_year

    validates :made_contribution, inclusion: { in: %w[yes no], message: :blank }
    validates :school_name, presence: true, if: -> { made_contribution == "yes" }
    validates :ctds_code, presence: true, format: { with: /\A\d{9}\z/, message: 'must be exactly 9 digits' }, if: -> { made_contribution == "yes" }
    validates :district_name, presence: true, if: -> { made_contribution == "yes" }
    validates :amount, presence: true, numericality: { greater_than: 0 }, if: -> { made_contribution == "yes" }
    validate :date_of_contribution_is_valid_date, if: -> { made_contribution == "yes" }

    def save
      binding.pry
      if made_contribution == "no"
        @intake.update(
          made_contribution: "no",
          school_name: nil,
          ctds_code: nil,
          district_name: nil,
          amount: nil,
          date_of_contribution: nil
        )
      else
        @intake.update(
          date_of_contribution: date_of_contribution
        )
      end
    end

    def self.existing_attributes(az322_contribution)
      if az322_contribution.present?
        super.merge(
          date_of_contribution_day: az322_contribution.date_of_contribution&.day,
          date_of_contribution_month: az322_contribution.date_of_contribution&.month,
          date_of_contribution_year: az322_contribution.date_of_contribution&.year,
          )
      else
        super
      end
    end

    private

    def date_of_contribution
      parse_date_params(date_of_contribution_year, date_of_contribution_month, date_of_contribution_day)
    end

    def date_of_contribution_is_valid_date
      valid_text_date(date_of_contribution_year, date_of_contribution_month, date_of_contribution_day, :date_of_contribution)
    end
  end
end
