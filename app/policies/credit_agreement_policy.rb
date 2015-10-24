class CreditAgreementPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def index?
    true
  end

  def show?
    user.admin? || user.accountant?
  end

  def create?
    user.admin? || user.accountant?
  end

  def update?
    user.admin? || user.accountant?
  end

  def destroy?
    user.admin? || user.accountant?
  end

  def permitted_params
    [:amount, :interest_rate, :cancellation_period, :account_id]
  end
end