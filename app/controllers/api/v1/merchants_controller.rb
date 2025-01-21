class Api::V1::MerchantsController < ApplicationController

  def index
    merchants = Merchant.all 

    if params[:sorted].present? && params[:sorted] == "age"
      merchants = merchants.sorted_by_creation
    end
    if params[:status].present?
      merchants = Merchant.filter_by_status(params[:status])
    end

    include_count = params[:count].present? && params[:count] == "true"

    if include_count
      render json: MerchantSerializer.new(merchants, { params: { count: include_count }})
    else
      render json: {
        data: merchants.map do|merchant| 
        {
          id: merchant.id,
          type: 'merchant',
          attributes: {
            name: merchant.name,
            coupons_count: merchant.coupons_count,
            invoice_coupon_count: merchant.invoice_coupon_count
          }
        }
      end
    }
    end
  end

  def show
    merchant = Merchant.find(params[:id])
    render json: MerchantSerializer.new(merchant)
  end

  def create
    merchant = Merchant.create!(merchant_params) # safe to use create! here because our exception handler will gracefully handle exception
    render json: MerchantSerializer.new(merchant), status: :created
  end

  def update
    merchant = Merchant.find(params[:id])
    merchant.update!(merchant_params)

    render json: MerchantSerializer.new(merchant)
  end

  def destroy
    merchant = Merchant.find(params[:id])
    merchant.destroy
  end

  private

  def merchant_params
    params.permit(:name)
  end

  # def coupons_with_status(merchant)
  #   status = params[:status]
  #   merchant.coupons_filtered_by_status(status).map do |coupon|
  #     {
  #       id: coupon.id,
  #       name: coupon.name,
  #       code: coupon.code,
  #       discount_type: coupon.discount_type,
  #       discount_value: coupon.discount_value,
  #       status: coupon.active ? 'active' : 'inactive'
  #     }
  #   end
  # end
end
