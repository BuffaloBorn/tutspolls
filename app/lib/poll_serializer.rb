class PollSerializer
  def self.count_per_month poll
      polls_per_month = poll.replies.group_by { |reply|
        reply.created_at.beginning_of_month }

      data = polls_per_month.map { |k,v| v.size }

      {
        data: data,
        title: "Polls answered by month",
        x_axis: {
          legend: "Polls per month",
          series: polls_per_month.keys.map { |date| date.strftime("%b %Y") }
        },
        y_axis: {
          legend: "No. polls",
          scale: [0, data.max + 1]
        }
      }
    end
end
