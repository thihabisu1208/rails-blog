require 'rails_helper'

RSpec.describe "Pages", type: :request do
  describe "GET /" do
    it "returns http success" do
      get root_path
      expect(response).to have_http_status(:success)
    end

    it "does not require authentication" do
      get root_path
      expect(response).not_to redirect_to(login_path)
    end

    it "renders the landing page" do
      get root_path
      expect(response.body).to be_present
    end
  end
end
