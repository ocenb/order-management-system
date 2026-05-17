class OrderPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(deleted_at: nil)
    end
  end

  def index?
    user.present?
  end

  def show?
    user.present?
  end

  def update?
    user.operator? || user.manager? || user.admin?
  end

  def cancel?
    user.manager? || user.admin?
  end

  def destroy?
    user.admin?
  end
end
