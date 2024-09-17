task test: :environment do
  article = Article.first
  Rails.logger.info "■■■■■■ Batch Test OK: Article title: #{article&.title}"
end