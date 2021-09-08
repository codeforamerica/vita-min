module SoftDeletable
  extend ActiveSupport::Concern

  included do
    default_scope { where(soft_deleted_at: nil) }

    scope :with_deleted, -> { unscope(where: :soft_deleted_at) }
    scope :only_deleted, -> { unscope(where: :soft_deleted_at).where.not(soft_deleted_at: nil) }
  end
end
