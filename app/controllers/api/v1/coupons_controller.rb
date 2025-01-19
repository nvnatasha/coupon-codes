class Api::V1::CouponsController < ApplicationController

    def index
        merchant = Merchant.find(params[:merchant_id])
        coupons = merchant.coupons
        render json: CouponSerializer.format_coupons(coupons)
    end

    def show
        merchant = Merchant.find(params[:merchant_id])
        coupon = merchant.coupons.find(params[:id])
        render json: CouponSerializer.format_coupon(coupon)
    end

    def create
        merchant = Merchant.find(params[:merchant_id])
        coupon = merchant.coupons.create!(coupon_params)

        render json: CouponSerializer.format_coupon(coupon)
    end

    def update
        merchant = Mercchant.find(params[:merchant_id])
        coupon = merchant.coupons.find(params[:id])

        coupon.update!(coupon_params)
        render json: CouponSerializer.format_coupon(coupon)
    end

    def destroy
        merchant = Merchant.find(params[:merchant_id])
        coupon = merchant.coupons.find(params[:id])
        coupon.destroy
        head :no_content
    end

    private

    def coupon_params 
        params.require(:coupon).permit(:name, :code, :discount_type, :discount_value, :status, :merchant_id)
    end
end