require 'rails_helper'

describe Division, type: :model do
  let(:division) { create :division }
  let(:app) { FirebaseApp.new }
  let(:first_email) { ActionMailer::Base.deliveries.first }
  let(:email) { ActionMailer::Base.deliveries.last }

  describe 'firebase' do
    before do
      allow_any_instance_of(User).to receive(:update_firebase_info).and_return(nil)
      ActionMailer::Base.deliveries = []
    end

    describe '#firebase_sync' do
      before do
        allow_any_instance_of(Firebase::Client).to receive(:update).and_return(Firebase::Response.new(nil))
        allow_any_instance_of(Firebase::Client).to receive(:delete).and_return(Firebase::Response.new(nil))
        allow_any_instance_of(Firebase::Response).to receive(:success?).and_return(true)
      end

      it 'syncs' do
        division.firebase_sync(app)
      end
    end

    describe '#firebase_cleanup' do
      let!(:user) { create :super_admin }

      before { Division.firebase_cleanup app, nil, 'foo', '/foo', {} }

      it 'emails firebase admins' do
        expect(email.subject).to eq 'User Error on Demo Foo'
      end
    end
  end
end
