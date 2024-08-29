# frozen_string_literal: true

require 'spec_helper'

RSpec.describe('NestedModelRendering') do

  fixtures(:all)

  def form_for(*)
    @output_buffer = super
  end

  let(:autocomplete) { Rails.gem_version >= Gem::Version.new('6.1.5') ? 'autocomplete="off" ' : '' }

  it('form_for renders correctly a new instance of UserFormFixture') do
    user = User.new
    user_form = UserFormFixture.new(user)
    form_for(user_form) do |f|
      concat(f.label(:name))
      concat(f.text_field(:name))
      concat(f.label(:age))
      concat(f.number_field(:age))
      concat(f.label(:gender))
      concat(f.select(:gender, User.get_genders_dropdown))
      concat(f.submit)
    end
    expect(output_buffer).to(match(%r{action="/users"}))
    expect(output_buffer).to(match(/class="new_user"/))
    expect(output_buffer).to(match(/id="new_user"/))
    expect(output_buffer).to(match(/method="post"/))
    expect(output_buffer).to(match(%r{<label for="user_name">Name</label>}))
    expect(output_buffer).to(match(%r{<input type="text" name="user\[name\]" id="user_name" />}))
    expect(output_buffer).to(match(%r{<label for="user_age">Age</label>}))
    expect(output_buffer).to(match(%r{<input type="number" name="user\[age\]" id="user_age" />}))
    expect(output_buffer).to(match(%r{<label for="user_gender">Gender</label>}))
    expect(output_buffer).to(match(/<select name="user\[gender\]" id="user_gender">/))
    expect(output_buffer).to(match(%r{<option value="0">Male</option>}))
    expect(output_buffer).to(match(%r{<option value="1">Female</option>}))
    expect(output_buffer).to(match(%r{</select>}))
    expect(output_buffer).to(match(%r{<input type="submit" name="commit" value="Create User" data-disable-with="Create User" />}))
  end

  it('form_for renders correctly a existing instance of UserFormFixture') do
    user = users(:peter)
    user_form = UserFormFixture.new(user)
    form_for(user_form) do |f|
      concat(f.label(:name))
      concat(f.text_field(:name))
      concat(f.label(:age))
      concat(f.number_field(:age))
      concat(f.label(:gender))
      concat(f.select(:gender, User.get_genders_dropdown))
      concat(f.submit)
    end
    id = user.id
    expect(output_buffer).to(match(%r{action="/users/#{id}"}))
    expect(output_buffer).to(match(/class="edit_user"/))
    expect(output_buffer).to(match(/id="edit_user_#{id}"/))
    expect(output_buffer).to(match(/method="post"/))
    expect(output_buffer).to(match(%r{<label for="user_name">Name</label>}))
    expect(output_buffer).to(match(%r{<input type="text" value="#{user_form.name}" name="user\[name\]" id="user_name" />}))
    expect(output_buffer).to(match(%r{<label for="user_age">Age</label>}))
    expect(output_buffer).to(match(%r{<input type="number" value="#{user_form.age}" name="user\[age\]" id="user_age" />}))
    expect(output_buffer).to(match(%r{<label for="user_gender">Gender</label>}))
    expect(output_buffer).to(match(/<select name="user\[gender\]" id="user_gender">/))
    expect(output_buffer).to(match(%r{<option selected="selected" value="0">Male</option>}))
    expect(output_buffer).to(match(%r{<option value="1">Female</option>}))
    expect(output_buffer).to(match(%r{</select>}))
    expect(output_buffer).to(match(%r{<input type="submit" name="commit" value="Update User" data-disable-with="Update User" />}))
  end

  it('form_for renders correctly a new instance of UserWithEmailFormFixture') do
    user = User.new
    user_form = UserWithEmailFormFixture.new(user)
    form_for(user_form) do |f|
      concat(f.label(:name))
      concat(f.text_field(:name))
      concat(f.label(:age))
      concat(f.number_field(:age))
      concat(f.label(:gender))
      concat(f.select(:gender, User.get_genders_dropdown))
      concat(f.fields_for(:email, user_form.email) do |email_fields|
        concat(email_fields.label(:address))
        concat(email_fields.text_field(:address))
      end)
      concat(f.submit)
    end
    expect(output_buffer).to(match(%r{action="/users"}))
    expect(output_buffer).to(match(/class="new_user"/))
    expect(output_buffer).to(match(/id="new_user"/))
    expect(output_buffer).to(match(/method="post"/))
    expect(output_buffer).to(match(%r{<label for="user_name">Name</label>}))
    expect(output_buffer).to(match(%r{<input type="text" name="user\[name\]" id="user_name" />}))
    expect(output_buffer).to(match(%r{<label for="user_age">Age</label>}))
    expect(output_buffer).to(match(%r{input type="number" name="user\[age\]" id="user_age" />}))
    expect(output_buffer).to(match(%r{<label for="user_gender">Gender</label>}))
    expect(output_buffer).to(match(/<select name="user\[gender\]" id="user_gender">/))
    expect(output_buffer).to(match(%r{<option value="0">Male</option>}))
    expect(output_buffer).to(match(%r{<option value="1">Female</option>}))
    expect(output_buffer).to(match(%r{</select>}))
    expect(output_buffer).to(match(%r{<label for="user_email_attributes_address">Address</label>}))
    expect(output_buffer).to(match(%r{<input type="text" name="user\[email_attributes\]\[address\]" id="user_email_attributes_address" />}))
    expect(output_buffer).to(match(%r{<input type="submit" name="commit" value="Create User" data-disable-with="Create User" />}))
  end

  it('form_for renders correctly a existing instance of UserWithEmailFormFixture') do
    user = users(:peter)
    user_form = UserWithEmailFormFixture.new(user)
    form_for(user_form) do |f|
      concat(f.label(:name))
      concat(f.text_field(:name))
      concat(f.label(:age))
      concat(f.number_field(:age))
      concat(f.label(:gender))
      concat(f.select(:gender, User.get_genders_dropdown))
      concat(f.fields_for(:email, user_form.email) do |email_fields|
        concat(email_fields.label(:address))
        concat(email_fields.text_field(:address))
      end)
      concat(f.submit)
    end
    id = user.id
    expect(output_buffer).to(match(%r{action="/users/#{id}"}))
    expect(output_buffer).to(match(/class="edit_user"/))
    expect(output_buffer).to(match(/id="edit_user_#{id}"/))
    expect(output_buffer).to(match(/method="post"/))
    expect(output_buffer).to(match(%r{<label for="user_name">Name</label>}))
    expect(output_buffer).to(match(%r{<input type="text" value="#{user_form.name}" name="user\[name\]" id="user_name" />}))
    expect(output_buffer).to(match(%r{<label for="user_age">Age</label>}))
    expect(output_buffer).to(match(%r{<input type="number" value="#{user_form.age}" name="user\[age\]" id="user_age" />}))
    expect(output_buffer).to(match(%r{<label for="user_gender">Gender</label>}))
    expect(output_buffer).to(match(/<select name="user\[gender\]" id="user_gender">/))
    expect(output_buffer).to(match(%r{<option selected="selected" value="0">Male</option>}))
    expect(output_buffer).to(match(%r{<option value="1">Female</option>}))
    expect(output_buffer).to(match(%r{</select>}))
    expect(output_buffer).to(match(%r{<label for="user_email_attributes_address">Address</label>}))
    expect(output_buffer).to(match(%r{<input type="text" value="#{user_form.email.address}" name="user\[email_attributes\]\[address\]" id="user_email_attributes_address" />}))
    expect(output_buffer).to(match(%r{<input #{autocomplete}type="hidden" value="#{user_form.email.id}" name="user\[email_attributes\]\[id\]" id="user_email_attributes_id" />}))
    expect(output_buffer).to(match(%r{<input type="submit" name="commit" value="Update User" data-disable-with="Update User" />}))
  end

  it('form_for renders correctly a new instance of UserWithEmailAndProfileFormFixture') do
    user = User.new
    user_form = UserForm.new(user)
    form_for(user_form) do |f|
      concat(f.label(:name))
      concat(f.text_field(:name))
      concat(f.label(:age))
      concat(f.number_field(:age))
      concat(f.label(:gender))
      concat(f.select(:gender, User.get_genders_dropdown))
      concat(f.fields_for(:email, user_form.email) do |email_fields|
        concat(email_fields.label(:address))
        concat(email_fields.text_field(:address))
      end)
      concat(f.fields_for(:profile, user_form.profile) do |profile_fields|
        concat(profile_fields.label(:twitter_name))
        concat(profile_fields.text_field(:twitter_name))
        concat(profile_fields.label(:github_name))
        concat(profile_fields.text_field(:github_name))
      end)
      concat(f.submit)
    end
    expect(output_buffer).to(match(%r{action="/users"}))
    expect(output_buffer).to(match(/class="new_user"/))
    expect(output_buffer).to(match(/id="new_user"/))
    expect(output_buffer).to(match(/method="post"/))
    expect(output_buffer).to(match(%r{<label for="user_name">Name</label>}))
    expect(output_buffer).to(match(%r{<input type="text" name="user\[name\]" id="user_name" />}))
    expect(output_buffer).to(match(%r{<label for="user_age">Age</label>}))
    expect(output_buffer).to(match(%r{input type="number" name="user\[age\]" id="user_age" />}))
    expect(output_buffer).to(match(%r{<label for="user_gender">Gender</label>}))
    expect(output_buffer).to(match(/<select name="user\[gender\]" id="user_gender">/))
    expect(output_buffer).to(match(%r{<option value="0">Male</option>}))
    expect(output_buffer).to(match(%r{<option value="1">Female</option>}))
    expect(output_buffer).to(match(%r{</select>}))
    expect(output_buffer).to(match(%r{<label for="user_email_attributes_address">Address</label>}))
    expect(output_buffer).to(match(%r{<input type="text" name="user\[email_attributes\]\[address\]" id="user_email_attributes_address" />}))
    expect(output_buffer).to(match(%r{<label for="user_profile_attributes_twitter_name">Twitter name</label>}))
    expect(output_buffer).to(match(%r{<input type="text" name="user\[profile_attributes\]\[twitter_name\]" id="user_profile_attributes_twitter_name" />}))
    expect(output_buffer).to(match(%r{<label for="user_profile_attributes_github_name">Github name</label>}))
    expect(output_buffer).to(match(%r{<input type="text" name="user\[profile_attributes\]\[github_name\]" id="user_profile_attributes_github_name" />}))
    expect(output_buffer).to(match(%r{<input type="submit" name="commit" value="Create User" data-disable-with="Create User" />}))
  end

  it('form_for renders correctly an existing instance of UserWithEmailAndProfileFormFixture') do
    user = users(:peter)
    user_form = UserForm.new(user)
    form_for(user_form) do |f|
      concat(f.label(:name))
      concat(f.text_field(:name))
      concat(f.label(:age))
      concat(f.number_field(:age))
      concat(f.label(:gender))
      concat(f.select(:gender, User.get_genders_dropdown))
      concat(f.fields_for(:email, user_form.email) do |email_fields|
        concat(email_fields.label(:address))
        concat(email_fields.text_field(:address))
      end)
      concat(f.fields_for(:profile, user_form.profile) do |profile_fields|
        concat(profile_fields.label(:twitter_name))
        concat(profile_fields.text_field(:twitter_name))
        concat(profile_fields.label(:github_name))
        concat(profile_fields.text_field(:github_name))
      end)
      concat(f.submit)
    end
    id = user.id
    expect(output_buffer).to(match(%r{action="/users/#{id}"}))
    expect(output_buffer).to(match(/class="edit_user"/))
    expect(output_buffer).to(match(/id="edit_user_#{id}"/))
    expect(output_buffer).to(match(/method="post"/))
    expect(output_buffer).to(match(%r{<label for="user_name">Name</label>}))
    expect(output_buffer).to(match(%r{<input type="text" value="#{user_form.name}" name="user\[name\]" id="user_name" />}))
    expect(output_buffer).to(match(%r{<label for="user_age">Age</label>}))
    expect(output_buffer).to(match(%r{<input type="number" value="#{user_form.age}" name="user\[age\]" id="user_age" />}))
    expect(output_buffer).to(match(%r{<label for="user_gender">Gender</label>}))
    expect(output_buffer).to(match(/<select name="user\[gender\]" id="user_gender">/))
    expect(output_buffer).to(match(%r{<option selected="selected" value="0">Male</option>}))
    expect(output_buffer).to(match(%r{<option value="1">Female</option>}))
    expect(output_buffer).to(match(%r{</select>}))
    expect(output_buffer).to(match(%r{<label for="user_email_attributes_address">Address</label>}))
    expect(output_buffer).to(match(%r{<input type="text" value="#{user_form.email.address}" name="user\[email_attributes\]\[address\]" id="user_email_attributes_address" />}))
    expect(output_buffer).to(match(%r{<input #{autocomplete}type="hidden" value="#{user_form.email.id}" name="user\[email_attributes\]\[id\]" id="user_email_attributes_id" />}))
    expect(output_buffer).to(match(%r{<label for="user_profile_attributes_twitter_name">Twitter name</label>}))
    expect(output_buffer).to(match(%r{<input type="text" value="#{user_form.profile.twitter_name}" name="user\[profile_attributes\]\[twitter_name\]" id="user_profile_attributes_twitter_name" />}))
    expect(output_buffer).to(match(%r{<label for="user_profile_attributes_github_name">Github name</label>}))
    expect(output_buffer).to(match(%r{<input type="text" value="#{user_form.profile.github_name}" name="user\[profile_attributes\]\[github_name\]" id="user_profile_attributes_github_name" />}))
    expect(output_buffer).to(match(%r{<input #{autocomplete}type="hidden" value="#{user_form.profile.id}" name="user\[profile_attributes\]\[id\]" id="user_profile_attributes_id" />}))
    expect(output_buffer).to(match(%r{<input type="submit" name="commit" value="Update User" data-disable-with="Update User" />}))
  end

  it('form_for renders correctly a new instance of SongsFormFixture') do
    song = Song.new
    song_form = SongForm.new(song)
    artist = song_form.artist
    producer = artist.producer
    form_for(song_form) do |f|
      concat(f.label(:title))
      concat(f.text_field(:title))
      concat(f.label(:length))
      concat(f.text_field(:length))
      concat(f.fields_for(:artist, artist) do |artist_fields|
        concat(artist_fields.label(:name))
        concat(artist_fields.text_field(:name))
        concat(artist_fields.fields_for(:producer, producer) do |producer_fields|
          concat(producer_fields.label(:name))
          concat(producer_fields.text_field(:name))
          concat(producer_fields.label(:studio))
          concat(producer_fields.text_field(:studio))
        end)
      end)
      concat(f.submit)
    end
    expect(output_buffer).to(match(%r{action="/songs"}))
    expect(output_buffer).to(match(/class="new_song"/))
    expect(output_buffer).to(match(/id="new_song"/))
    expect(output_buffer).to(match(/method="post"/))
    expect(output_buffer).to(match(%r{<label for="song_title">Title</label>}))
    expect(output_buffer).to(match(%r{<input type="text" name="song\[title\]" id="song_title" />}))
    expect(output_buffer).to(match(%r{<label for="song_length">Length</label>}))
    expect(output_buffer).to(match(%r{input type="text" name="song\[length\]" id="song_length" />}))
    expect(output_buffer).to(match(%r{<label for="song_artist_attributes_name">Name</label>}))
    expect(output_buffer).to(match(%r{<input type="text" name="song\[artist_attributes\]\[name\]" id="song_artist_attributes_name" />}))
    expect(output_buffer).to(match(%r{<label for="song_artist_attributes_producer_attributes_name">Name</label>}))
    expect(output_buffer).to(match(%r{<input type="text" name="song\[artist_attributes\]\[producer_attributes\]\[name\]" id="song_artist_attributes_producer_attributes_name" />}))
    expect(output_buffer).to(match(%r{<label for="song_artist_attributes_producer_attributes_studio">Studio</label>}))
    expect(output_buffer).to(match(%r{<input type="text" name="song\[artist_attributes\]\[producer_attributes\]\[studio\]" id="song_artist_attributes_producer_attributes_studio" />}))
    expect(output_buffer).to(match(%r{<input type="submit" name="commit" value="Create Song" data-disable-with="Create Song" />}))
  end

  it('form_for renders correctly a existing instance of SongsFormFixture') do
    song = songs(:lockdown)
    song_form = SongForm.new(song)
    artist = song_form.artist
    producer = artist.producer
    form_for(song_form) do |f|
      concat(f.label(:title))
      concat(f.text_field(:title))
      concat(f.label(:length))
      concat(f.text_field(:length))
      concat(f.fields_for(:artist, artist) do |artist_fields|
        concat(artist_fields.label(:name))
        concat(artist_fields.text_field(:name))
        concat(artist_fields.fields_for(:producer, producer) do |producer_fields|
          concat(producer_fields.label(:name))
          concat(producer_fields.text_field(:name))
          concat(producer_fields.label(:studio))
          concat(producer_fields.text_field(:studio))
        end)
      end)
      concat(f.submit)
    end
    id = song.id
    expect(output_buffer).to(match(%r{action="/songs/#{id}"}))
    expect(output_buffer).to(match(/class="edit_song"/))
    expect(output_buffer).to(match(/id="edit_song_#{id}"/))
    expect(output_buffer).to(match(/method="post"/))
    expect(output_buffer).to(match(%r{<label for="song_title">Title</label>}))
    expect(output_buffer).to(match(%r{<input type="text" value="#{song_form.title}" name="song\[title\]" id="song_title" />}))
    expect(output_buffer).to(match(%r{<label for="song_length">Length</label>}))
    expect(output_buffer).to(match(%r{input type="text" value="#{song_form.length}" name="song\[length\]" id="song_length" />}))
    expect(output_buffer).to(match(%r{<label for="song_artist_attributes_name">Name</label>}))
    expect(output_buffer).to(match(%r{<input type="text" value="#{artist.name}" name="song\[artist_attributes\]\[name\]" id="song_artist_attributes_name" />}))
    expect(output_buffer).to(match(%r{<input #{autocomplete}type="hidden" value="#{artist.id}" name="song\[artist_attributes\]\[id\]" id="song_artist_attributes_id" />}))
    expect(output_buffer).to(match(%r{<label for="song_artist_attributes_producer_attributes_name">Name</label>}))
    expect(output_buffer).to(match(%r{<input type="text" value="#{producer.name}" name="song\[artist_attributes\]\[producer_attributes\]\[name\]" id="song_artist_attributes_producer_attributes_name" />}))
    expect(output_buffer).to(match(%r{<label for="song_artist_attributes_producer_attributes_studio">Studio</label>}))
    expect(output_buffer).to(match(%r{<input type="text" value="#{producer.studio}" name="song\[artist_attributes\]\[producer_attributes\]\[studio\]" id="song_artist_attributes_producer_attributes_studio" />}))
    expect(output_buffer).to(match(%r{<input #{autocomplete}type="hidden" value="#{producer.id}" name="song\[artist_attributes\]\[producer_attributes\]\[id\]" id="song_artist_attributes_producer_attributes_id" />}))
    expect(output_buffer).to(match(%r{<input type="submit" name="commit" value="Update Song" data-disable-with="Update Song" />}))
  end

  it('form_for renders correctly a new instance of ConferenceFormFixture') do
    conference = Conference.new
    conference_form = ConferenceForm.new(conference)
    speaker = conference_form.speaker
    presentations = speaker.presentations
    form_for(conference_form) do |f|
      concat(f.label(:name))
      concat(f.text_field(:name))
      concat(f.label(:city))
      concat(f.text_field(:city))
      concat(f.fields_for(:speaker, speaker) do |speaker_fields|
        concat(speaker_fields.label(:name))
        concat(speaker_fields.text_field(:name))
        concat(speaker_fields.label(:occupation))
        concat(speaker_fields.text_field(:occupation))
        concat(speaker_fields.fields_for(:presentations, presentations) do |presentation_fields|
          concat(presentation_fields.label(:topic))
          concat(presentation_fields.text_field(:topic))
          concat(presentation_fields.label(:duration))
          concat(presentation_fields.text_field(:duration))
        end)
      end)
      concat(f.submit)
    end
    expect(output_buffer).to(match(%r{action="/conferences"}))
    expect(output_buffer).to(match(/class="new_conference"/))
    expect(output_buffer).to(match(/id="new_conference"/))
    expect(output_buffer).to(match(/method="post"/))
    expect(output_buffer).to(match(%r{<label for="conference_name">Name</label>}))
    expect(output_buffer).to(match(%r{<input type="text" name="conference\[name\]" id="conference_name" />}))
    expect(output_buffer).to(match(%r{<label for="conference_city">City</label>}))
    expect(output_buffer).to(match(%r{<input type="text" name="conference\[city\]" id="conference_city" />}))
    expect(output_buffer).to(match(%r{<label for="conference_speaker_attributes_name">Name</label>}))
    expect(output_buffer).to(match(%r{<input type="text" name="conference\[speaker_attributes\]\[name\]" id="conference_speaker_attributes_name" />}))
    expect(output_buffer).to(match(%r{<label for="conference_speaker_attributes_occupation">Occupation</label>}))
    expect(output_buffer).to(match(%r{<input type="text" name="conference\[speaker_attributes\]\[occupation\]" id="conference_speaker_attributes_occupation" />}))
    [0, 1].each do |i|
      expect(output_buffer).to(match(%r{<label for="conference_speaker_attributes_presentations_attributes_#{i}_topic">Topic</label>}))
      expect(output_buffer).to(match(%r{<input type="text" name="conference\[speaker_attributes\]\[presentations_attributes\]\[#{i}\]\[topic\]" id="conference_speaker_attributes_presentations_attributes_#{i}_topic" />}))
      expect(output_buffer).to(match(%r{<label for="conference_speaker_attributes_presentations_attributes_#{i}_duration">Duration</label>}))
      expect(output_buffer).to(match(%r{<input type="text" name="conference\[speaker_attributes\]\[presentations_attributes\]\[#{i}\]\[duration\]" id="conference_speaker_attributes_presentations_attributes_#{i}_duration" />}))
    end
    expect(output_buffer).to(match(%r{<input type="submit" name="commit" value="Create Conference" data-disable-with="Create Conference" />}))
  end

  it('form_for renders correct a existing instance of ConferenceFormFixture') do
    conference = conferences(:ruby)
    conference_form = ConferenceForm.new(conference)
    speaker = conference_form.speaker
    presentations = speaker.presentations
    form_for(conference_form) do |f|
      concat(f.label(:name))
      concat(f.text_field(:name))
      concat(f.label(:city))
      concat(f.text_field(:city))
      concat(f.fields_for(:speaker, speaker) do |speaker_fields|
        concat(speaker_fields.label(:name))
        concat(speaker_fields.text_field(:name))
        concat(speaker_fields.label(:occupation))
        concat(speaker_fields.text_field(:occupation))
        concat(speaker_fields.fields_for(:presentations, presentations) do |presentation_fields|
          concat(presentation_fields.label(:topic))
          concat(presentation_fields.text_field(:topic))
          concat(presentation_fields.label(:duration))
          concat(presentation_fields.text_field(:duration))
        end)
      end)
      concat(f.submit)
    end
    id = conference.id
    expect(output_buffer).to(match(%r{action="/conferences/#{id}"}))
    expect(output_buffer).to(match(/class="edit_conference"/))
    expect(output_buffer).to(match(/id="edit_conference_#{id}"/))
    expect(output_buffer).to(match(/method="post"/))
    expect(output_buffer).to(match(%r{<label for="conference_name">Name</label>}))
    expect(output_buffer).to(match(%r{<input type="text" value="#{conference_form.name}" name="conference\[name\]" id="conference_name" />}))
    expect(output_buffer).to(match(%r{<label for="conference_city">City</label>}))
    expect(output_buffer).to(match(%r{<input type="text" value="#{conference_form.city}" name="conference\[city\]" id="conference_city" />}))
    expect(output_buffer).to(match(%r{<label for="conference_speaker_attributes_name">Name</label>}))
    expect(output_buffer).to(match(%r{<input type="text" value="#{speaker.name}" name="conference\[speaker_attributes\]\[name\]" id="conference_speaker_attributes_name" />}))
    expect(output_buffer).to(match(%r{<label for="conference_speaker_attributes_occupation">Occupation</label>}))
    expect(output_buffer).to(match(%r{<input type="text" value="#{speaker.occupation}" name="conference\[speaker_attributes\]\[occupation\]" id="conference_speaker_attributes_occupation" />}))
    expect(output_buffer).to(match(%r{<input #{autocomplete}type="hidden" value="#{speaker.id}" name="conference\[speaker_attributes\]\[id\]" id="conference_speaker_attributes_id" />}))
    [0, 1].each do |i|
      expect(output_buffer).to(match(%r{<label for="conference_speaker_attributes_presentations_attributes_#{i}_topic">Topic</label>}))
      expect(output_buffer).to(match(%r{<input type="text" value="#{presentations[i].topic}" name="conference\[speaker_attributes\]\[presentations_attributes\]\[#{i}\]\[topic\]" id="conference_speaker_attributes_presentations_attributes_#{i}_topic" />}))
      expect(output_buffer).to(match(%r{<label for="conference_speaker_attributes_presentations_attributes_#{i}_duration">Duration</label>}))
      expect(output_buffer).to(match(%r{<input type="text" value="#{presentations[i].duration}" name="conference\[speaker_attributes\]\[presentations_attributes\]\[#{i}\]\[duration\]" id="conference_speaker_attributes_presentations_attributes_#{i}_duration" />}))
    end
    expect(output_buffer).to(match(%r{<input type="submit" name="commit" value="Update Conference" data-disable-with="Update Conference" />}))
  end

  it('form_for renders correctly a new instance of SurveyFormFixture') do
    survey = Survey.new
    survey_form = SurveyForm.new(survey)
    questions = survey_form.questions
    form_for(survey_form) do |f|
      concat(f.label(:name))
      concat(f.text_field(:name))
      concat(f.fields_for(:questions, questions) do |question_fields|
        concat(question_fields.label(:content))
        concat(question_fields.text_field(:content))
        concat(question_fields.fields_for(:answers, question_fields.object.answers) do |answer_fields|
          concat(answer_fields.label(:content))
          concat(answer_fields.text_field(:content))
        end)
      end)
      concat(f.submit)
    end
    expect(output_buffer).to(match(%r{action="/surveys"}))
    expect(output_buffer).to(match(/class="new_survey"/))
    expect(output_buffer).to(match(/id="new_survey"/))
    expect(output_buffer).to(match(/method="post"/))
    expect(output_buffer).to(match(%r{<label for="survey_name">Name</label>}))
    expect(output_buffer).to(match(%r{<input type="text" name="survey\[name\]" id="survey_name" />}))
    expect(output_buffer).to(match(%r{<label for="survey_questions_attributes_0_content">Content</label>}))
    expect(output_buffer).to(match(%r{<input type="text" name="survey\[questions_attributes\]\[0\]\[content\]" id="survey_questions_attributes_0_content" />}))
    [0, 1].each do |i|
      expect(output_buffer).to(match(%r{<label for="survey_questions_attributes_0_answers_attributes_#{i}_content">Content</label>}))
      expect(output_buffer).to(match(%r{<input type="text" name="survey\[questions_attributes\]\[0\]\[answers_attributes\]\[#{i}\]\[content\]" id="survey_questions_attributes_0_answers_attributes_#{i}_content" />}))
    end
    expect(output_buffer).to(match(%r{<input type="submit" name="commit" value="Create Survey" data-disable-with="Create Survey" />}))
  end

  it('form_for renders correctly a existing instance of SurveyFormFixture') do
    survey = surveys(:programming)
    survey_form = SurveyForm.new(survey)
    questions = survey_form.questions
    form_for(survey_form) do |f|
      concat(f.label(:name))
      concat(f.text_field(:name))
      concat(f.fields_for(:questions, questions) do |question_fields|
        concat(question_fields.label(:content))
        concat(question_fields.text_field(:content))
        concat(question_fields.fields_for(:answers, question_fields.object.answers) do |answer_fields|
          concat(answer_fields.label(:content))
          concat(answer_fields.text_field(:content))
        end)
      end)
      concat(f.submit)
    end
    id = survey.id
    expect(output_buffer).to(match(%r{action="/surveys/#{id}"}))
    expect(output_buffer).to(match(/class="edit_survey"/))
    expect(output_buffer).to(match(/id="edit_survey_#{id}"/))
    expect(output_buffer).to(match(/method="post"/))
    expect(output_buffer).to(match(%r{<label for="survey_name">Name</label>}))
    expect(output_buffer).to(match(%r{<input type="text" value="#{survey_form.name}" name="survey\[name\]" id="survey_name" />}))
    expect(output_buffer).to(match(%r{<label for="survey_questions_attributes_0_content">Content</label>}))
    expect(output_buffer).to(match(%r{<input type="text" value="Which language allows closures\?" name="survey\[questions_attributes\]\[0\]\[content\]" id="survey_questions_attributes_0_content" />}))
    expect(output_buffer).to(match(%r{<input #{autocomplete}type="hidden" value="#{questions[0].id}" name="survey\[questions_attributes\]\[0\]\[id\]" id="survey_questions_attributes_0_id" />}))
    [0, 1].each do |i|
      expect(output_buffer).to(match(%r{<label for="survey_questions_attributes_0_answers_attributes_#{i}_content">Content</label>}))
      expect(output_buffer).to(match(%r{<input type="text" value="#{questions[0].answers[i].content}" name="survey\[questions_attributes\]\[0\]\[answers_attributes\]\[#{i}\]\[content\]" id="survey_questions_attributes_0_answers_attributes_#{i}_content" />}))
    end
    expect(output_buffer).to(match(%r{<input type="submit" name="commit" value="Update Survey" data-disable-with="Update Survey" />}))
  end
end
