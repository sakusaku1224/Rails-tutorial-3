require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  def setup
    @user = users(:michael)
    # このコードは慣習的に正しくない
    # @micropost = Micropost.new(content: 'Lorem ipsum', user_id: @user.id)
    @micropost = @user.microposts.build(content: 'Lorem ipsum')
  end

  # 有効であるべきである。正しい
  test 'should be valid' do
    # micropostは有効かどうか
    assert @micropost.valid?
  end

  test 'user id should be present' do
    # user id が空なら無効である
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  test 'content should be present' do
    # contentはから文字だめ
    @micropost.content = '  '
    assert_not @micropost.valid?
  end

  test 'content should be at most 140 characters' do
    # 140文字以内
    @micropost.content = 'a' * 141
    assert_not @micropost.valid?
  end

  test 'order should be most recent first' do
    # 予想される結果」と「実際の計算・処理結果」が一致するかどうかを検証（アサート）
    # 第1引数（左側）: expected（こうなるはず、という期待値）
    # 第2引数（右側）: actual（プログラムを実行して得られた実際の値）
    assert_equal microposts(:most_recent), Micropost.first
  end
end
