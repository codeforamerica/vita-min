class IndexFaqSurveysOnFindyColumns < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :faq_surveys, [:visitor_id, :question_key], algorithm: :concurrently
  end
end
