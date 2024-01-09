module Hub
  class FaqCategoriesController < Hub::BaseController
    before_action :require_admin
    before_action :set_paper_trail_whodunnit
    before_action :load_faq_return_path
    load_and_authorize_resource
    layout "hub"

    def index
      @faq_categories = @faq_categories.where(product_type: "gyr")
    end

    def edit
      @form = form_class.from_record(@faq_category)
    end

    def show; end

    def new
      @form = form_class.new(FaqCategory.new, {})
    end

    def create
      @form = form_class.new(@faq_category, faq_category_params)

      if @form.save
        flash_message = "Successfully created '#{@faq_category.name_en}' category"
        redirect_to send(@faq_return_path), notice: flash_message
      else
        flash_message = "Unable to create '#{@faq_category.name_en}' category"
        render :new, error: flash_message
      end
    end

    def update
      @faq_return_path = :hub_state_file_faq_categories_path unless @faq_category.product_type_gyr?
      @form = form_class.new(@faq_category, faq_category_params)

      if @form.save
        flash_message = "Successfully updated '#{@faq_category.name_en}' category"
        redirect_to send(@faq_return_path), notice: flash_message
      else
        flash_message = "Unable to update '#{@faq_category.name_en}' category"
        render :edit, error: flash_message
      end
    end

    def destroy
      @faq_return_path = :hub_state_file_faq_categories_path unless @faq_category.product_type_gyr?
      begin
        ActiveRecord::Base.transaction do
          # if faq_items deletion fails, don't destroy their faq_category
          @faq_category.faq_items.map(&:destroy)
          @faq_category.destroy!
        end
        flash_message = "Deleted '#{@faq_category.name_en}' category and associated items"
      rescue ActiveRecord::InvalidForeignKey
        flash_message = "Unable to delete '#{@faq_category.name_en}' category and associated items"
      end
      redirect_to send(@faq_return_path), notice: flash_message
    end

    private

    def faq_category_params
      params.fetch(:hub_faq_category_form, {}).permit(*form_class.attribute_names)
    end

    def load_faq_return_path
      @faq_return_path = :hub_faq_categories_path
    end

    def form_class
      Hub::FaqCategoryForm
    end
  end
end