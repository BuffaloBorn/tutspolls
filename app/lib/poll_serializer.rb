class PollSerializer

    def self.count_per_month poll
      replies = poll.replies.group_by { |reply| reply.created_at.beginning_of_month }
      binding.pry
      {
        data: []
      }
    end


end
