require 'rails_helper'

RSpec.describe 'Divisions', type: :system do
  let(:user) { create :admin }
  let(:division) { create :division }

  before { login_as user, scope: :user }

  describe 'new' do
    it 'renders the new template' do
      visit new_division_path
      expect(page).to have_content('New Division')
    end

    it 'shows presence error on autocomplete field' do
      visit new_division_path
      click_button 'Save'
      expect(page).to have_content('must exist')
    end

    describe 'single attachment validation' do
      let(:file) { 'spec/test_files/radlogo.jpeg' }

      before do
        allow_any_instance_of(Division).to receive(:save).and_return true
        visit new_division_path
        page.attach_file('Icon', file)
        click_on 'Save'
      end

      context 'invalid due to content type' do
        it 'validates' do
          expect(page).to have_content 'File could not be saved. File type must be one of image/png'
          expect(division.icon.attached?).to be false
        end
      end

      context 'invalid due to file size' do
        let(:file) { 'spec/test_files/large_logo.png' }

        it 'validates' do
          expect(page).to have_content 'File could not be saved. File size must be less than 48.8 KB.'
          expect(division.icon.attached?).to be false
        end
      end
    end
  end

  describe 'edit' do
    it 'renders the edit template' do
      visit edit_division_path(division)
      expect(page).to have_content('Editing Division')
    end

    describe 'multiple attachment validation' do
      let(:file2) { 'spec/test_files/radlogo.jpeg' }

      before do
        visit edit_division_path(division)
        page.attach_file('Avatar', file1)
        page.attach_file('Logo', file2)
        click_on 'Save'
      end

      context 'both invalid' do
        let(:file1) { 'spec/test_files/radlogo.png' }

        it 'validates' do
          expect(page).to have_content 'Logo, Avatar could not be saved due to invalid content types'
          expect(division.logo.attached?).to be false
          expect(division.avatar.attached?).to be false
        end
      end

      context 'one invalid' do
        let(:file1) { 'spec/test_files/radlogo.jpeg' }

        it 'validates' do
          expect(page).to have_content 'Logo could not be saved due to invalid content types'
          expect(division.logo.attached?).to be false
          expect(division.avatar.attached?).to be true
        end
      end
    end

    it 'displays error for owner field when blank', js: true do
      visit edit_division_path(division)
      fill_in 'owner_name', with: ''
      click_button 'Save'

      if ENV['CI']
        # TODO: fix this so it works locally
        expect(page).to have_content 'Owner must exist and Owner can\'t be blank'
      end
    end
  end

  describe 'index' do
    it 'displays the divisions' do
      division
      visit divisions_path
      expect(page).to have_content(division.to_s)
    end
  end

  describe 'show' do
    before { visit division_path(division) }

    it 'shows the division' do
      expect(page).to have_content(division.to_s)
    end

    it 'shows the right actions' do
      expect(page).to have_content('Right Button')
    end

    context 'attachments' do
      let(:prompt) { 'Are you sure? Attachment cannot be recovered.' }

      before do
        division.logo.attach(io: File.open(Rails.root.join('app', 'assets', 'images', 'app_logo.png')), filename: 'logo.png')
        visit division_path(division)
      end

      it 'allows attachment to be deleted', js: true do
        expect(ActiveStorage::Attachment.count).to eq 1

        page.accept_alert prompt do
          first('dd .fa-times').click
        end

        division.reload
        expect(page).to have_content 'Attachment successfully deleted'
        expect(ActiveStorage::Attachment.count).to eq 0
        expect(division.logo.attached?).to be false
      end
    end
  end
end
