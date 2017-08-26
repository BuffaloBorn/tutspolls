desc "Clean up datatables"
namespace :tutspolls do
  task :db_clean  => [:environment] do
      PossibleAnswer.where('title IS NULL').destroy_all
      Question.where('title IS NULL').destroy_all
      Poll.where('title IS NULL').destroy_all
      puts "Done removing all NULL records from DB tables"
  end
end
