class BoardsController < ApplicationController
  load_and_authorize_resource :board, except: [:create]
  before_action :find_board!, only: [:show, :edit, :update, :destroy, :export, :members]

  def index
    @boards = Board.filter(params[:filter], current_user)
      .search(params[:search])
      .sorting(params[:sort])
      .paginate(page: params[:page])
  end

  def show
    @columns = @board.columns.order(position: :asc) 
  end

  def new
    @board = Board.new
  end

  def edit; end

  def create
    @board = Boards::CreateService.call(current_user, board_params)
    if @board.errors.empty?
      redirect_to @board 
    else
      render 'new'
    end
  end

  def update
    if @board.update(board_params)
      flash[:success] = 'Successfully updated!'
      redirect_to @board
    else
      render 'edit'
    end
  end

  def destroy
    if @board.destroy
      flash[:success] = 'Successfully deleted!'
      redirect_to @board
    else
      flash[:error] = "Something went wrong, the acticle wasn't deleted"
    end
  end

  def export
    if !params[:export_id].nil?
      BoardJobs::ExportJob.perform_later(params[:export_id], @board)
    else
      BoardJobs::ExportMailJob.perform_later(current_user.email, @board)
    end
  end

  def members
    respond_to do |f|
      f.json { render json: @board.users }
    end
  end

  private

  def find_board!
    @board = Board.find(params[:id])
  end

  def board_params
    params.require(:board).permit(:title, :description, :public)
  end
end
