module Middleware
  class DebugMiddleware
    def initialize(app)
      @app = app
      puts "【初期化】DebugMiddleware作成: @app = #{@app.class}"
    end

    def call(env)
      puts "【1. 前処理】DebugMiddleware: リクエスト受信"
      puts "  → 次の@app(#{@app.class})を呼び出します"

      # ここで次のミドルウェアまたはRailsアプリを呼ぶ
      status, headers, response = @app.call(env)

      puts "【3. 後処理】DebugMiddleware: レスポンス受信 status=#{status}"
      puts "  → さらに次へ返します"

      [status, headers, response]
    end
  end
end
