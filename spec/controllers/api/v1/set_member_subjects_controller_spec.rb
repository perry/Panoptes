require 'spec_helper'

RSpec.describe Api::V1::SetMemberSubjectsController, type: :controller do
  let(:authorized_user) { create(:user) }
  let(:subject_set) { create(:subject_set, project: create(:project, owner: authorized_user)) }
  let!(:set_member_subjects) { create_list(:set_member_subject, 2, state: "active", subject_set: subject_set) }
  let(:api_resource_name) { 'set_member_subjects' }
  let(:api_resource_attributes) { %w(id state priority) }
  let(:api_resource_links) { %w(set_member_subjects.subject set_member_subjects.subject_set) }

  let(:scopes) { %w(public project) }
  let(:resource) { set_member_subjects.first }
  let(:resource_class) { SetMemberSubject }

  describe "#index" do
    let!(:private_resource) do
      ss = create(:subject_set, project: create(:project, private: true))
      create(:set_member_subject, subject_set: ss)
    end
    
    let(:n_visible) { 2 }

    it_behaves_like "is indexable"
  end

  describe "#show" do
    it_behaves_like "is showable"
  end

  describe "#update" do
    let(:test_attr) { :state }
    let(:test_attr_value) { "retired" }
    let(:update_params) do
      { set_member_subjects: { state: "retired" } }
    end

    it_behaves_like "is updatable"
  end

  describe "#create" do
    let(:test_attr) { :state }
    let(:test_attr_value) { "active" }
    let(:create_params) do
      {
        set_member_subjects: {
          links: {
            subject: create(:subject).id.to_s,
            subject_set: subject_set.id.to_s
          }
        }
      }
    end

    it_behaves_like "is creatable"
  end

  describe "#destroy" do
    it_behaves_like "is destructable"
  end
end
