module RequestJsonHelper
  def expect_error_json(status:, code:, message: nil)
    expect(response).to have_http_status(status)
    expect(response.parsed_body.dig("error", "code")).to eq(code)
    expect(response.parsed_body.dig("error", "message")).to eq(message) if message
  end

  def expect_not_found_json(message: "対象のデータが見つかりません")
    expect_error_json(status: :not_found, code: "not_found", message: message)
  end

  def expect_unauthorized_json(message: "認証が必要です")
    expect_error_json(status: :unauthorized, code: "unauthorized", message: message)
  end

  def expect_bad_request_json
    expect_error_json(
      status: :bad_request,
      code: "bad_request",
      message: "リクエスト内容が正しくありません"
    )
  end

  def expect_validation_error_json
    expect_error_json(
      status: :unprocessable_content,
      code: "validation_error",
      message: "入力内容に誤りがあります"
    )
    expect(response.parsed_body.dig("error", "details")).to be_present
  end
end
