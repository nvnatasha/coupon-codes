require 'rails_helper'

RSpec.describe "Coupons API", type: :request do
    describe "GET /api/v1/merchants/:merchant_id/coupons/:id" do
        it "returns a specific coupon for a merchant" do

        merchant = Merchant.create!(name: 'Taylor Swift Store')
    
        coupon = Coupon.create!(
            name: "50Percent",
            code: "50OFF",
            discount_type: "percent",
            discount_value: 50,
            status: true,
            merchant_id: merchant.id
        )

        get "/api/v1/merchants/#{merchant.id}/coupons/#{coupon.id}"
    
        json_response = JSON.parse(response.body, symbolize_names: true)[:data].first
    
        expect(json_response[:id]).to eq(coupon.id.to_s)
        expect(json_response[:type]).to eq("coupon")
        expect(json_response[:attributes][:name]).to eq("50Percent")
        expect(json_response[:attributes][:code]).to eq("50OFF")
        expect(json_response[:attributes][:discount_type]).to eq("percent")
        expect(json_response[:attributes][:discount_value]).to eq(50)
        expect(json_response[:attributes][:status]).to eq(true)
        end
    end
end
