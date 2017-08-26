class RepliesController < ApplicationController
  def new
      @poll = Poll.find params[:poll_id]
      @reply = @poll.replies.build
  end

  def create
    @reply = @poll.replies.build params[:reply]
    if @reply.save
      redirect_to @poll notice: "Thank you for taking the poll"
    else
      render :new
    end
  end
private
  def reply_params
    params.require(:reply).permit({:poll_id, {answers_attributes: [ :value, :question_id, :reply_id, :possible_answer_id ] })
  end
end
