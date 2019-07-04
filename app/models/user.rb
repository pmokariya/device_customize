class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :lockable,
         :recoverable, :rememberable, :validatable, :timeoutable

  # password history
  include ActiveModel::Validations
  has_many :password_histories
  after_save :store_digest
  validates :password, :unique_password => true

  # username login
  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value", { :value => login.downcase }]).first
    else
      if conditions[:username].nil?
        where(conditions).first
      else
        where(username: conditions[:username]).first
      end
    end
  end

  # logout after 2 days
  def timeout_in
    # return 1.year if admin?
    2.days
  end
  private
  
  # password history
  def store_digest
    # puts "...1...#{self.password}.............#{self.username}.."
    # puts ".3.........#{encrypted_password}..."
    # puts ".2........#{encrypted_password_changed?}..."
    if self.password != self.username
      if encrypted_password.present?
        PasswordHistory.create(:user => self, :encrypted_password => encrypted_password)
        # puts "...4.....#{PasswordHistory.last}......."
      end
      @user_all_password = self.password_histories.order(created_at: :asc).collect(&:id)
      @last_password = self.password_histories.order(created_at: :asc).last(6).collect(&:id)
      # puts "...8...#{@user_all_password}.....#{@last_password}.."
      @extra_password = @user_all_password - @last_password
      # puts "...7...#{@extra_password}......."
      PasswordHistory.where(id: @extra_password).destroy_all
    else
      self.errors[:password] << "must be diffrent then username."
    end
  end
end
