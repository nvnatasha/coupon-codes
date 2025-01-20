require 'rails_helper'

describe Merchant, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name)}
  end

  describe 'relationships' do
    it { should have_many :items }
    it { should have_many :invoices }
    it { should have_many(:customers).through(:invoices) }
    it { should have_many :coupons }
  end

  describe "class methods" do
    it "should sort merchants by created_at" do
      merchant1 = create(:merchant, created_at: 1.day.ago)
      merchant2 = create(:merchant, created_at: 4.days.ago)
      merchant3 = create(:merchant, created_at: 2.days.ago)

      expect(Merchant.sorted_by_creation).to eq([merchant1, merchant3, merchant2])
    end

    it "should filter merchants by status of invoices" do
      merchant1 = create(:merchant)
      merchant2 = create(:merchant)
      customer = create(:customer)
      create(:invoice, status: "returned", merchant_id: merchant1.id, customer_id: customer.id)
      create_list(:invoice, 5, merchant_id: merchant1.id, customer_id: customer.id)
      create_list(:invoice, 5, merchant_id: merchant2.id, customer_id: customer.id)
      create(:invoice, status: "packaged", merchant_id: merchant2.id, customer_id: customer.id)

      expect(Merchant.filter_by_status("returned")).to eq([merchant1])
      expect(Merchant.filter_by_status("packaged")).to eq([merchant2])
      expect(Merchant.filter_by_status("shipped")).to match_array([merchant1, merchant2])
    end

    it "should retrieve merchant when searching by name" do
      merchant1 = Merchant.create!(name: "Turing")
      merchant2 = Merchant.create!(name: "ring world")
      merchant3 = Merchant.create!(name: "Vera Wang")

      expect(Merchant.find_one_merchant_by_name("ring")).to eq(merchant2)
      expect(Merchant.find_all_by_name("ring")).to eq([merchant1, merchant2])
    end
  end

  describe "instance methods" do
    it "#item_count should return the count of items for a merchant" do
      merchant = Merchant.create!(name: "My merchant")
      merchant2 = Merchant.create!(name: "My other merchant")

      # These FactoryBot methods create lots of test data quickly with random attributes
      # The line below is the equivalent of running `merchant.items.create!` 8 times
      # In your new tests, you do not need to use FactoryBot unless you'd like to explore it
      create_list(:item, 8, merchant_id: merchant.id)
      create_list(:item, 4, merchant_id: merchant2.id)

      expect(merchant.item_count).to eq(8)
      expect(merchant2.item_count).to eq(4)
    end

    it "#distinct_customers should return all customers for a merchant" do
      merchant1 = create(:merchant)
      customer1 = create(:customer)
      customer2 = create(:customer)
      customer3 = create(:customer)

      merchant2 = create(:merchant)

      create_list(:invoice, 3, merchant_id: merchant1.id, customer_id: customer1.id)
      create_list(:invoice, 2, merchant_id: merchant1.id, customer_id: customer2.id)

      create_list(:invoice, 2, merchant_id: merchant2.id, customer_id: customer3.id)

      expect(merchant1.distinct_customers).to match_array([customer1, customer2])
      expect(merchant2.distinct_customers).to eq([customer3])
    end

    it "#invoices_filtered_by_status should return all invoices for a customer that match the given status" do
      merchant = create(:merchant)
      other_merchant = create(:merchant)
      customer = create(:customer)
      inv_1_shipped = Invoice.create!(status: "shipped", merchant: merchant, customer: customer)
      inv_2_shipped = Invoice.create!(status: "shipped", merchant: merchant, customer: customer)
      inv_3_packaged = Invoice.create!(status: "packaged", merchant: merchant, customer: customer)
      inv_4_packaged = Invoice.create!(status: "packaged", merchant: other_merchant, customer: customer)
      inv_5_returned = Invoice.create!(status: "returned", merchant: merchant, customer: customer)

      expect(merchant.invoices_filtered_by_status("shipped")).to match_array([inv_1_shipped, inv_2_shipped])
      expect(merchant.invoices_filtered_by_status("packaged")).to eq([inv_3_packaged])
      expect(merchant.invoices_filtered_by_status("returned")).to eq([inv_5_returned])
      expect(other_merchant.invoices_filtered_by_status("packaged")).to eq([inv_4_packaged])
    end
  end
  
  describe 'merchant coupons' do
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
  end
end
