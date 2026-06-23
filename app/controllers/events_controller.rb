class EventsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_event, only: [:show, :edit, :update, :destroy, :participate, :cancel_participate]
  before_action :check_event_owner, only: [:edit, :update, :destroy]

  def index
    @events = Event.includes(:book, :user, :participants).upcoming
  end

  def show
    @participation = @event.participations.find_by(user: current_user) if logged_in?
  end

  def new
    @event = Event.new
  end

  def create
    @event = current_user.events.new(event_params)

    if @event.save
      redirect_to @event, notice: "イベントを作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to @event, notice: "イベントを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy
    redirect_to events_url, notice: "イベントを削除しました"
  end

  def participate
    @participation = @event.participations.build(
      user: current_user,
      comment: params[:comment]
    )

    if @participation.save
      EventMailer.participation_confirmation(@participation).deliver_later
      redirect_to @event, notice: 'イベントに参加しました。確認メールを送信しました。'
    else
      redirect_to @event, alert: @participation.errors.full_messages.join(', ')
    end
  end

  def cancel_participate
    @participation = @event.participations.find_by(user: current_user)

    if @participation
      @participation.destroy
      redirect_to @event, notice: "参加をキャンセルしました"
    else
      redirect_to @event, alert: "このイベントに参加していません"
    end
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def check_event_owner
    unless @event.created_by?(current_user)
      redirect_to @event, alert: "このイベントを編集する権限がありません"
    end
  end

  def event_params
    params.require(:event).permit(
      :name, :description, :location, :capacity,
      :start_at, :end_at, :image_url, :book_id
    )
  end
end

