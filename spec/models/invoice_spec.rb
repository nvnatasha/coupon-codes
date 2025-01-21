require "rails_helper"

RSpec.describe Invoice do
  describe 'associations and validations' do
    it { should belong_to :merchant }
    it { should belong_to :customer }
    it { should validate_inclusion_of(:status).in_array(%w(shipped packaged returned)) }
  end

    it 'creates a valid invoice with an associated merchant, customer, and coupon' do
      tsStore = Merchant.create!(name: "Taylor Swift Store")
      tsCoupon = Coupon.create!(
        name: '$10 off',
        code: '10OFF',
        discount_type: 'dollar',
        discount_value: 10,
        merchant_id: tsStore.id
      )
      chrissy = Customer.create!(
        first_name: 'Chrissy',
        last_name: 'Karrmann'
      )
      invoice = Invoice.create!(
        merchant_id: tsStore.id,
        customer_id: chrissy.id,
        coupon_id: tsCoupon.id,
        status: 'shipped'
      )

      expect(invoice).to be_valid 
      expect(invoice.merchant_id).to eq(tsStore.id)
      expect(invoice.coupon_id).to eq(tsCoupon.id)
      expect(invoice.customer_id).to eq(chrissy.id)
    end

    it 'creates a valid invoice without a coupon' do
      tsStore = Merchant.create!(name: "Taylor Swift Store")
      chrissy = Customer.create!(
        first_name: 'Chrissy',
        last_name: 'Karrmann'
      )
      invoice = Invoice.create!(
        merchant_id: tsStore.id,
        customer_id: chrissy.id,
        status: 'shipped'
      )

      expect(invoice).to be_valid
      expect(invoice.coupon).to be_nil
    end

    it 'associates a coupon with the invoice' do
      tsStore = Merchant.create!(name: "Taylor Swift Store")
      tsCoupon = Coupon.create!(
        name: '$10 off',
        code: '10OFF',
        discount_type: 'dollar',
        discount_value: 10,
        merchant_id: tsStore.id
      )
      chrissy = Customer.create!(
        first_name: 'Chrissy',
        last_name: 'Karrmann'
      )
      invoice = Invoice.create!(
        merchant_id: tsStore.id,
        customer_id: chrissy.id,
        coupon_id: tsCoupon.id,
        status: 'shipped'
      )

      expect(invoice.coupon).to eq(tsCoupon)
      expect(invoice.coupon.merchant).to eq(tsStore)
    end

    it 'is invalid without a merchant' do
      tsStore = Merchant.create!(name: "Taylor Swift Store")
      tsCoupon = Coupon.create!(
        name: '$10 off',
        code: '10OFF',
        discount_type: 'dollar',
        discount_value: 10,
        merchant_id: tsStore.id
      )
      chrissy = Customer.create!(
        first_name: 'Chrissy',
        last_name: 'Karrmann'
      )
      invoice = Invoice.create(
        customer_id: chrissy.id,
        coupon_id: tsCoupon.id,
        status: 'shipped'
      )

      expect(invoice).to_not be_valid
      expect(invoice.errors[:merchant]).to include('must exist')
    end
end