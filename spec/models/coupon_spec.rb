require 'rails_helper'

RSpec.describe Coupon, type: :model do
    describe 'validations' do
        it 'creates a valid coupon' do
            tsStore = Merchant.create!(name: "Taylor Swift Store")
            tsCoupon = Coupon.create!(
                name: '$10 off',
                code: '10OFF',
                discount_type: 'dollar',
                discount_value: 10,
                merchant_id: tsStore.id
            )

            expect(tsCoupon).to be_valid 
        end

        it 'requires a name to create a valid coupon' do
            tsStore = Merchant.create!(name: "Taylor Swift Store")
            tsCoupon = Coupon.create(
                code: '10OFF',
                discount_type: 'dollar',
                discount_value: 10,
                merchant_id: tsStore.id
            )

            expect(tsCoupon).to be_invalid
            expect(tsCoupon.errors[:name]).to include("can't be blank")
        end

        it 'requires a code to create a valid coupon' do
            tsStore = Merchant.create!(name: "Taylor Swift Store")
            tsCoupon = Coupon.create(
                name: '$10 off',
                discount_type: 'dollar',
                discount_value: 10,
                merchant_id: tsStore.id
            )

            expect(tsCoupon).to be_invalid
            expect(tsCoupon.errors[:code]).to include("can't be blank")
        end

        it 'requires a discount type to create a valid coupon' do
            tsStore = Merchant.create!(name: "Taylor Swift Store")
            tsCoupon = Coupon.create(
                name: '$10 off',
                code: '10OFF',
                discount_value: 10,
                merchant_id: tsStore.id
            )

            expect(tsCoupon).to be_invalid
            expect(tsCoupon.errors[:discount_type]).to include("can't be blank")
        end

        it 'requires a discount value to create a valid coupon' do
            tsStore = Merchant.create!(name: "Taylor Swift Store")
            tsCoupon = Coupon.create(
                name: '$10 off',
                code: '10OFF',
                discount_type: 'dollar',
                merchant_id: tsStore.id
            )

            expect(tsCoupon).to be_invalid
            expect(tsCoupon.errors[:discount_value]).to include("can't be blank")
        end

        it 'requires a merchant to create a valid coupon' do
            tsCoupon = Coupon.create(
                name: '$10 off',
                code: '10OFF',
                discount_type: 'dollar',
                discount_value: 10
            )

            expect(tsCoupon).to be_invalid
            expect(tsCoupon.errors[:merchant]).to include("must exist")
        end

        it 'requires a unique coupon code' do
            tsStore = Merchant.create!(name: "Taylor Swift Store")
            anotherStore = Merchant.create(name: 'Another Swiftie Store')
            tsCoupon = Coupon.create(
                name: '$10 off',
                code: '10OFF',
                discount_type: 'dollar',
                discount_value: 10,
                merchant_id: tsStore.id
            )
            anotherCoupon = Coupon.create(
                name: 'Holiday Sale',
                code: '10OFF',
                discount_type: 'dollar',
                discount_value: 10,
                merchant_id: anotherStore.id
            )

            expect(anotherCoupon).to be_invalid
            expect(anotherCoupon.errors[:code]).to include("has already been taken")
        end
    end
end