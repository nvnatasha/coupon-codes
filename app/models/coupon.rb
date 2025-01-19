class Coupon < ApplicationRecord
    belongs_to :merchant
    has_many :invoices

    validates :name, presence: true
    validates :code, presence: true, uniqueness: true
    validates :discount_type, inclusion: { in: ["percent", "dollar"]}
    validates :discount_value, presence: true, numericality: { greater_than: 0 }
    validates :merchant, presence:{ message: "must exist" }
    validates :status, presence: true

    def self.active
        where(status: true)
    end
    
    def self.inactive
        where(status: false)
    end

    def use_count
        invoices.count
    end
end