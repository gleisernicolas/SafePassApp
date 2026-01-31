class EntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_entry, only: [ :show, :edit, :destroy, :update ]

  def new
    @entry = Entry.new(user_id: current_user.id)
  end

  def index
    @entries = current_user.entries.search(params[:name]).order(:name)
    @main_entry = @entries.first

    return unless params[:name].present?

    if @entries.length == 1
      render turbo_stream: [
        turbo_stream.update("main-dashboard", partial: "entries/main", locals: {
          entry: @entries.first
        }),
        turbo_stream.update("entries-list", partial: "entries/entry", locals: {
          entry: @entries.first
        })
      ]
    end
  end

  def create
    @entry = current_user.entries.new(entry_params)

    if @entry.save
      flash.now.notice = "<strong>#{@entry.name}</strong> created successfully".html_safe

      respond_to do |format|
        format.html { redirect_to root_path }
        format.turbo_stream { }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show; end
  def edit; end
  def update
    if @entry.update(entry_params)
      flash.now.notice = "#{@entry.reload.name} has been updated."
      respond_to do |format|
        format.html { redirect_to @entry }
        format.turbo_stream { }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @entry.destroy

    flash.now.notice = "#{@entry.name} deleted successfully"

    respond_to do |format|
      format.html { redirect_to root_path }
      format.turbo_stream { }
    end
  end

  private

  def entry_params
    params.expect(entry: [ :name, :username, :url, :password ])
  end

  def set_entry
    @entry = current_user.entries.find(params[:id])
  end
end
