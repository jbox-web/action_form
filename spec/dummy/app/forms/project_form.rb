# frozen_string_literal: true

class ProjectForm < ActionForm::Base
  attribute :name
  attribute :description
  attribute :owner_id

  association :tasks do
    attribute :name
    attribute :description
    attribute :done

    association :sub_tasks do
      attribute :name
      attribute :description
      attribute :done
    end
  end

  association :contributors, records: 2 do
    attribute :name
    attribute :description
    attribute :role
  end

  association :project_tags do
    attribute :tag_id

    association :tag do
      attribute :name
    end
  end

  association :owner do
    attribute :name
    attribute :description
    attribute :role
  end
end
