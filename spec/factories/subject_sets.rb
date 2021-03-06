FactoryGirl.define do
  factory :subject_set do
    display_name "A Subject set"
    metadata({ just_some: "stuff" })
    project
    workflow
    retired_set_member_subjects_count 0

    factory :subject_set_with_subjects do
      after(:create) do |sg|
        create_list(:set_member_subject, 2, subject_set: sg)
      end
    end
  end
end
