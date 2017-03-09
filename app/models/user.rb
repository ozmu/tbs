class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  require 'rest-client'
  has_many :roles, dependent: :destroy
  has_many :advisors
  has_many :assistant_consultants
  has_one  :profile, dependent: :destroy
  has_many :black_list
  # has_many :club_board_of_directors
  # has_many :club_board_of_supervisory

  mount_uploader :image, ImageUploader

  def admin?
    roles.find_by(role_type_id: RoleType.admin_id).present?
  end

  def advisor?(club_period_id = active_club_periods)
    roles.find_by(club_period_id: club_period_id,
                  role_type_id: RoleType.advisor_id,
                  status: true).present?
  end

  def vice_advisor?(club_period_id = active_club_periods)
    roles.where(club_period_id: club_period_id,
                role_type_id: RoleType.vise_advisor_id,
                status: true).present?
  end

  def president?(club_period_id = active_club_periods)
    roles.where(club_period_id: club_period_id,
                role_type_id: RoleType.president_id,
                status: true).present?
  end

  def member?(club_period_id = active_club_periods)
    roles.where(club_period_id: club_period_id,
                role_type_id: RoleType.member_id,
                status: true).present?
  end

  def dean?
    roles.where(role_type_id: RoleType.dean_id,
                status: true).present?
  end

  def owner_of_role?(role)
    id == role.user.id
  end

  def active_club_periods
    return unless roles.present?
    current_user_roles = roles.includes(:club_period)
    current_user_roles.map do |role|
      if role.try(:club_period).try(:academic_period).try(:is_active)
        role.club_period
      end
    end.uniq
  end

  def president_or_advisor_club_period
    return nil unless president? || advisor?
    roles.select do |role|
      role.try(:club_period).try(:academic_period).try(:is_active) &&
        (role.user.president?(role.club_period) || role.user.advisor?(role.club_period))
    end.first.club_period
  end

  def admin_or_president?
    club_period = president_or_advisor_club_period
    is_active_club = club_period.present? &&
                     club_period.club.club_setting.is_active
    admin? || (president?(club_period) && is_active_club)
  end

  #### Yardımcı Fonksiyonlar
  def full_name
    if is_academic?
      degree.present? ? degree + ' ' + first_name + ' ' + last_name : first_name + ' ' + last_name
    else
      first_name + ' ' + last_name
    end
  end

  def crime?
    profile.crime ? 'Disiplin Cezası Var, Topluluklara Üye Olamaz' : 'Disiplin Cezası Yok, Topluluklara Üye Olabilir'
  end

  def ubs_active?
    is_ubs_active ? 'Aktif' : 'Aktif Değil'
  end

  def name_surname
    "#{first_name} #{last_name}"
  end

  def show_profile?(user)
    user.admin? || user.advisor? || user.president? || user.vice_advisor? unless user.blank?
  end

  def member_block_request(club)
    BlackList.find_by(club_id: club.id, user_id: id)
  end

  def member_blocked?(club)
    member_block_request(club).try(:approved)
  end
end
