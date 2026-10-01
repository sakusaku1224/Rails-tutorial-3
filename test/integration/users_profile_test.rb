require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user = users(:michael)
  end

  test 'profile display' do
    # プロフィールにアクセス
    get user_path(@user)
    # ページが正常に開けたか確認
    assert_response :success
    # ブラウザのタブタイトルの確認
    assert_select 'title', full_title(@user.name)
    # ページのh1タグの中にユーザの名前が入っているか
    assert_select 'h1', text: @user.name
    # <h1> タグのすぐ内側（子要素）に、gravatar というクラス名を持った <img> タグ（プロフィール画像）が存在するか
    assert_select 'h1>img.gravatar'
    # 投稿数の数字が表示されているか
    assert_match @user.microposts.count.to_s, response.body
    # ページネーションの存在チェック
    assert_select 'div.pagination'
    # 1ページ目に表示されるはずのマイクロポストを1件ずつ取り出して（each）
    # その投稿本文（micropost.content）が、画面のHTML（response.body）の中にちゃんと書き込まれているか
    @user.microposts.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body
    end
  end
end
