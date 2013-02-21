class User < ActiveRecord::Base
  attr_accessible :name, :email, :password, :password_confirmation, :admin 

  attr_accessor :password  
  before_create { generate_token(:auth_token) }

  before_save :encrypt_password

  validates_confirmation_of :password  
  validates_presence_of :password, :on => :create
  validates_presence_of :name 
  validates_uniqueness_of :name  
  validates_presence_of :email  
  validates_uniqueness_of :email  

  
  # encrypt the password using bcrypt
  def encrypt_password  
    if password.present?  
      self.password_salt = BCrypt::Engine.generate_salt  
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)  
    end  
  end
  # authenticate users using bcrypt do decypher the password
  def self.authenticate(name, password)  
    user = find_by_name(name)  
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)  
      user  
    else  
      nil  
    end  
  end  

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end
  
  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.password_reset(self).deliver
  end

end  


