class Invoice < ApplicationRecord
  belongs_to :customer
  belongs_to :merchant
  belongs_to :coupon, optional: true
  has_many :invoice_items, dependent: :destroy
  has_many :transactions, dependent: :destroy

  validates :status, inclusion: { in: ["shipped", "packaged", "returned"] }
  validates :merchant, :customer, :status, presence: true


  def self.filter(params)
    merchant = Merchant.find(params[:merchant_id])
    if params.include?(:status)
      invoices = Invoice.where(merchant_id: params[:merchant_id], status: params[:status])
    else 
      invoices = Invoice.where(merchant_id: params[:merchant_id])
    end
  end

  def self.by_merchant(merchant_id)
    where(merchant_id: merchant_id)
  end

  def self.by_customer(customer_id)
    where(customer_id: customer_id)
  end
end