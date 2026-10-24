require "test_helper"

class WellKnownControllerTest < ActionDispatch::IntegrationTest
  test "should get apple_app_site_association from .well-known" do
    get "/.well-known/apple-app-site-association"
    assert_response :success
    assert_equal "application/json; charset=utf-8", response.content_type

    json = response.parsed_body
    assert json["applinks"].present?
    assert json["applinks"]["details"].first["appID"].end_with?("et.netale.LitLoop")
  end

  test "should get apple_app_site_association from root" do
    get "/apple-app-site-association"
    assert_response :success
    assert_equal "application/json; charset=utf-8", response.content_type
  end

  test "should get assetlinks.json" do
    get "/.well-known/assetlinks.json"
    assert_response :success
    assert_equal "application/json; charset=utf-8", response.content_type

    json = response.parsed_body
    assert_equal "android_app", json.first["target"]["namespace"]
    assert_equal "et.netale.litloop", json.first["target"]["package_name"]
  end
end
