# frozen_string_literal: true

task :test, ['message'] => :environment do |_task, args|
  article = Article.first
  Rails.logger.info "■■■■■■ Batch Test OK: args: #{args&.extras&.join(', ')} Article title: #{article&.title}"
end
