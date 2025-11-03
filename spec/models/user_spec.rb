require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should have_secure_password }
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
end
