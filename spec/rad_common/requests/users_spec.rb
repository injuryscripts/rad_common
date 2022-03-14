require 'rails_helper'

RSpec.describe 'Users', type: :request do
  let(:admin) { create :admin }
  let(:user) { create :user }
  let(:another) { create :user }
  let(:invalid_attributes) { { first_name: nil } }

  before { login_as admin, scope: :user }

  describe 'POST create' do
    before do
      allow(RadicalConfig).to receive(:disable_sign_up?).and_return true
      allow(RadicalConfig).to receive(:disable_invite?).and_return true

      allow_any_instance_of(User).to receive(:authy_enabled?).and_return false
    end

    describe 'with valid params' do
      let(:valid_attributes) do
        { first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          mobile_phone: create(:phone_number, :mobile),
          password: 'cOmpl3x_p@55w0rd',
          email: 'example000@example.com' }
      end

      it 'creates the user and redirects' do
        post '/users', params: { user: valid_attributes }
        new_user = User.last
        expect(new_user.first_name).to eq(valid_attributes[:first_name])
        expect(response).to redirect_to(new_user)
      end
    end

    describe 'with invalid params' do
      it 're-renders the new template' do
        post '/users', params: { user: invalid_attributes }
        expect(response.body).to include 'Please review the problems below'
      end
    end
  end

  describe 'PUT update' do
    let(:valid_attributes) { { first_name: Faker::Name.first_name, last_name: Faker::Name.last_name } }

    describe 'with valid params' do
      let(:new_name) { 'Gary' }

      let(:new_attributes) { { first_name: new_name } }

      it 'updates the requested user' do
        put "/users/#{user.id}", params: { user: new_attributes }
        user.reload
        expect(user.first_name).to eq(new_name)
      end

      it 'redirects to the user' do
        put "/users/#{user.id}", params: { user: valid_attributes }
        expect(response).to redirect_to(user)
      end
    end

    describe 'with invalid params' do
      it 're-renders the edit template' do
        put "/users/#{user.id}", params: { user: invalid_attributes }
        expect(response.body).to include 'Please review the problems below'
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested user' do
      user
      expect {
        delete "/users/#{user.id}", headers: { HTTP_REFERER: user_path(user) }
      }.to change(User, :count).by(-1)
    end

    it 'redirects to the users list' do
      delete "/users/#{user.id}", headers: { HTTP_REFERER: user_path(user) }
      expect(response).to redirect_to(users_url)
    end

    it 'can not delete if user created audits' do
      another
      Audited::Audit.as_user(another) { user.update!(first_name: 'Foo') }
      expect(another.other_audits_created.count.positive?).to be true

      expect {
        delete "/users/#{another.id}", headers: { HTTP_REFERER: users_path }
      }.to change(User, :count).by(0)

      follow_redirect!
      expect(flash[:error]).to include 'User has audit history'
    end
  end
end
