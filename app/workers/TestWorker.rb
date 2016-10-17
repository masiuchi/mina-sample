class TestWorker
  include Sidekiq::Worker

  def perform(key)
    puts key
  end
end
