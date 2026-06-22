class EventReminderJob < ApplicationJob
  queue_as :default

  def perform(event_id)
    event = Event.find(event_id)

    Rails.logger.info "===== イベントリマインダー送信 ====="
    Rails.logger.info "イベント:#{event.name}"
    Rails.logger.info "開始時刻:#{event.start_at.strftime('%Y年%m月%d日 %H時%M分')}"
    Rails.logger.info "参加者数:#{event.participants.count}"

    event.participants.each do |participant|
      Rails.logger.info "  -#{participant.name}（#{participant.email}）にリマインダー送信"
      # 後でメール送信を追加
      # EventMailer.reminder(event, participant).deliver_now
    end

    Rails.logger.info "リマインダー送信完了"
    Rails.logger.info "=============================="
  end
end
