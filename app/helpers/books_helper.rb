module BooksHelper
  def status_budge(status)
    case status
    when 'available'
      '✅ 販売中'
    when 'sold_out'
      '📤 売り切れ'
    when 'discontinued'
      '⛔️ 販売終了'
    else
      status
    end
  end
end
