FactoryGirl.define do

  factory :funding_source do
    name "Test Funding Source"
    description "Test Funding Source Description"
    funding_source_type_id 1
    active true
  end
end
