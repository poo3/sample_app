require 'test_helper'

class UsersShowTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
    @not_logged_in_user = users(:archer)
    @logged_in_user = users(:michael)
    @not_activated_user = users(:michael)
    @not_activated_user.update_attribute(:activated,false)
    @not_activated_user.reload
  end
  
  test "not activated user should redirect to root page" do
    get user_path(@not_activated_user)
    follow_redirect!
    assert_template 'static_pages/home'
  end

end
