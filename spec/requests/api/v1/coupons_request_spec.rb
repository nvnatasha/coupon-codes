require 'rails_helper'

RSpec.describe "Coupons API", type: :request do
    describe "GET /api/v1/merchants/:merchant_id/coupons/:id" do
        it "returns a specific coupon for a merchant" do

        tsStore = Merchant.create!(name: 'Taylor Swift Store')
    
        tsCoupon = Coupon.create!(
            name: "50Percent",
            code: "50PERCENT",
            discount_type: "percent",
            discount_value: 50,
            status: true,
            merchant_id: tsStore.id
        )

        get "/api/v1/merchants/#{tsStore.id}/coupons/#{tsCoupon.id}"

        expect(response).to be_successful
        expect(response.status).to eq(200)
    
        json_response = JSON.parse(response.body, symbolize_names: true)[:data]
    
        expect(json_response[:id]).to eq(tsCoupon.id.to_s)
        expect(json_response[:type]).to eq("coupon")
        expect(json_response[:attributes][:name]).to eq("50Percent")
        expect(json_response[:attributes][:code]).to eq("50PERCENT")
        expect(json_response[:attributes][:discount_type]).to eq("percent")
        expect(json_response[:attributes][:discount_value]).to eq(50)
        expect(json_response[:attributes][:status]).to eq(true)
        end

        it 'returns all coupons for a merchant' do
            tsStore = Merchant.create!(name: 'Taylor Swift Store')
    
            tsCoupon = Coupon.create!(
                name: "50Percent",
                code: "50PERCENT",
                discount_type: "percent",
                discount_value: 50,
                status: true,
                merchant_id: tsStore.id
            )

            ttpdCoupon = Coupon.create!(
                name: "$10 off",
                code: "10OFF",
                discount_type: "dollar",
                discount_value: 10,
                status: false,
                merchant_id: tsStore.id
            )

            repCoupon = Coupon.create!(
                name: "$20 off",
                code: "20OFF",
                discount_type: "dollar",
                discount_value: 20,
                status: true,
                merchant_id: tsStore.id
            )

            get "/api/v1/merchants/#{tsStore.id}/coupons"
            json_response = JSON.parse(response.body, symbolize_names: true)[:data]

            expect(response).to have_http_status(:ok)
            expect(json_response.length).to eq(3)

            expect(json_response[0][:id]).to eq(tsCoupon.id.to_s)
            expect(json_response[0][:type]).to eq("coupon")
            expect(json_response[0][:attributes][:name]).to eq("50Percent")
            expect(json_response[0][:attributes][:code]).to eq("50PERCENT")
            expect(json_response[0][:attributes][:discount_type]).to eq("percent")
            expect(json_response[0][:attributes][:discount_value]).to eq(50)

            expect(json_response[1][:id]).to eq(ttpdCoupon.id.to_s)
            expect(json_response[1][:type]).to eq("coupon")
            expect(json_response[1][:attributes][:name]).to eq("$10 off")
            expect(json_response[1][:attributes][:code]).to eq("10OFF")
            expect(json_response[1][:attributes][:discount_type]).to eq("dollar")
            expect(json_response[1][:attributes][:discount_value]).to eq(10)

            expect(json_response[2][:id]).to eq(repCoupon.id.to_s)
            expect(json_response[2][:type]).to eq("coupon")
            expect(json_response[2][:attributes][:name]).to eq("$20 off")
            expect(json_response[2][:attributes][:code]).to eq("20OFF")
            expect(json_response[2][:attributes][:discount_type]).to eq("dollar")
            expect(json_response[2][:attributes][:discount_value]).to eq(20)
    
        end

        it 'returns a specific coupon and shows a count of how many times it has been used' do
            tsStore = Merchant.create!(name: 'Taylor Swift Store')
            tsCoupon = Coupon.create!(
                name: "50Percent",
                code: "50PERCENT",
                discount_type: "percent",
                discount_value: 50,
                status: true,
                merchant_id: tsStore.id
            )
            chrissy = Customer.create!(first_name: "Chrissy", last_name: "Karrmann")
            
            3.times { Invoice.create!(
                merchant_id: tsStore.id, 
                coupon: tsCoupon, 
                status: 'shipped', 
                customer: chrissy) }
    
            get "/api/v1/merchants/#{tsStore.id}/coupons/#{tsCoupon.id}"
            json_response = JSON.parse(response.body, symbolize_names: true)[:data]
    
            expect(response).to have_http_status(:ok)
            expect(json_response[:id]).to eq(tsCoupon.id.to_s)
            expect(json_response[:type]).to eq("coupon")
            expect(json_response[:attributes][:name]).to eq("50Percent")
            expect(json_response[:attributes][:code]).to eq("50PERCENT")
            expect(json_response[:attributes][:discount_type]).to eq("percent")
            expect(json_response[:attributes][:discount_value]).to eq(50)
            expect(json_response[:attributes][:status]).to be true
            expect(json_response[:attributes][:use_count]).to eq(3)
        end

        it 'returns a usage count of 0 if the coupon has not been used' do
            tsStore = Merchant.create!(name: 'Taylor Swift Store')
            tsCoupon = Coupon.create!(
                name: "50Percent",
                code: "50PERCENT",
                discount_type: "percent",
                discount_value: 50,
                status: true,
                merchant_id: tsStore.id
            )
        
            get "/api/v1/merchants/#{tsStore.id}/coupons/#{tsCoupon.id}"
            json_response = JSON.parse(response.body, symbolize_names: true)
        
            expect(response).to have_http_status(:ok)
            expect(json_response[:data][:attributes][:use_count]).to eq(0)
        end

        it 'returns an empty list if no coupons exist for a merchant' do
            merchant_without_coupons = Merchant.create(name: 'Just a store')
        
            get "/api/v1/merchants/#{merchant_without_coupons.id}/coupons"
        
            json_response = JSON.parse(response.body, symbolize_names: true)
        
            expect(response).to have_http_status(:ok)
            expect(json_response[:data]).to be_empty
        end

        it 'returns a 404 status if the merchant ID is invalid' do
            tsStore = Merchant.create!(name: 'Taylor Swift Store')
            tsCoupon = Coupon.create!(
                name: "50Percent",
                code: "50PERCENT",
                discount_type: "percent",
                discount_value: 50,
                status: true,
                merchant_id: tsStore.id
            )

            notTSStore = tsStore.id + 1

            get "/api/v1/merchants/#{notTSStore}/coupons/#{tsCoupon.id}"
            json_response = JSON.parse(response.body, symbolize_names: true)

            expect(response).to have_http_status(:not_found)
            expect(json_response[:error]).to eq("Merchant not found")
            expect(response.status).to eq(404)
        end


        it 'returns a 404 status if the coupon is invalid' do
            tsStore = Merchant.create!(name: 'Taylor Swift Store')

            get "/api/v1/merchants/#{tsStore.id}/coupons/#{123456}"

            json_response = JSON.parse(response.body, symbolize_names: true)

            expect(response).to have_http_status(:not_found)
            expect(json_response[:error]).to eq("Coupon not found")
            expect(response.status).to eq(404)
        end

        it 'returns a 404 status if the coupon does not belong to the specified merchant' do
            tsStore = Merchant.create!(name: 'Taylor Swift Store')
            tsErasStore = Merchant.create!(name: 'Eras Tour Store')
            erasCoupon = Coupon.create!(
                name: "$10 off",
                code: "10OFF",
                discount_type: "dollar",
                discount_value: 10,
                status: true,
                merchant_id: tsErasStore.id
            )

            get "/api/v1/merchants/#{tsStore.id}/coupons/#{erasCoupon.id}"
            json_response = JSON.parse(response.body, symbolize_names: true)
        
            expect(response).to have_http_status(:not_found)
            expect(json_response[:error]).to eq("Coupon not found")
        end
    end

    describe 'POST /api/v1/merchants/:merchant_id/coupons' do
        it 'creates a new coupon for a merchant' do
            tsStore = Merchant.create!(name: 'Taylor Swift Store')
            coupon_params = {
                coupon: {
                    name: '25 Percent',
                    code: '25PERCENT',
                    discount_type: 'percent',
                    discount_value: 25,
                    status: true
                }
            }

            post "/api/v1/merchants/#{tsStore.id}/coupons", params: coupon_params
    
            json_response = JSON.parse(response.body, symbolize_names: true)[:data]
    
            expect(response).to have_http_status(:created)
            expect(json_response[:type]).to eq("coupon")
            expect(json_response[:attributes][:name]).to eq("25 Percent")
            expect(json_response[:attributes][:code]).to eq("25PERCENT")
            expect(json_response[:attributes][:discount_type]).to eq("percent")
            expect(json_response[:attributes][:discount_value]).to eq(25)
            expect(json_response[:attributes][:status]).to be true
        end

        it 'returns an error if a coupon code is not unique' do
            tsStore = Merchant.create!(name: 'Taylor Swift Store')
            itsACoupon = Coupon.create!(
                name: "$10 off",
                code: "10OFF",
                discount_type: "dollar",
                discount_value: 10,
                status: true,
                merchant_id: tsStore.id
            )

            coupon_params = {
                coupon: {
                    name: "10 Percent off",
                    code: "10OFF",
                    discount_type: "percent",
                    discount_value: 10,
                    status: true,
                    merchant_id: tsStore.id
                }
            }

            post "/api/v1/merchants/#{tsStore.id}/coupons", params: coupon_params
    
            json_response = JSON.parse(response.body, symbolize_names: true)
    
            expect(response).to have_http_status(:unprocessable_entity)
            expect(json_response[:error]).to eq("Code has already been taken")
        end    
    end

    describe 'PATCH /api/v1/merchants/:merchant_id/coupons/:id' do
        it 'deactivates the coupon and returns the updated coupon' do
            tsStore = Merchant.create!(name: 'Taylor Swift Store')
            tsCoupon = Coupon.create!(
                name: "50Percent",
                code: "50PERCENT",
                discount_type: "percent",
                discount_value: 50,
                status: true,
                merchant_id: tsStore.id
            )

            patch "/api/v1/merchants/#{tsStore.id}/coupons/#{tsCoupon.id}",
            params: { coupon: { status: false } }

            json_response = JSON.parse(response.body, symbolize_names: true)[:data]

            expect(response).to have_http_status(:ok)

            expect(json_response[:attributes][:status]).to eq(false)
            expect(json_response[:attributes][:name]).to eq(tsCoupon.name)
        end

        it 'returns a 404 status if the coupon does not exist' do
            tsStore = Merchant.create!(name: 'Taylor Swift Store')

            patch "/api/v1/merchants/#{tsStore.id}/coupons/28" 

            json_response = JSON.parse(response.body, symbolize_names: true)

            expect(response).to have_http_status(:not_found)
            expect(json_response[:error]).to eq('Coupon not found')
        end
    end
end
