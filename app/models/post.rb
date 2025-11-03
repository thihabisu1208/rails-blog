class Post < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :post_categories, dependent: :destroy
  has_many :categories, through: :post_categories

  # Validations
  validates :title, :content, presence: true

  # Callbacks
  before_save :generate_slug

  # Scopes (reusable queries)
  scope :published, -> { where(is_published: true) }
  scope :by_views, -> { order(views_count: :desc) }

  private

  def generate_slug
    self.slug = title.parameterize if title.present?
  end
end
