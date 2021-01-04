require 'spec_helper'

RSpec.describe('ProjectForm') do

  fixtures(:projects, :tasks, :people)

  before do
    @project = Project.new
    @form = ProjectForm.new(@project)
    @tasks_form = @form.forms[0]
    @contributors_form = @form.forms[1]
    @project_tags_form = @form.forms[2]
    @owner_form = @form.forms[3]
    @model = @form
  end

  it("project form responds to attributes") do
    attributes = [:name, :name=, :description, :description=]
    attributes.each { |attribute| assert_respond_to(@form, attribute) }
  end

  it("declares collection association") do
    assert_respond_to(ProjectForm, :association)
  end

  it("forms list contains sub-form definitions") do
    expect(ProjectForm.forms.size).to(eq(4))
    tasks_definition = ProjectForm.forms[0]
    contributors_definition = ProjectForm.forms[1]
    project_tags_definition = ProjectForm.forms[2]
    owner_definition = ProjectForm.forms[3]
    expect(tasks_definition.assoc_name).to(eq(:tasks))
    expect(contributors_definition.assoc_name).to(eq(:contributors))
    expect(project_tags_definition.assoc_name).to(eq(:project_tags))
    expect(owner_definition.assoc_name).to(eq(:owner))
  end

  it("project form provides getter method for tasks sub-form") do
    expect(@tasks_form).to(be_instance_of(ActionForm::FormCollection))
  end

  it("project form provides getter method for contributors sub-form") do
    expect(@contributors_form).to(be_instance_of(ActionForm::FormCollection))
  end

  it("project form provides getter method for project_tags sub-form") do
    expect(@project_tags_form).to(be_instance_of(ActionForm::FormCollection))
  end

  it("project form provides getter method for owner sub-form") do
    expect(@owner_form).to(be_instance_of(ActionForm::Form))
  end

  it("tasks sub-form contains association name and parent") do
    expect(@tasks_form.association_name).to(eq(:tasks))
    expect(@tasks_form.records).to(eq(1))
    expect(@tasks_form.parent).to(eq(@project))
  end

  it("contributors sub-form contains association name and parent") do
    expect(@contributors_form.association_name).to(eq(:contributors))
    expect(@contributors_form.records).to(eq(2))
    expect(@contributors_form.parent).to(eq(@project))
  end

  it("project-tags sub-form contains association name and parent") do
    expect(@project_tags_form.association_name).to(eq(:project_tags))
    expect(@project_tags_form.records).to(eq(1))
    expect(@project_tags_form.parent).to(eq(@project))
  end

  it("owner sub-form contains association name and parent") do
    expect(@owner_form.association_name).to(eq(:owner))
    expect(@owner_form.parent).to(eq(@project))
  end

  it("#represents? returns true if the argument matches the Form's association name, false otherwise") do
    expect(@tasks_form.represents?("tasks")).to(eq(true))
    expect(@tasks_form.represents?("task")).to(eq(false))
    expect(@contributors_form.represents?("contributors")).to(eq(true))
    expect(@contributors_form.represents?("contributor")).to(eq(false))
    expect(@project_tags_form.represents?("project_tags")).to(eq(true))
    expect(@project_tags_form.represents?("project_tag")).to(eq(false))
    expect(@owner_form.represents?("owner")).to(eq(true))
    expect(@owner_form.represents?("person")).to(eq(false))
  end

  it("project form provides getter method for task objects") do
    assert_respond_to(@form, :tasks)
    tasks = @form.tasks
    tasks.each do |form|
      expect(form).to(be_instance_of(ActionForm::Form))
      expect(form.model).to(be_instance_of(Task))
    end
  end

  it("project form provides getter method for contributor objects") do
    assert_respond_to(@form, :contributors)
    contributors = @form.contributors
    contributors.each do |form|
      expect(form).to(be_instance_of(ActionForm::Form))
      expect(form.model).to(be_instance_of(Person))
    end
  end

  it("project form provides getter method for project_tag objects") do
    assert_respond_to(@form, :project_tags)
    project_tags = @form.project_tags
    project_tags.each do |form|
      expect(form).to(be_instance_of(ActionForm::Form))
      expect(form.model).to(be_instance_of(ProjectTag))
    end
  end

  it("project form provides getter method for owner object") do
    assert_respond_to(@form, :owner)
    owner = @form.owner
    expect(owner).to(be_instance_of(ActionForm::Form))
    expect(owner.model).to(be_instance_of(Person))
  end

  it("project form initializes the number of records specified for tasks") do
    assert_respond_to(@tasks_form, :models)
    expect(@tasks_form.models.size).to(eq(1))
    @tasks_form.each do |form|
      expect(form).to(be_instance_of(ActionForm::Form))
      expect(form.model).to(be_instance_of(Task))
      expect(form.model.new_record?).to(eq(true))
      assert_respond_to(form, :name)
      assert_respond_to(form, :name=)
      assert_respond_to(form, :description)
      assert_respond_to(form, :description=)
      assert_respond_to(form, :done)
      assert_respond_to(form, :done=)
    end
    expect(@form.model.tasks.size).to(eq(1))
  end

  it("project form initializes the number of records specified for contributors") do
    assert_respond_to(@contributors_form, :models)
    expect(@contributors_form.models.size).to(eq(2))
    @contributors_form.each do |form|
      expect(form).to(be_instance_of(ActionForm::Form))
      expect(form.model).to(be_instance_of(Person))
      expect(form.model.new_record?).to(eq(true))
      assert_respond_to(form, :name)
      assert_respond_to(form, :name=)
      assert_respond_to(form, :role)
      assert_respond_to(form, :role=)
      assert_respond_to(form, :description)
      assert_respond_to(form, :description=)
    end
    expect(@form.model.contributors.size).to(eq(2))
  end

  it("project form initializes the number of records specified for project_tags") do
    assert_respond_to(@project_tags_form, :models)
    expect(@project_tags_form.models.size).to(eq(1))
    @project_tags_form.each do |form|
      expect(form).to(be_instance_of(ActionForm::Form))
      expect(form.model).to(be_instance_of(ProjectTag))
      expect(form.model.new_record?).to(eq(true))
      assert_respond_to(form, :tag_id)
      assert_respond_to(form, :tag_id=)
    end
    expect(@form.model.project_tags.size).to(eq(1))
  end

  it("project_tags sub-form declares the tag sub-form") do
    expect(@project_tags_form.forms.size).to(eq(1))
    tag_form = @project_tags_form.models[0].tag
    expect(tag_form).to(be_instance_of(ActionForm::Form))
    expect(tag_form.association_name).to(eq(:tag))
    expect(tag_form.parent).to(be_instance_of(ProjectTag))
    expect(tag_form.model).to(be_instance_of(Tag))
    assert_respond_to(tag_form, :name)
    assert_respond_to(tag_form, :name=)
  end

  it("reject owner if attributes are all blank") do
    project = Project.new
    project_form = ProjectForm.new(project)
    params = { :name => "Add Form Models", :description => "Google Summer of Code 2014", :owner_attributes => ({ :name => "", :role => "", :description => "" }) }
    project_form.submit(params)
    expect { project_form.save }.to(change { Project.count })
    expect(project_form.model.owner).to(be_nil)
  end

  it("reject contributor if attributes are all blank") do
    project = Project.new
    project_form = ProjectForm.new(project)
    params = { :name => "Add Form Models", :description => "Google Summer of Code 2014", :contributors_attributes => ({ "0" => ({ :name => "Peter Markou", :role => "Rails GSoC student", :description => "Working on adding Form Models" }), "1" => ({ :name => "", :role => "", :description => "" }) }) }
    project_form.submit(params)
    expect { project_form.save }.to(change { Project.count })
    expect(project_form.model.contributors.size).to(eq(1))
  end

  it("create new project with new tag") do
    project = Project.new
    project_form = ProjectForm.new(project)
    params = { :name => "Add Form Models", :description => "Google Summer of Code 2014", :project_tags_attributes => ({ "0" => ({ :tag_attributes => ({ :name => "Html Forms" }) }) }) }
    project_form.submit(params)
    expect { project_form.save }.to(change { Project.count })
    expect(project_form.name).to(eq("Add Form Models"))
    expect(project_form.description).to(eq("Google Summer of Code 2014"))
    expect(project_form.project_tags.size).to(eq(1))
    expect(project_form.project_tags[0].tag.name).to(eq("Html Forms"))
  end

  it("create new project with existing tag") do
    ProjectTag.delete_all
    Tag.delete_all
    tag = Tag.create(:name => "Html Forms")
    project = Project.new
    project_form = ProjectForm.new(project)
    params = { :name => "Add Form Models", :description => "Google Summer of Code 2014", :project_tags_attributes => ({ "0" => ({ :tag_id => tag.id }) }) }
    project_form.submit(params)
    expect { project_form.save }.to(change { Project.count })
    expect(project_form.name).to(eq("Add Form Models"))
    expect(project_form.description).to(eq("Google Summer of Code 2014"))
    expect(project_form.project_tags.size).to(eq(1))
    expect(project_form.project_tags[0].tag.name).to(eq("Html Forms"))
  end

  it("update existing project with new tag") do
    project = Project.create(:name => "Add Form Models", :description => "Google Summer of Code 2014")
    project_form = ProjectForm.new(project)
    params = { :project_tags_attributes => ({ "0" => ({ :tag_attributes => ({ :name => "Html Forms" }) }) }) }
    project_form.submit(params)
    expect { project_form.save }.to(change { Project.count }.by(0))
    expect(project_form.name).to(eq("Add Form Models"))
    expect(project_form.description).to(eq("Google Summer of Code 2014"))
    expect(project_form.project_tags.size).to(eq(1))
    expect(project_form.project_tags[0].tag.name).to(eq("Html Forms"))
  end

  it("update existing project with existing tag") do
    tag = Tag.create(:name => "Html Forms")
    project = Project.create(:name => "Form Models", :description => "Google Summer of Code 2014")
    project_form = ProjectForm.new(project)
    params = { :name => "Add Form Models", :project_tags_attributes => ({ "0" => ({ :tag_id => tag.id }) }) }
    project_form.submit(params)
    expect { project_form.save }.to(change { Project.count }.by(0))
    expect(project_form.name).to(eq("Add Form Models"))
    expect(project_form.description).to(eq("Google Summer of Code 2014"))
    expect(project_form.project_tags.size).to(eq(1))
    expect(project_form.project_tags[0].tag.name).to(eq("Html Forms"))
  end

  it("create new project with new owner") do
    project = Project.new
    project_form = ProjectForm.new(project)
    params = { :name => "Add Form Models", :description => "Nesting models in a single form", :owner_attributes => ({ :name => "Petros Markou", :role => "Rails GSoC student", :description => "Working on adding Form Models" }) }
    before_owner = project_form.owner.model
    expect(before_owner.new_record?).to(eq(true))
    expect(before_owner.name).to(be_nil)
    expect(before_owner.role).to(be_nil)
    expect(before_owner.description).to(be_nil)
    expect(project_form.model.owner).to(be_nil)
    project_form.submit(params)
    expect { project_form.save }.to(change { Project.count })
    expect(project_form.name).to(eq("Add Form Models"))
    expect(project_form.description).to(eq("Nesting models in a single form"))
    expect(project_form.model.owner).to_not(be_nil)
    expect(project_form.model.owner).to_not(eq(before_owner))
    expect(project_form.model.owner.name).to(eq("Petros Markou"))
    expect(project_form.model.owner.role).to(eq("Rails GSoC student"))
    expect(project_form.model.owner.description).to(eq("Working on adding Form Models"))
    expect(project_form.model.owner).to(eq(project_form.owner.model))
    expect(project_form.owner.name).to(eq("Petros Markou"))
    expect(project_form.owner.role).to(eq("Rails GSoC student"))
    expect(project_form.owner.description).to(eq("Working on adding Form Models"))
  end

  it("create new project with existing owner") do
    owner = Person.create(:name => "Carlos Silva", :role => "RoR Core Member", :description => "Mentoring Peter throughout GSoC")
    project = Project.new
    project_form = ProjectForm.new(project)
    params = { :name => "Add Form Models", :description => "Nesting models in a single form", :owner_id => owner.id }
    before_owner = project_form.owner.model
    expect(before_owner.new_record?).to(eq(true))
    expect(before_owner.name).to(be_nil)
    expect(before_owner.role).to(be_nil)
    expect(before_owner.description).to(be_nil)
    expect(project_form.model.owner).to(be_nil)
    project_form.submit(params)
    expect { project_form.save }.to(change { Project.count })
    expect(project_form.name).to(eq("Add Form Models"))
    expect(project_form.description).to(eq("Nesting models in a single form"))
    expect(project_form.model.owner).to_not(be_nil)
    expect(project_form.owner.model).to_not(eq(before_owner))
    expect(project_form.owner.name).to(eq("Carlos Silva"))
    expect(project_form.owner.role).to(eq("RoR Core Member"))
    expect(project_form.owner.description).to(eq("Mentoring Peter throughout GSoC"))
  end

  it("update project with new owner") do
    project = Project.create(:name => "Form Models", :description => "GSoC 2014")
    project_form = ProjectForm.new(project)
    params = { :name => "Add Form Models", :description => "Nesting models in a single form", :owner_attributes => ({ :name => "Carlos Silva", :role => "RoR Core Team", :description => "Mentoring Peter throughout GSoC" }) }
    project_form.submit(params)
    expect { project_form.save }.to(change { Project.count }.by(0))
    expect(project_form.name).to(eq("Add Form Models"))
    expect(project_form.description).to(eq("Nesting models in a single form"))
    expect(project_form.owner.name).to(eq("Carlos Silva"))
    expect(project_form.owner.role).to(eq("RoR Core Team"))
    expect(project_form.owner.description).to(eq("Mentoring Peter throughout GSoC"))
  end

  it("update project with existing owner") do
    owner = Person.create(:name => "Carlos Silva", :role => "RoR Core Member", :description => "Mentoring Peter throughout GSoC")
    project = Project.create(:name => "Form Models", :description => "GSoC 2014")
    project_form = ProjectForm.new(project)
    params = { :name => "Add Form Models", :description => "Nesting models in a single form", :owner_id => owner.id }
    project_form.submit(params)
    expect { project_form.save }.to(change { Project.count }.by(0))
    expect(project_form.name).to(eq("Add Form Models"))
    expect(project_form.description).to(eq("Nesting models in a single form"))
    expect(project_form.owner.name).to(eq("Carlos Silva"))
    expect(project_form.owner.role).to(eq("RoR Core Member"))
    expect(project_form.owner.description).to(eq("Mentoring Peter throughout GSoC"))
  end

  it("project form initializes the owner record") do
    expect(@owner_form.model.new_record?).to(eq(true))
    assert_respond_to(@owner_form, :name)
    assert_respond_to(@owner_form, :name=)
    assert_respond_to(@owner_form, :role)
    assert_respond_to(@owner_form, :role=)
    assert_respond_to(@owner_form, :description)
    assert_respond_to(@owner_form, :description=)
  end

  it("project form fetches task objects for existing Project") do
    project = projects(:yard)
    form = ProjectForm.new(project)
    expect(form.name).to(eq(project.name))
    expect(form.tasks.size).to(eq(2))
    expect(form.tasks[0].model).to(eq(project.tasks[0]))
    expect(form.tasks[1].model).to(eq(project.tasks[1]))
  end

  it("project form fetches contributor objects for existing Project") do
    project = projects(:gsoc)
    form = ProjectForm.new(project)
    expect("Add Form Models").to(eq(project.name))
    expect("Nesting models in a single form").to(eq(project.description))
    expect(form.contributors.size).to(eq(2))
    expect(form.contributors[0].model).to(eq(project.contributors[0]))
    expect(form.contributors[1].model).to(eq(project.contributors[1]))
  end

  it("project form fetches owner object for existing Project") do
    project = projects(:gsoc)
    form = ProjectForm.new(project)
    expect("Add Form Models").to(eq(project.name))
    expect("Nesting models in a single form").to(eq(project.description))
    expect(form.owner.name).to(eq("Peter Markou"))
    expect(form.owner.role).to(eq("GSoC Student"))
    expect(form.owner.description).to(eq("Working on adding Form Models"))
  end

  it("project form syncs its model and its tasks") do
    params = { :name => "Add Form Models", :tasks_attributes => ({ "0" => ({ :name => "Form unit", :description => "Form to represent a single model", :done => false }) }) }
    @form.submit(params)
    expect(@form.name).to(eq("Add Form Models"))
    expect(@form.tasks[0].name).to(eq("Form unit"))
    expect(@form.tasks[0].description).to(eq("Form to represent a single model"))
    expect(@form.tasks[0].done).to(eq(false))
    expect(@form.tasks.size).to(eq(1))
  end

  it("project form syncs its model and its contributors") do
    params = { :name => "Add Form Models", :description => "Nesting models in a single form", :contributors_attributes => ({ "0" => ({ :name => "Peter Markou", :role => "GSoC Student", :description => "Working on adding Form Models" }), "1" => ({ :name => "Carlos Silva", :role => "RoR Core Member", :description => "Assisting Peter throughout GSoC" }) }) }
    @form.submit(params)
    expect(@form.name).to(eq("Add Form Models"))
    expect(@form.description).to(eq("Nesting models in a single form"))
    expect(@form.contributors[0].name).to(eq("Peter Markou"))
    expect(@form.contributors[0].role).to(eq("GSoC Student"))
    expect(@form.contributors[0].description).to(eq("Working on adding Form Models"))
    expect(@form.contributors[1].name).to(eq("Carlos Silva"))
    expect(@form.contributors[1].role).to(eq("RoR Core Member"))
    expect(@form.contributors[1].description).to(eq("Assisting Peter throughout GSoC"))
    expect(@form.contributors.size).to(eq(2))
  end

  it("project form saves its model and its tasks") do
    params = { :name => "Add Form Models", :description => "Nested models in a single form", :tasks_attributes => ({ "0" => ({ :name => "Form unit", :description => "Form to represent a single model", :done => "0" }) }) }
    @form.submit(params)
    expect { @form.save }.to(change { Project.count })
    expect(@form.name).to(eq("Add Form Models"))
    expect(@form.description).to(eq("Nested models in a single form"))
    expect(@form.tasks[0].name).to(eq("Form unit"))
    expect(@form.tasks[0].description).to(eq("Form to represent a single model"))
    expect(@form.tasks[0].done).to(eq(false))
    expect(@form.tasks.size).to(eq(1))
    expect(@form.persisted?).to(eq(true))
    @form.tasks.each { |task_form| expect(task_form.persisted?).to(eq(true)) }
  end

  it("project form saves its model and its contributors") do
    params = { :name => "Add Form Models", :description => "Nesting models in a single form", :contributors_attributes => ({ "0" => ({ :name => "Peter Markou", :role => "GSoC Student", :description => "Working on adding Form Models" }), "1" => ({ :name => "Carlos Silva", :role => "RoR Core Member", :description => "Assisting Peter throughout GSoC" }) }) }
    @form.submit(params)
    expect { @form.save }.to(change { Project.count })
    expect(@form.name).to(eq("Add Form Models"))
    expect(@form.description).to(eq("Nesting models in a single form"))
    expect(@form.contributors[0].name).to(eq("Peter Markou"))
    expect(@form.contributors[0].role).to(eq("GSoC Student"))
    expect(@form.contributors[0].description).to(eq("Working on adding Form Models"))
    expect(@form.contributors[1].name).to(eq("Carlos Silva"))
    expect(@form.contributors[1].role).to(eq("RoR Core Member"))
    expect(@form.contributors[1].description).to(eq("Assisting Peter throughout GSoC"))
    expect(@form.contributors.size).to(eq(2))
    expect(@form.persisted?).to(eq(true))
    @form.contributors.each do |contributor_form|
      expect(contributor_form.persisted?).to(eq(true))
    end
  end

  it("project form updates its model and its tasks") do
    project = projects(:yard)
    form = ProjectForm.new(project)
    params = { :name => "Life", :tasks_attributes => ({ "0" => ({ :name => "Eat", :done => "1", :id => tasks(:rake).id }), "1" => ({ :name => "Pray", :done => "1", :id => tasks(:paint).id }) }) }
    form.submit(params)
    expect { form.save }.to(change { Project.count }.by(0))
    expect(form.name).to(eq("Life"))
    expect(form.tasks[0].name).to(eq("Eat"))
    expect(form.tasks[0].done).to(eq(true))
    expect(form.tasks[1].name).to(eq("Pray"))
    expect(form.tasks[1].done).to(eq(true))
    expect(form.tasks.size).to(eq(2))
  end

  it("project form updates its model and its contributors") do
    project = projects(:gsoc)
    form = ProjectForm.new(project)
    params = { :name => "Add Form Models", :description => "Nesting models in a single form", :contributors_attributes => ({ "0" => ({ :role => "CS Student", :id => people(:peter).id }), "1" => ({ :role => "Plataformatec Engineer", :id => people(:carlos).id }) }) }
    form.submit(params)
    expect { form.save }.to(change { Project.count }.by(0))
    expect(form.name).to(eq("Add Form Models"))
    expect(form.description).to(eq("Nesting models in a single form"))
    expect(form.contributors[0].name).to(eq("Peter Markou"))
    expect(form.contributors[0].role).to(eq("CS Student"))
    expect(form.contributors[0].description).to(eq("Working on adding Form Models"))
    expect(form.contributors[1].name).to(eq("Carlos Silva"))
    expect(form.contributors[1].role).to(eq("Plataformatec Engineer"))
    expect(form.contributors[1].description).to(eq("Assisting Peter throughout GSoC"))
    expect(form.contributors.size).to(eq(2))
  end

  it("project form responds to owner_id attribute") do
    attributes = [:owner_id, :owner_id=]
    attributes.each { |attribute| assert_respond_to(@form, attribute) }
  end

  it("project form responds to tasks writer method") do
    assert_respond_to(@form, :tasks_attributes=)
  end

  it("project form responds to contributors writer method") do
    assert_respond_to(@form, :contributors_attributes=)
  end

  it("project form responds to owner writer method") do
    assert_respond_to(@form, :owner_attributes=)
  end
end
