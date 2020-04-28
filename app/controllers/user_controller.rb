# frozen_string_literal: true

class UserController < ApplicationController
  def index
    @users = User.search(params[:search]).limit(10)

    respond_to do |foramt|
      foramt.json { render json: @users }
    end
  end
end