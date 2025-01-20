FactoryBot.define do
    factory :coupon do
        name { '$10 Off' }
        code { '10OFF' }
        discount_value { 10 }
        discount_type { 'dollar' }
        status { true }
        association :merchant 
    end
end