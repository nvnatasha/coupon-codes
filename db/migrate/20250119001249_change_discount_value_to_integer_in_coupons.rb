class ChangeDiscountValueToIntegerInCoupons < ActiveRecord::Migration[7.1]
  def change
    change_column :coupons, :discount_value, :integer, using: 'discount_value::integer'
  end
end
