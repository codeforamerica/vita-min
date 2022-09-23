module Ctc
  module W2s
    class MiscInfoForm < W2Form
      set_attributes_for(
        :w2,
        :box11_nonqualified_plans,
        :box12a_code,
        :box12a_value,
        :box12b_code,
        :box12b_value,
        :box12c_code,
        :box12c_value,
        :box12d_code,
        :box12d_value,
        :box13_statutory_employee,
        :box13_retirement_plan,
        :box13_third_party_sick_pay,
      )

      validates :box11_nonqualified_plans, gyr_numericality: true, allow_blank: true
      validates_presence_of :box12a_code, if: :box12a_value
      validates_presence_of :box12a_value, if: :box12a_code
      validates_presence_of :box12b_code, if: :box12b_value
      validates_presence_of :box12b_value, if: :box12b_code
      validates_presence_of :box12c_code, if: :box12c_value
      validates_presence_of :box12c_value, if: :box12c_code
      validates_presence_of :box12d_code, if: :box12d_value
      validates_presence_of :box12d_value, if: :box12d_code
      validates :box12a_code, allow_blank: true, inclusion: { in: W2::BOX12_OPTIONS }
      validates :box12b_code, allow_blank: true, inclusion: { in: W2::BOX12_OPTIONS }
      validates :box12c_code, allow_blank: true, inclusion: { in: W2::BOX12_OPTIONS }
      validates :box12d_code, allow_blank: true, inclusion: { in: W2::BOX12_OPTIONS }
      validates :box12a_value, gyr_numericality: true, allow_blank: true
      validates :box12b_value, gyr_numericality: true, allow_blank: true
      validates :box12c_value, gyr_numericality: true, allow_blank: true
      validates :box12d_value, gyr_numericality: true, allow_blank: true

      def save
        extra_attributes = w2.completed_at.nil? ? {completed_at: DateTime.now} : {}
        @w2.assign_attributes(attributes_for(:w2).merge(extra_attributes))
        @w2.save!
      end
    end
  end
end
