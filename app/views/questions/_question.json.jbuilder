json.extract! question, :id, :title, :kind, :created_at, :updated_at
json.url question_url(question, format: :json)
