require 'rails_helper'

describe 'SchemaValidations', type: :module do
  subject { division.errors.full_messages }
  let(:division) { create :division }

  describe 'presence validations' do
    context 'text field' do
      before { division.update(name: nil) }

      it { is_expected.to include "Name can't be blank" }
    end

    context 'numeric field' do
      before { division.update(hourly_rate: nil) }

      it { is_expected.to include "Hourly rate can't be blank" }
    end

    context 'boolean field' do
      before { division.update(notify: nil) }

      it { is_expected.to include "Notify can't be blank" }
    end

    context 'association' do
      before { division.update(owner: nil) }

      it { is_expected.to include "Owner can't be blank" }
    end
  end

  describe 'numericality validations' do
    context 'not a number' do
      before { division.update(hourly_rate: 'string') }

      it { is_expected.to include 'Hourly rate is not a number' }
    end

    context 'decimal value outside of precision range' do
      before { division.update(hourly_rate: 1_000_000_000) }

      it { is_expected.to include 'Hourly rate must be less than 1000000' }
    end
  end

  describe 'exempt columns' do
    it 'raises an error if exempt column fails database constraint' do
      expect { division.update!(created_at: nil) }.to raise_error ActiveRecord::NotNullViolation
    end
  end

  describe 'unique index valdiations' do
    subject { user_status.errors.full_messages }

    let(:user_status) { create :user_status }

    before { user_status.update(name: UserStatus.first.name) }

    it { is_expected.to include 'Name has already been taken' }
  end
end