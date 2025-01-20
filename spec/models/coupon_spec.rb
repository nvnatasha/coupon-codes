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

        it 'requires a discount value greater than zero' do
            tsStore = Merchant.create!(name: "Taylor Swift Store")
            tsCoupon = Coupon.create(
                name: '$10 off',
                code: '10OFF',
                discount_type: 'dollar',
                discount_value: -10,
                merchant_id: tsStore.id
            )

            expect(tsCoupon).to be_invalid
            expect(tsCoupon.errors[:discount_value]).to include("must be greater than 0")
        end

        it 'creates a new active coupon if a merchant has less than five' do
            tsStore = Merchant.create!(name: "Taylor Swift Store")
            tsCoupon = Coupon.create(
                name: '$10 off',
                code: '10OFF',
                discount_type: 'dollar',
                discount_value: 10,
                merchant_id: tsStore.id
            )
            expect(tsCoupon).to be_valid
        end

        it 'returns only active coupons' do
            tsStore = Merchant.create!(name: "Taylor Swift Store")
            tsCoupon = Coupon.create(
                name: '$10 off',
                code: '10OFF',
                discount_type: 'dollar',
                discount_value: 10,
                status: true,
                merchant_id: tsStore.id
            )
            erasCoupon = Coupon.create(
                name: '10 Percent',
                code: '10PERCENT',
                discount_type: 'percent',
                discount_value: 10,
                status: false,
                merchant_id: tsStore.id
            )

            expect(Coupon.active).to include(tsCoupon)
            expect(Coupon.active).to_not include(erasCoupon)
        end

        it 'returns only inactive coupons' do
            tsStore = Merchant.create!(name: "Taylor Swift Store")
            tsCoupon = Coupon.create(
                name: '$10 off',
                code: '10OFF',
                discount_type: 'dollar',
                discount_value: 10,
                status: true,
                merchant_id: tsStore.id
            )
            erasCoupon = Coupon.create(
                name: '10 Percent',
                code: '10PERCENT',
                discount_type: 'percent',
                discount_value: 10,
                status: false,
                merchant_id: tsStore.id
            )

            expect(Coupon.inactive).to include(erasCoupon)
            expect(Coupon.inactive).to_not include(tsCoupon)
        end

        it 'cannot create a valid 6th active coupon for a single merchant' do
            tsStore = Merchant.create!(name: "Taylor Swift Store")
            5.times do |i|
            Coupon.create(
                name: "TS#{i + 1}",
                code: "TAYLOR#{i + 1}",
                discount_type: "dollar",
                discount_value: 10,
                status: true,
                merchant_id: tsStore.id
            )
            end

            erasCoupon = Coupon.create(
                name: 'Eras Coupon',
                code: 'ERAS',
                discount_type: "dollar",
                discount_value: 25,
                status: true,
                merchant_id: tsStore.id
            )

            expect(erasCoupon.errors[:base]).to include("Merchant cannot have more than 5 active coupons")
        end
    end
end