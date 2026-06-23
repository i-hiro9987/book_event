require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'バリデーション' do
    it 'valid factory' do
      event = build(:event)
      expect(event).to be_valid
    end

    it '終了時刻は開始時刻より後' do
      event = build(:event, start_at: Time.current, end_at: 1.hour.ago)
      expect(event).not_to be_valid
      expect(event.errors[:end_at]).to include('は開始時刻より後に設定してください')
    end

    it '店員は1以上' do
      event = build(:event, capacity: 0)
      expect(event).not_to be_valid
    end

    describe '#full?' do
      it '定員に達している場合はtrue' do
        event = create(:event, :full)
        expect(event.full?).to be true
      end

      it '定員に達していない場合はfalse' do
        event = create(:event, capacity: 10)
        create_list(:participation, 5, event: event)
        expect(event.full?).to be false
      end
    end

    describe '#participated_by?' do
      let(:event) { create(:event) }
      let(:user) { create(:user) }

      it '参加している場合true' do
        create(:participation, event: event, user: user)
        expect(event.participated_by?(user)).to be true
      end

      it '参加していない場合false' do
        expect(event.participated_by?(user)).to be false
      end
    end
  end
end