class Api::V1::CouponsController < ApplicationController
rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity

    def index
        merchant = Merchant.find(params[:merchant_id])
        coupons = merchant.coupons
        render json: CouponSerializer.format_coupons(coupons), status: :ok
    end

    def show
        merchant = Merchant.find(params[:merchant_id])
        coupon = merchant.coupons.find(params[:id])
        render json: CouponSerializer.format_coupon(coupon), status: :ok
    end

    def create
        merchant = Merchant.find(params[:merchant_id])
        coupon = merchant.coupons.create!(coupon_params)

        coupon.save
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
        params.require(:coupon).permit(:name, :code, :discount_type, :discount_value, :status)
    end

    def record_not_found(error)
        if error.message.include?("Merchant")
            render json: { error: "Merchant not found" }, status: :not_found
        else 
            render json: { error: "Coupon not found" }, status: :not_found
        end
    end

    def unprocessable_entity(error)
        render json: { error: message }, status: :unprocessable_entity
    end

end