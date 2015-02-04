require 'rails_helper'

RSpec.describe StaticPagesController, :type => :controller do

  describe "GET help" do
    it "returns http success" do
      get :help
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET resources" do
    it "returns http success" do
      get :resources
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET contact" do
    it "returns http success" do
      get :contact
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET copyright" do
    it "returns http success" do
      get :copyright
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET privacy" do
    it "returns http success" do
      get :privacy
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET linking" do
    it "returns http success" do
      get :linking
      expect(response).to have_http_status(:success)
    end
  end

end
