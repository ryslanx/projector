class BoardsController < ApplicationController
	before_action :find_board, only: [:show, :edit,:update, :destroy]

  def index 
    if params.has_key? :search
      @input = params[:search]
      @boards = Board.search(@input)
    elsif params.has_key? :filter
      case params[:filter]
      when "my_boards"
        @boards = Board.user_boards(1)
      when "private_boards"
        @boards = Board.is_public?(false).user_boards(1)
      when "public_boards"
        @boards = Board.is_public?(true)
      end
    else
      @boards = Board.all
    end

      @private_boards = @boards.is_public?(false)
      @public_boards = @boards.is_public?(true)
  end

  def show
  end

  def new
    @board = Board.new
  end

  def edit
  end

  def create
    @board = Board.new(board_params)
    # @board.user_id = current_user.id
    @board.user_id = 2
    if @board.save
      redirect_to @board
    else
      render 'new'
    end
  end

  def update
    flash[:success] = "Successfully updated!"
    if @board.update(board_params)
      redirect_to @board
    else
      render 'edit'
    end
  end

  def destroy
    if @board.destroy
      flash[:success] = "Successfully deleted!"
      redirect_to @board
    else
      flash[:error] = "Something went wrong, the acticle wasn't deleted"
    end
  end

private

  def find_board
    @board = Board.find(params[:id])
  end

  def board_params
    params.require(:board).permit(:title, :description, :search, :is_public)
  end
end