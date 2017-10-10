FactoryGirl.define do

  factory :reply do
    poll
  end

  factory :answer do
    possible_answer
    reply
  end

  factory :possible_answer do
    title "Possible Answer"
  end

  factory :question do
    title "Question #"
    kind "choice"

    factory :full_question do
      transient do
        answers_count 5
        possible_answers_count 5
      end

      after(:create) do |question, evaluator|
        create_list :possible_answer, evaluator.possible_answers_count, question: question
        create_list :answer, evaluator.answers_count, question: question, possible_answer_id: 1
      end
    end
  end

  factory :poll do
    title "Testing poll"

    factory :full_poll do

      transient do
        replies_count 5
        questions_count 5
      end

      after(:create) do |poll, evaluator|
        create_list :full_question, evaluator.questions_count, poll: poll
        create_list :reply, evaluator.replies_count, poll: poll
      end
    end
  end
end
