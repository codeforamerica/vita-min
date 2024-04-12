module StateFile
  class AzCharitableContributionsForm < QuestionsForm
    set_attributes_for :intake, :charitable_contributions, :charitable_cash, :charitable_noncash

    validates :charitable_contributions, inclusion: { in: %w[yes no], message: :blank }
    validates_numericality_of :charitable_cash, only_integer: true, message: :whole_number, if: -> { charitable_contributions == "yes" && charitable_cash.present? }
    validates :charitable_cash, numericality: { greater_than_or_equal_to: 1, message: ->(_object, _data) { I18n.t('errors.messages.greater_than_or_equal_to', count: 1)}  }, if: -> { charitable_contributions == "yes" }
    validates_numericality_of :charitable_noncash, only_integer: true, message: :whole_number, if: -> { charitable_contributions == "yes" && charitable_noncash.present? }
    validates :charitable_noncash, numericality: { greater_than_or_equal_to: 1, message: ->(_object, _data) { I18n.t('errors.messages.greater_than_or_equal_to', count: 1)} }, if: -> { charitable_contributions == "yes" }
    validates :charitable_noncash, numericality: { less_than_or_equal_to: 500, message: ->(_object, _data) { I18n.t('errors.messages.less_than_or_equal_to', count: 500)} }, if: -> { charitable_contributions == "yes" }


    def save
      if charitable_contributions == "no"
        @intake.update(charitable_contributions: "no", charitable_cash: nil, charitable_noncash: nil)
      else
        @intake.update(attributes_for(:intake))
      end
    end
  end
end