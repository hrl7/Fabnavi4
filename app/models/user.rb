class User < ActiveRecord::Base
  validates :name , length:{maximum:10, minimum:2}
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:persona]

  has_many :project


  def update_with_password (params, *options)
    if encrypted_password.blank?
      update_attrributes(params, *options)
    else
      super
    end
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name
    end
  end

end
