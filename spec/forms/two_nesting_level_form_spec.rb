require 'spec_helper'

RSpec.describe('TwoNestingLevelForm') do

  fixtures(:songs, :artists, :producers)

  before do
    @song = Song.new
    @form = SongForm.new(@song)
    @producer_form = @form.artist.producer
    @model = @form
  end

  it("contains getter for producer sub-form") do
    assert_respond_to(@form.artist, :producer)
    expect(@producer_form).to(be_instance_of(ActionForm::Form))
  end

  it("producer sub-form contains association name and parent model") do
    expect(@producer_form.association_name).to(eq(:producer))
    expect(@producer_form.model).to(be_instance_of(Producer))
    expect(@producer_form.parent).to(be_instance_of(Artist))
  end

  it("producer sub-form initializes models for new parent") do
    expect(@producer_form.model).to(eq(@form.artist.model.producer))
    expect(@producer_form.model.new_record?).to(eq(true))
  end

  it("producer sub-form fetches models for existing parent") do
    song = songs(:lockdown)
    form = SongForm.new(song)
    artist_form = form.artist
    producer_form = artist_form.producer
    expect(form.title).to(eq("Love Lockdown"))
    expect(form.length).to(eq("350"))
    expect(form.persisted?).to(eq(true))
    expect(artist_form.name).to(eq("Kanye West"))
    expect(artist_form.persisted?).to(eq(true))
    expect(producer_form.name).to(eq("Jay-Z"))
    expect(producer_form.studio).to(eq("Ztudio"))
    expect(producer_form.persisted?).to(eq(true))
  end

  it("producer sub-form declares attributes") do
    attributes = [:name, :name=, :studio, :studio=]
    attributes.each { |attribute| assert_respond_to(@producer_form, attribute) }
  end

  it("producer sub-form delegates attributes to model") do
    @producer_form.name = "Phoebos"
    @producer_form.studio = "MADog"
    expect(@producer_form.name).to(eq("Phoebos"))
    expect(@producer_form.studio).to(eq("MADog"))
    expect(@producer_form.model.name).to(eq("Phoebos"))
    expect(@producer_form.model.studio).to(eq("MADog"))
  end

  it("main form syncs its model and the models in nested sub-forms") do
    params = { :title => "Diamonds", :length => "360", :artist_attributes => ({ :name => "Karras", :producer_attributes => ({ :name => "Phoebos", :studio => "MADog" }) }) }
    @form.submit(params)
    expect(@form.title).to(eq("Diamonds"))
    expect(@form.length).to(eq("360"))
    expect(@form.artist.name).to(eq("Karras"))
    expect(@producer_form.name).to(eq("Phoebos"))
    expect(@producer_form.studio).to(eq("MADog"))
  end

  it("main form validates itself") do
    params = { :title => nil, :length => nil, :artist_attributes => ({ :name => nil, :producer_attributes => ({ :name => nil, :studio => nil }) }) }
    @form.submit(params)
    expect(@form.valid?).to(eq(false))
    assert_includes(@form.errors[:title], "can't be blank")
    assert_includes(@form.errors[:length], "can't be blank")
    assert_includes(@form.errors["artist.name"], "can't be blank")
    assert_includes(@form.errors["artist.producer.studio"], "can't be blank")
    @form.title = "Diamonds"
    @form.length = "355"
    @form.artist.name = "Karras"
    @producer_form.name = "Phoebos"
    @producer_form.studio = "MADog"
    expect(@form.valid?).to(eq(true))
  end

  it("main form validates the models") do
    song = songs(:lockdown)
    params = { :title => song.title, :length => nil, :artist_attributes => ({ :name => song.artist.name, :producer_attributes => ({ :name => song.artist.producer.name, :studio => song.artist.producer.studio }) }) }
    @form.submit(params)
    expect(@form.valid?).to(eq(false))
    assert_includes(@form.errors[:title], "has already been taken")
    assert_includes(@form.errors["artist.name"], "has already been taken")
    assert_includes(@form.errors["artist.producer.name"], "has already been taken")
    assert_includes(@form.errors["artist.producer.studio"], "has already been taken")
  end

  it("main form saves its model and the models in nested sub-forms") do
    params = { :title => "Diamonds", :length => "360", :artist_attributes => ({ :name => "Karras", :producer_attributes => ({ :name => "Phoebos", :studio => "MADog" }) }) }
    @form.submit(params)
    expect { @form.save }.to change(Song, :count).by(1).and change(Artist, :count).by(1).and change(Producer, :count).by(1)
    expect(@form.title).to(eq("Diamonds"))
    expect(@form.length).to(eq("360"))
    expect(@form.artist.name).to(eq("Karras"))
    expect(@producer_form.name).to(eq("Phoebos"))
    expect(@producer_form.studio).to(eq("MADog"))
    expect(@form.persisted?).to(eq(true))
    expect(@form.artist.persisted?).to(eq(true))
    expect(@producer_form.persisted?).to(eq(true))
  end

  it("main form updates its model and the models in nested sub-forms") do
    song = songs(:lockdown)
    params = { :title => "Diamonds", :length => "360", :artist_attributes => ({ :name => "Karras", :producer_attributes => ({ :name => "Phoebos", :studio => "MADog" }) }) }
    form = SongForm.new(song)
    form.submit(params)
    expect { form.save }.to change(Song, :count).by(0).and change(Artist, :count).by(0).and change(Producer, :count).by(0)
    expect(form.title).to(eq("Diamonds"))
    expect(form.length).to(eq("360"))
    expect(form.artist.name).to(eq("Karras"))
    expect(form.artist.producer.name).to(eq("Phoebos"))
    expect(form.artist.producer.studio).to(eq("MADog"))
    expect(form.persisted?).to(eq(true))
    expect(form.artist.persisted?).to(eq(true))
    expect(form.artist.producer.persisted?).to(eq(true))
  end

  it("main form responds to writer method") do
    assert_respond_to(@form, :artist_attributes=)
    assert_respond_to(@form.artist, :producer_attributes=)
  end
end
