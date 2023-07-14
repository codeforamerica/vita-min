module Hub
  class FaqCategoriesController < ApplicationController
    include AccessControllable
    before_action :require_sign_in
    before_action :require_admin
    layout "hub"

    def index
      @faq_categories = FaqCategory.all #order by position
      @faq_items = FaqItem.all #group_by categories
    end

  end
end