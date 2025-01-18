class Api::V1::CouponsController < ApplicationController

    def index
        merchant = Merchant.find(params[:merchant_id])
        coupons = merchant.coupons
        render json: CouponsSerializer.format_coupons(coupons)
    end

    def show
        merchant = Merchant.find(params[:merchant_id])
        coupon = merchant.coupons.find(params[:id])
        render json: CouponsSerializer.format_coupon(coupon)
    end

    def create
        merchant = Merchant.find(params[:merchant_id])
        coupon = merchant.coupons.create!(coupon_params)
    end

    def update
        merchant = Mercchant.find(params[:merchant_id])
        coupon = merchant.coupons.find(params[:id])

        coupon.update!(coupon_params)
        render json: CouponsSerializer.format_coupon(coupon)
    end

    def destroy
        merchant = Merchant.find(params[:merchant_id])
        coupon = merchant.coupons.find(params[:id])
        coupon.destroy
        head :no_content
    end

    private

    def coupon_params 
        params.require(:coupon).permie(:name, :code, :discount_type, :discount_value, :status)
    end
end