class Post < ApplicationRecord
  # Soft delete support
  include Discard::Model

  # Associations
  belongs_to :user
  has_many :post_categories, dependent: :destroy
  has_many :categories, through: :post_categories

  # Validations
  validates :title, presence: true, length: { minimum: 3, maximum: 200 }
  validates :content, presence: true, length: { minimum: 10, maximum: 1_000_000 }
  validates :excerpt, length: { maximum: 500 }, allow_blank: true
  validates :user, presence: true
  validates :slug, uniqueness: { scope: :discarded_at, message: "has already been taken" }

  # URL format validation for featured image
  validates :featured_image_url,
    format: {
      with: /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/,
      message: "must be a valid HTTP or HTTPS URL"
    },
    allow_blank: true

  # Callbacks
  before_save :generate_slug

  # Scopes (reusable queries)
  scope :published, -> { where(is_published: true) }
  scope :by_views, -> { order(views_count: :desc) }

  def to_param
    slug
  end

  private

  def generate_slug
    self.slug = title.parameterize if title.present?
  end
end
