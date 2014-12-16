class WorkflowCreateSchema < JsonSchema
  schema do
    type "object"
    description "A Description of a Classification Workflow"
    required "primary_language", "display_name", "links"

    additional_properties false

    property "primary_language" do
      type "string"
    end

    property "pairwise" do
      type "boolean"
    end

    property "grouped" do
      type "boolean"
    end
    
    property "prioritized" do
      type "boolean"
    end

    property "display_name" do
      type "string"
    end

    property "first_task" do
      type "string"
    end

    property "tasks" do
      type "object"
    end

    property "links" do
      type "object"
      required "project"

      property "project" do
        type "string", "integer"
      end

      property "tutorial_subject" do
        type "string", "integer"
      end

      property "subject_sets" do
        type "array"

        items do
          type "string", "integer"
        end
      end
    end
  end
end