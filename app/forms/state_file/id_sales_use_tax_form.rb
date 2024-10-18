module StateFile
  class IdSalesUseTaxForm < QuestionsForm
    set_attributes_for :intake, :has_unpaid_sales_use_tax, :total_purchase_amount

    validates :has_unpaid_sales_use_tax, inclusion: { in: %w[yes no], message: :blank }
    validates :total_purchase_amount,
      presence: true,
      numericality: {
        allow_blank: true,
        greater_than_or_equal_to: 0,
        message: I18n.t("state_file.questions.nc_sales_use_tax.edit.not_a_number")
      },
      if: -> { has_unpaid_sales_use_tax == "yes" }

    def save
      attributes_to_save = attributes_for(:intake)
      attributes_to_save[:total_purchase_amount] = nil if has_unpaid_sales_use_tax == "no"
      @intake.update!(attributes_to_save)
    end
  end
end