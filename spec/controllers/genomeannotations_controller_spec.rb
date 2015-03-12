require 'rails_helper'

RSpec.describe GenomeannotationsController, :type => :controller do

  describe "GET upload" do
    it "returns http success" do
      get :upload
      expect(response).to have_http_status(:success)
    end
  end

end
