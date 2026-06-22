module Middleware
  class RequestTimer
    # アプリ起動時に一度だけ呼ばれる
    # @param app [Object] 次のミドルウェアまたはRailsアプリ本体
    def initialize(app)
      @app = app  # 次に呼び出すミドルウェアを保存
    end

    # リクエストが来るたびに呼ばれる
    # @param env [Hash] リクエスト情報（HTTPメソッド、パス、ヘッダーなど）
    # @return [Array] [ステータスコード, ヘッダー, レスポンスボディ]
    def call(env)
      # 1. 処理開始時刻を記録
      start_time = Time.now
      request_method = env["REQUEST_METHOD"]  # "GET", "POST"など
      request_path = env["PATH_INFO"]         # "/books", "/books/1"など

      Rails.logger.info "[RequestTimer] ▶▶▶ 処理開始: #{request_method} #{request_path}"

      # 2. 次のミドルウェア（最終的にRailsアプリ）を呼び出す
      #    ここで実際のアプリケーション処理が実行される
      #    ⚠️ 重要: この行で待機する！全部終わるまで次の行に進まない！
      Rails.logger.info "[RequestTimer]   ⏱️  @app.call(env)を呼び出します..."
      status, headers, response = @app.call(env)

      # 返ってきた値を確認
      Rails.logger.info "[RequestTimer]   ✅ @app.call(env)が完了しました"
      Rails.logger.info "[RequestTimer]      status = #{status}"
      Rails.logger.info "[RequestTimer]      headers = #{headers['Content-Type']}"
      Rails.logger.info "[RequestTimer]      response = #{response.class} (HTMLの配列)"

      # 3. 処理終了後、経過時間を計算
      #    ↑ @app.call(env)が終わって戻ってきたので、ここが実行される
      elapsed_time = ((Time.now - start_time) * 1000).round(2)

      # 4. ログに処理時間を記録
      Rails.logger.info "[RequestTimer] ◀◀◀ 処理完了: #{request_method} #{request_path} - #{elapsed_time}ms"

      # 5. 受け取ったレスポンスをそのまま返す（次のミドルウェアまたはブラウザへ）
      [status, headers, response]
    end
  end
end
