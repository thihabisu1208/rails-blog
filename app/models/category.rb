class Category < ApplicationRecord
  # Associations
  has_many :post_categories, dependent: :destroy
  has_many :posts, through: :post_categories

  # Validations
  validates :name, presence: true, uniqueness: true

  # Callbacks
  before_save :generate_slug

  private

  def generate_slug
    self.slug = name.parameterize if name.present?
  end
end
