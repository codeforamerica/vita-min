module Hub
  module StateFile
    class FaqCategoriesController < Hub::BaseController
      before_action :require_admin
      before_action :set_paper_trail_whodunnit
      load_and_authorize_resource :faq_category
      layout "hub"

      def index
        @az_faq_categories = @faq_categories.where(product_type: "state_file_az")
        @ny_faq_categories = @faq_categories.where(product_type: "state_file_ny")
      end

      def edit
        @form = form_class.from_record(@faq_category)
      end

      def show; end

      def new
        @form = form_class.new(FaqCategory.new, {product_type: "state_file_az"})
      end

      def create
        @form = form_class.new(@faq_category, faq_category_params)

        if @form.save
          flash_message = "Successfully created '#{@faq_category.name_en}' category"
          redirect_to hub_faq_categories_path, notice: flash_message
        else
          flash_message = "Unable to create '#{@faq_category.name_en}' category"
          @position_options = (1..(FaqCategory.all.count + 1)).to_a
          render :new, error: flash_message
        end
      end

      def update
        @form = form_class.new(@faq_category, faq_category_params)

        if @form.save
          flash_message = "Successfully updated '#{@faq_category.name_en}' category"
          redirect_to hub_faq_categories_path, notice: flash_message
        else
          flash_message = "Unable to update '#{@faq_category.name_en}' category"
          render :edit, error: flash_message
        end
      end

      def destroy
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
        redirect_to hub_faq_categories_path, notice: flash_message
      end

      private

      def faq_category_params
        params.fetch(:hub_faq_category_form, {}).permit(*form_class.attribute_names)
      end

      def form_class
        Hub::FaqCategoryForm
      end
    end
  end
end