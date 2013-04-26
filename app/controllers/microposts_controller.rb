class MicropostsController < ApplicationController
  # before_filter :signed_in_user
  before_filter :correct_user, only: :destroys


  def create
    @micropost = current_user.microposts.build(params[:micropost])
    # @micropost.generate_provenance


    if @micropost.save
      flash[:success] = "Micropost created!"
      # redirect_to root_path
      redirect_to micropost_generate_provenance_path(@micropost.id)
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end


  def generate_provenance

    @micropost = Micropost.find(params[:micropost_id])
    @micropost.generate_provenance

    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_path
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end

  def destroy

    @micropost = current_user.microposts.find_by_id(params[:id])

    @micropost.destroy
    redirect_to root_path
  end

  private

    def correct_user
      @micropost = current_user.microposts.find_by_id(params[:id])
      redirect_to root_path if @micropost.nil?
    end
end