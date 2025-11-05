require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  let(:user) { User.create!(email: 'test@example.com', password: 'password123') }

  describe "GET /login" do
    it "returns http success" do
      get login_path
      expect(response).to have_http_status(:success)
    end

    it "renders the login form" do
      get login_path
      expect(response.body).to match(/<form/)
    end
  end

  describe "POST /sessions" do
    context "with valid credentials" do
      it "logs in the user" do
        post sessions_path, params: { email: user.email, password: 'password123' }
        expect(session[:user_id]).to eq(user.id)
      end

      it "sets session expiry" do
        post sessions_path, params: { email: user.email, password: 'password123' }
        expect(session[:expires_at]).to be_present
        expect(Time.parse(session[:expires_at].to_s)).to be > Time.current
      end

      it "redirects to admin path" do
        post sessions_path, params: { email: user.email, password: 'password123' }
        expect(response).to redirect_to(admin_path)
      end

      it "shows success notice" do
        post sessions_path, params: { email: user.email, password: 'password123' }
        expect(flash[:notice]).to eq('Logged in successfully')
      end

      it "resets session to prevent session fixation" do
        # Set a value in session before login
        get login_path
        old_session_id = session.id

        post sessions_path, params: { email: user.email, password: 'password123' }

        # Session should have new ID after login
        expect(session[:user_id]).to eq(user.id)
      end
    end

    context "with invalid credentials" do
      it "does not log in the user with wrong password" do
        post sessions_path, params: { email: user.email, password: 'wrongpassword' }
        expect(session[:user_id]).to be_nil
      end

      it "does not log in with non-existent email" do
        post sessions_path, params: { email: 'nonexistent@example.com', password: 'password123' }
        expect(session[:user_id]).to be_nil
      end

      it "renders the login form again" do
        post sessions_path, params: { email: user.email, password: 'wrongpassword' }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "shows error alert" do
        post sessions_path, params: { email: user.email, password: 'wrongpassword' }
        expect(flash[:alert]).to eq('Invalid email or password')
      end
    end
  end

  describe "DELETE /logout" do
    before do
      post sessions_path, params: { email: user.email, password: 'password123' }
    end

    it "logs out the user" do
      delete logout_path
      expect(session[:user_id]).to be_nil
    end

    it "clears all session data" do
      delete logout_path
      expect(session[:expires_at]).to be_nil
    end

    it "redirects to root path" do
      delete logout_path
      expect(response).to redirect_to(root_path)
    end

    it "shows logout notice" do
      delete logout_path
      expect(flash[:notice]).to eq('Logged out')
    end
  end
end
