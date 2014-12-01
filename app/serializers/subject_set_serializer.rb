class SubjectSetSerializer
  include RestPack::Serializer
  attributes :id, :display_name, :set_member_subjects_count,
             :created_at, :updated_at
  can_include :project, :workflows
end
