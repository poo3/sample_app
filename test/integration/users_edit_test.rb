require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
    @user = users(:michael)
  end

  test 'unsucessful edit' do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user),params: {user:{name:'',
                          email:'foo@invalid',
                          password: 'foo',
                          password_confirmation: 'bar'}}

    assert_template 'users/edit'
    assert_select "div.alert","The form contains 4 errors."
  end

  test 'sucessful edit' do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    name = 'Foo Bar'
    email = "foo@bar.com"
    patch user_path(@user),params:{user:{name: name,
                          email: email,
                          password: "",
                          password_confirmation: ""}}
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name,@user.name
    assert_equal email,@user.email
  end

  test "sucessful edit with friendly fowarding" do
    get edit_user_path(@user)
    assert_equal session[:fowarding_url],edit_user_url(@user)
    log_in_as(@user)
    assert_equal session[:fowarding_url],nil
    assert_redirected_to edit_user_url(@user)
    name = 'Foo Bar'
    email = "foo@bar.com"
    patch user_path(@user),params:{user:{name: name,
                          email: email,
                          password: "",
                          password_confirmation: ""}}
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name,@user.name
    assert_equal email,@user.email
  end
end
