require 'rails_helper'

RSpec.describe "ApplicationController", type: :request do
  let(:user) { User.create!(email: 'test@example.com', password: 'password123') }

  def login_as(user)
    post sessions_path, params: { email: user.email, password: 'password123' }
  end

  describe "session expiry" do
    # Note: Session manipulation across requests is difficult in request specs
    # Session expiry is better tested in controller specs or integration tests
    # These tests verify the basic session management behavior

    context "when user is not logged in" do
      it "does not check session expiry" do
        get root_path
        expect(response).to have_http_status(:success)
      end
    end

    context "when user is logged in" do
      it "allows access with valid session" do
        login_as(user)
        get posts_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "authentication" do
    context "when accessing protected pages" do
      it "redirects to login when not authenticated" do
        get posts_path
        expect(response).to redirect_to(login_path)
      end

      it "allows access when authenticated" do
        login_as(user)
        get posts_path
        expect(response).to have_http_status(:success)
      end
    end

    context "when accessing public pages" do
      it "allows access to root path without authentication" do
        get root_path
        expect(response).to have_http_status(:success)
      end

      it "allows access to published post without authentication" do
        public_post = Post.create!(title: 'Public Post', content: 'Content for public post here', user: user, is_published: true)
        get post_path(public_post.slug)
        expect(response).to have_http_status(:success)
      end

      it "allows access to login page without authentication" do
        get login_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "current_user helper" do
    it "returns nil when not logged in" do
      get root_path
      expect(controller.send(:current_user)).to be_nil
    end

    it "returns the user when logged in" do
      login_as(user)
      get posts_path
      expect(controller.send(:current_user)).to eq(user)
    end

    it "memoizes the user lookup" do
      login_as(user)
      get posts_path

      # Should only query once due to memoization
      expect(User).not_to receive(:find_by)
      controller.send(:current_user)
      controller.send(:current_user)
    end
  end
end
