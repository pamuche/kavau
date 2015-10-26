class UsersController < ApplicationController
  before_action :clear_password_params, only: :update
  include LoadAuthorized
  responders :collection

  def index
    @q = @users.ransack(search_params)
    @users = @q.result(distinct: true).page(params[:page])
    respond_with @users
  end

  def show
    respond_with @user
  end

  def new
    respond_with @user
  end

  def edit
    respond_with @user
  end

  def create
    @user.save
    respond_with @user
  end

  def update
    @user.update(permitted_params)
    respond_with @user, location: after_action_path
  end

  def destroy
    @user.destroy
    respond_with @user
  end

  private
    def default_sort
      {"s" => ["first_name asc", "name asc"]}
    end

    def search_params
      default_sort.merge(params[:q] || {})
    end

    def clear_password_params
      return if password_params_set?
      params[:user].except!(:password, :password_confirmation)
    end

    def password_params_set?
      return false unless params[:user]
      ! params[:user].slice(:password, :password_confirmation).values.all?(&:blank?)
    end

    def after_action_path
      session[:back_url]
    end
end
