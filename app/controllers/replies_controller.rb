class RepliesController < ApplicationController
  before_action :set_poll

  def new
      @poll = Poll.find params[:poll_id]
      @reply = @poll.replies.build
    #  @poll.questions.each {|question| @reply.answers.build question: question}
      @poll.questions.each do |question|
          @reply.answers.build question: question
      end
  end

  def create
    @poll = Poll.find params[:poll_id]
    @reply = @poll.replies.build reply_params
    if @reply.save
     redirect_to @poll, notice: "Thank you for taking the poll."
    else
      render :new
    end
  end
private
  def set_poll
    @poll = Poll.find params[:poll_id]
  end

  def reply_params
      params.require(:reply).permit(:poll_id, {
        answers_attributes: [ :value, :question_id, :reply_id, :possible_answer_id ] })
    end
end
