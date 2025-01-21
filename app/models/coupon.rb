class Coupon < ApplicationRecord
    belongs_to :merchant
    has_many :invoices

    validates :name, presence: true
    validates :code, presence: true, uniqueness: true
    validates :discount_type, presence: true, inclusion: { in: ["percent", "dollar"]}
    validates :discount_value, presence: true, numericality: { greater_than: 0 }
    validates :merchant, presence:{ message: "must exist" }
    validate :active_coupon_limit, on: :create

    def self.active
        where(status: true)
    end
    
    def self.inactive
        where(status: false)
    end

    def use_count
        invoices.count
    end

    def activate!
        update(status: true)
    end

    def deactivate!
        update(status: false)
    end

    def active_coupon_limit
        return if merchant.nil?

        if merchant.coupons.active.count >= 5
            errors.add(:base, "Merchant cannot have more than 5 active coupons")
        end
    
    end
end