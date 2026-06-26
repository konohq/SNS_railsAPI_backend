module RequestJsonHelper
  def expect_not_found_json
    expect(response).to have_http_status(:not_found)
    expect(response.parsed_body).to eq(
      "error" => {
        "code" => "not_found",
        "message" => "対象のデータが見つかりません"
      }
    )
  end
end
