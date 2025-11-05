require 'rails_helper'

RSpec.describe User, type: :model do
  # Create a valid subject for shoulda-matchers
  # This is needed because of our NOT NULL database constraints
  subject { User.new(email: 'test@example.com', password: 'password123') }

  describe 'validations' do
    it { should validate_presence_of(:email) }

    # Fix for NOT NULL constraint - provide a valid subject
    it { should validate_uniqueness_of(:email).case_insensitive }

    it { should have_secure_password }

    # New validation tests from our PR
    it { should allow_value('user@example.com').for(:email) }
    it { should allow_value('test.user+tag@example.co.uk').for(:email) }
    it { should_not allow_value('notanemail').for(:email).with_message('must be a valid email address') }
    it { should_not allow_value('user@').for(:email).with_message('must be a valid email address') }
    it { should_not allow_value('@example.com').for(:email).with_message('must be a valid email address') }

    it { should validate_length_of(:password).is_at_least(6).with_message('must be at least 6 characters') }
  end

  describe 'email normalization' do
    it 'converts email to lowercase before save' do
      user = User.create(email: 'TEST@EXAMPLE.COM', password: 'password123')
      expect(user.email).to eq('test@example.com')
    end

    it 'strips whitespace from email before save' do
      user = User.create(email: '  test@example.com  ', password: 'password123')
      expect(user.email).to eq('test@example.com')
    end
  end

  describe 'email uniqueness (case-insensitive)' do
    it 'prevents duplicate emails with different cases' do
      User.create!(email: 'john@example.com', password: 'password123')
      duplicate = User.new(email: 'JOHN@example.com', password: 'password123')

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to include('has already been taken')
    end
  end

  describe 'password authentication' do
    let(:user) { User.create(email: 'test@example.com', password: 'password123') }

    it 'authenticates with correct password' do
      expect(user.authenticate('password123')).to eq(user)
    end

    it 'fails to authenticate with wrong password' do
      expect(user.authenticate('wrongpassword')).to be_falsey
    end

    it 'hashes the password' do
      expect(user.password_digest).not_to eq('password123')
      expect(user.password_digest).to start_with('$2a$')
    end
  end

  describe 'associations' do
    it { should have_many(:posts).dependent(:destroy) }
  end
end
