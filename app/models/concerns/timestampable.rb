module TimeStampable
  extend ActiveSupport::Concern

  included do
    before_create :log_creation
    before_update :log_update
  end

  private 

  def log_creation
    Rails.logger.info "[#{self.class.name}] 新規作成: ID=#{id || 'pending'}"
  end

  def log_update
    Rails.logger.info "[#{self.class.name}] 更新: ID=#{id}, 変更カラム=#{changed.join(', ')}"
  end

end