class Api::V1::CouponsController < ApplicationController
rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity

    def index
        merchant = Merchant.find(params[:merchant_id])

        if params[:status].present?

            params[:status] == 'true' || params[:status] == 'false'
            status = ActiveModel::Type::Boolean.new.cast(params[:status])
                
            coupons = merchant.coupons.where(status: status)

        else
            coupons = merchant.coupons
        end

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
        render json: CouponSerializer.format_coupon(coupon), status: :created
    end



    def update
        merchant = Merchant.find(params[:merchant_id])
        coupon = merchant.coupons.find(params[:id])
        status = ActiveModel::Type::Boolean.new.cast(params[:status]) 

        if coupon.invoices.where(status: 'packaged').exists?
            render json: { error: 'Cannot deactivate coupon with pending invoices' }, status: :unprocessable_entity
            return
        end
    
        if status
            if coupon.status
                render json: { error: 'Coupon is already active' }, status: :bad_request
            else
                coupon.activate!
                render json: CouponSerializer.format_coupon(coupon), status: :ok
            end
        else
            if !coupon.status
                render json: { error: 'Coupon is already inactive' }, status: :bad_request
            else
                coupon.deactivate!
                render json: CouponSerializer.format_coupon(coupon), status: :ok
            end
        end
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
        render json: { error: "Code has already been taken" }, status: :unprocessable_entity
    end

end