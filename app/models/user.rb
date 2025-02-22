class User < ApplicationRecord
  has_many :microposts,dependent: :destroy
  has_many :active_relationships, class_name:"Relationship",
                  foreign_key: 'follower_id',
                  dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship",
                  foreign_key: 'followed_id',
                  dependent: :destroy
  has_many :following,through: :active_relationships,source: :followed
  has_many :followers,through: :passive_relationships,source: :follower
  
  attr_accessor :remember_token,:activation_token,:reset_token
  before_save :downcase_email
  before_create :create_activation_digest
  validates :name,presence: true,length: {maximum: 50}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email,presence: true,length: {maximum: 255},
            format: {with: VALID_EMAIL_REGEX},
            uniqueness: true
  has_secure_password
  validates :password,presence: true,length: {minimum: 6},allow_nil: true

  #渡された文字列のハッシュを返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  #ランダムなトークンを返す
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  #永続セッションのためにユーザをデータベースに記憶する
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest,User.digest(remember_token))
  end

  #渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(attribute,token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  #ユーザログイン情報を破棄する
  def forget
    update_attribute(:remember_digest,nil)
  end

  #アカウントを有効にする
  def activate
    update_columns(activated: true,activated_at: Time.zone.now)
  end

  #パスワード再設定の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token),reset_sent_at: Time.zone.now)
  end

  #パスワード再設定のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  #有効化メールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  #パスワード再設定の期限が切れている場合はtrueを返す
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  #試作feedの定義
  # ユーザーのステータスフィードを返す
  def feed
    #下記はただの文字列
    part_of_feed = "relationships.follower_id = :id or microposts.user_id = :id"
    Micropost.joins(user: :followers).where(part_of_feed, { id: id })
  end

  #ユーザーをフォローする
  def follow(other_user)
    following << other_user
  end

  #ユーザをフォローを解除する
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  #現在のユーザがフォローしていたらtrueを返す
  def following?(other_user)
    following.include?(other_user)
  end

  private

    def downcase_email
      self.email.downcase!
    end
    
    def create_activation_digest
      #有効化トークンとダイジェストを作成及代入する
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
