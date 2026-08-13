class ApplicationController < ActionController::Base
  # 他のコントローラで使用できると便利なメソッドを定義するために、ApplicationControllerに記述する
  # 他のコントローラで使用できるようにするために、helper_methodを使用する
  include SessionsHelper
end
