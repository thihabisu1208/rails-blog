require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:user) { User.create!(email: 'author@example.com', password: 'password123') }

  # Create a valid subject for shoulda-matchers
  subject { Post.new(title: 'Test Post', content: 'This is test content with enough characters', user: user) }

  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:content) }
    it { should validate_presence_of(:user) }

    # Title length validations (added in PR)
    it { should validate_length_of(:title).is_at_least(3).with_message('is too short (minimum is 3 characters)') }
    it { should validate_length_of(:title).is_at_most(200).with_message('is too long (maximum is 200 characters)') }

    # Content length validations (added in PR)
    it { should validate_length_of(:content).is_at_least(10).with_message('is too short (minimum is 10 characters)') }
    it { should validate_length_of(:content).is_at_most(1_000_000).with_message('is too long (maximum is 1000000 characters)') }

    # Excerpt length validation (added in PR)
    it { should validate_length_of(:excerpt).is_at_most(500).with_message('is too long (maximum is 500 characters)') }

    # Slug uniqueness (added in PR)
    it 'validates uniqueness of slug scoped to discarded_at' do
      user = User.create!(email: 'test@example.com', password: 'password123')
      Post.create!(title: 'Unique Post', slug: 'unique-post', content: 'Content here', user: user)

      duplicate = Post.new(title: 'Another Post', slug: 'unique-post', content: 'Different content', user: user)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:slug]).to include('has already been taken')
    end

    # Featured image URL validation (added in PR)
    describe 'featured_image_url validation' do
      it 'allows valid HTTP URLs' do
        post = Post.new(title: 'Test', content: 'Content here', user: user, featured_image_url: 'http://example.com/image.jpg')
        expect(post).to be_valid
      end

      it 'allows valid HTTPS URLs' do
        post = Post.new(title: 'Test', content: 'Content here', user: user, featured_image_url: 'https://example.com/image.jpg')
        expect(post).to be_valid
      end

      it 'allows blank URLs' do
        post = Post.new(title: 'Test', content: 'Content here', user: user, featured_image_url: '')
        expect(post).to be_valid
      end

      it 'rejects javascript: URLs (XSS prevention)' do
        post = Post.new(title: 'Test', content: 'Content here', user: user, featured_image_url: "javascript:alert('xss')")
        expect(post).not_to be_valid
        expect(post.errors[:featured_image_url]).to include('must be a valid HTTP or HTTPS URL')
      end

      it 'rejects data: URLs' do
        post = Post.new(title: 'Test', content: 'Content here', user: user, featured_image_url: 'data:text/html,<script>alert("xss")</script>')
        expect(post).not_to be_valid
        expect(post.errors[:featured_image_url]).to include('must be a valid HTTP or HTTPS URL')
      end

      it 'rejects invalid URLs' do
        post = Post.new(title: 'Test', content: 'Content here', user: user, featured_image_url: 'not-a-url')
        expect(post).not_to be_valid
        expect(post.errors[:featured_image_url]).to include('must be a valid HTTP or HTTPS URL')
      end
    end
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:post_categories).dependent(:destroy) }
    it { should have_many(:categories).through(:post_categories) }
  end

  describe 'callbacks' do
    describe 'slug generation' do
      it 'generates slug from title before save' do
        post = Post.create!(title: 'My First Post', content: 'Content here', user: user)
        expect(post.slug).to eq('my-first-post')
      end

      it 'handles titles with special characters' do
        post = Post.create!(title: 'Rails & JavaScript: A Guide!', content: 'Content here', user: user)
        expect(post.slug).to eq('rails-javascript-a-guide')
      end

      it 'handles titles with multiple spaces' do
        post = Post.create!(title: 'Rails    Best   Practices', content: 'Content here', user: user)
        expect(post.slug).to eq('rails-best-practices')
      end
    end
  end

  describe 'scopes' do
    let!(:published_post) { Post.create!(title: 'Published', content: 'Content here', user: user, is_published: true, views_count: 10) }
    let!(:draft_post) { Post.create!(title: 'Draft', content: 'Content here', user: user, is_published: false, views_count: 1) }
    let!(:popular_post) { Post.create!(title: 'Popular', content: 'Content here', user: user, views_count: 100) }
    let!(:unpopular_post) { Post.create!(title: 'Unpopular', content: 'Content here', user: user, views_count: 5) }

    describe '.published' do
      it 'returns only published posts' do
        expect(Post.published).to include(published_post)
        expect(Post.published).not_to include(draft_post)
      end
    end

    describe '.by_views' do
      it 'orders posts by views_count descending' do
        expect(Post.by_views.first).to eq(popular_post)
        expect(Post.by_views.to_a).to eq([ popular_post, published_post, unpopular_post, draft_post ])
      end
    end
  end

  describe 'defaults' do
    it 'sets views_count to 0 by default' do
      post = Post.create!(title: 'Test', content: 'Content here', user: user)
      expect(post.views_count).to eq(0)
    end

    it 'sets is_published to false by default' do
      post = Post.create!(title: 'Test', content: 'Content here', user: user)
      expect(post.is_published).to eq(false)
    end
  end

  describe 'soft delete' do
    it 'includes Discard::Model' do
      expect(Post.included_modules).to include(Discard::Model)
    end

    it 'soft deletes instead of destroying' do
      post = Post.create!(title: 'Test', content: 'Content here', user: user)
      post.discard

      expect(post.discarded?).to be true
      expect(post.discarded_at).not_to be_nil
      expect(Post.kept.count).to eq(0)
      expect(Post.with_discarded.count).to eq(1)
    end

    it 'can be restored' do
      post = Post.create!(title: 'Test', content: 'Content here', user: user)
      post.discard
      post.undiscard

      expect(post.discarded?).to be false
      expect(post.discarded_at).to be_nil
    end
  end

  describe '#to_param' do
    it 'returns slug instead of id' do
      post = Post.create!(title: 'My Post', content: 'Content here', user: user)
      expect(post.to_param).to eq('my-post')
    end
  end
end
