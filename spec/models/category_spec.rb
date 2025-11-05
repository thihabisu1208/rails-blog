require 'rails_helper'

RSpec.describe Category, type: :model do
  subject { Category.new(name: 'Rails') }

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe 'associations' do
    it { should have_many(:post_categories).dependent(:destroy) }
    it { should have_many(:posts).through(:post_categories) }
  end

  describe 'slug generation' do
    it 'generates slug from name before save' do
      category = Category.create!(name: 'Ruby on Rails')
      expect(category.slug).to eq('ruby-on-rails')
    end

    it 'handles names with special characters' do
      category = Category.create!(name: 'C++ & JavaScript')
      expect(category.slug).to eq('c-javascript')
    end
  end
end
