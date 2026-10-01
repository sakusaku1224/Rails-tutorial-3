require 'test_helper'

class MicropostsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @micropost = microposts(:orange)
  end

  test 'should redirect create when not logged in' do
    # ログインしていない時に新しい投稿を作成しようとしたら、作成されず、ログイン画面へリダイレクトされる
    assert_no_difference 'Micropost.count' do
      # 投稿数が増えていないことを確認する
      post microposts_path, params: { micropost: { content: 'Lorem ipsum' } }
      # 新しく作成するリクエストを送る
    end
    assert_redirected_to login_url
    # ログインページへリダイレクトされる
  end

  test 'should redirect destroy when not logged in' do
    assert_no_difference 'Micropost.count' do
      delete micropost_path(@micropost)
    end
    # 303ステータスコード：別のページに移動してください
    # Actual: 204：処理は実行されるが返す中身がない
    assert_response :see_other
    assert_redirected_to login_url
  end

  test 'should redirect destroy for wrong micropost' do
    # 自分以外のユーザが削除しようとするとリダイレクトされる
    log_in_as(users(:michael))
    micropost = microposts(:ants)
    assert_no_difference 'Micropost.count' do
      # 投稿数が減っていないことを確認する
      delete micropost_path(micropost)
    end
    assert_response :see_other
    assert_redirected_to root_url
  end
end
