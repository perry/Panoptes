# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_subject_queue do
    user
    workflow
    subject_ids []
  end
end
