module StateFile
  class NySalesUseTaxForm < QuestionsForm
    set_attributes_for :intake,
                       :untaxed_out_of_state_purchases,
                       :sales_use_tax_calculation_method,
                       :sales_use_tax

    validates :untaxed_out_of_state_purchases, presence: true
    validates :sales_use_tax_calculation_method, presence: true, if: -> { untaxed_out_of_state_purchases == "yes" }
    validates :sales_use_tax, presence: true, if: -> { sales_use_tax_calculation_method == "manual" }

    def initialize(intake = nil, params = nil)
      if params[:untaxed_out_of_state_purchases] == "no"
        params[:sales_use_tax_calculation_method] = "unfilled"
        params[:sales_use_tax] = nil
      end
      if params[:sales_use_tax_calculation_method] == "automated"
        params[:sales_use_tax] = intake.calculate_sales_use_tax
      end
      super(intake, params)
    end

    def save
      attributes = attributes_for(:intake)
      attributes[:untaxed_out_of_state_purchases] = "unfilled" unless attributes[:untaxed_out_of_state_purchases].present?
      attributes[:sales_use_tax_calculation_method] = "unfilled" unless attributes[:sales_use_tax_calculation_method].present?
      attributes[:sales_use_tax] = intake.calculate_sales_use_tax if attributes[:sales_use_tax_calculation_method] == :automated

      @intake.update!(attributes)
    end
  end
end