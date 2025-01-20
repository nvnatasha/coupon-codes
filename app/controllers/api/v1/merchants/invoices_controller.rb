class Api::V1::Merchants::InvoicesController < ApplicationController
rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def index
    invoices = Invoice.filter(params)
    render json: InvoiceSerializer.new(invoices)
  end

  private

  def invoice_params
    params.require(:invoice.permit(:status, :merchant_id, :customer_id)

  def record_not_found
    render json: { error.message }, status: :not_found
  end
end