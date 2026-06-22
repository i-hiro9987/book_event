class DailyReminderJob < ApplicationJob
  queue_as :default

  def perform
    tomorrow_start = 1.day.from_now.beginning_of_day
    tomorrow_end = 1.day.from_now.end_of_day

    events = Event.where(start_at: tomorrow_start..tomorrow_end)

    Rails.logger.info "===== 明日のイベントリマインダー ====="
    Rails.logger.info "対象イベント数:#{events.count}"

    events.each do |event|
      EventReminderJob.perform_later(event.id)
    end

    Rails.logger.info "=============================="
  end
end
