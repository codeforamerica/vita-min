module Ctc
  module Dependents
    class InfoForm < DependentForm
      include BirthDateHelper

      set_attributes_for :dependent,
                         :first_name,
                         :middle_initial,
                         :last_name,
                         :suffix,
                         :relationship,
                         :full_time_student,
                         :permanently_totally_disabled
      set_attributes_for :birthday, :birth_date_month, :birth_date_day, :birth_date_year

      validates :first_name, presence: true, legal_name: true
      validates :last_name, presence: true, legal_name: true
      validates :middle_initial, length: { maximum: 1 }, legal_name: true
      validates_presence_of :relationship
      validate :birth_date_is_valid_date

      def save
        @dependent.assign_attributes(attributes_for(:dependent).merge(
          birth_date: birth_date
        ))
        @dependent.save
      end

      def self.existing_attributes(dependent, _attribute_keys)
        if dependent.birth_date.present?
          super.merge(
            birth_date_day: dependent.birth_date.day,
            birth_date_month: dependent.birth_date.month,
            birth_date_year: dependent.birth_date.year,
          )
        else
          super
        end
      end

      private

      def birth_date
        parse_birth_date_params(birth_date_year, birth_date_month, birth_date_day)
      end

      def birth_date_is_valid_date
        valid_text_birth_date(birth_date_year, birth_date_month, birth_date_day, :birth_date)
      end
    end
  end
end
