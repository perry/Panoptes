class ApiUser
  include RoleControl::Actor
  
  attr_reader :user

  delegate :memberships_for, :owns?, :id, :languages, :user_groups,
           :project_preferences, :collection_preferences, :classifications,
           :user_groups, to: :user, allow_nil: true

  def initialize(user, admin: false)
    @user, @admin_flag = user, admin
  end

  def logged_in?
    !!user
  end
  
  def owner
    user
  end

  def is_admin?
    logged_in? && user.is_admin? && @admin_flag
  end

  def banned?
    logged_in? && user.banned
  end
end
