require "fileutils"

namespace :docker do
  BASE_COMPOSE = "docker compose -f docker-compose.yaml".freeze
  DEV_COMPOSE = "#{BASE_COMPOSE} -f docker-compose.override.yaml".freeze

  desc "Create .env from .env.example if missing"
  task :prepare_env do
    next if File.exist?(".env")

    unless File.exist?(".env.example")
      abort ".env.example not found"
    end

    FileUtils.cp(".env.example", ".env")
    puts "Created .env from .env.example"
  end

  desc "Alias for docker:dev_db_up"
  task db: :dev_db_up

  desc "Start PostgreSQL container for development (with override)"
  task dev_db_up: :prepare_env do
    sh "#{DEV_COMPOSE} up -d postgres"
  end

  desc "Start Redis container for development (with override)"
  task dev_redis_up: :prepare_env do
    sh "#{DEV_COMPOSE} up -d redis"
  end

  desc "Start infrastructure for development (with override)"
  task dev_infra_up: %i[dev_db_up dev_redis_up]

  desc "Start Sidekiq worker container for development (with override)"
  task dev_worker_up: :prepare_env do
    sh "#{DEV_COMPOSE} up -d worker"
  end

  desc "Start web container for development (with override)"
  task dev_web_up: :prepare_env do
    sh "#{DEV_COMPOSE} up -d web"
  end

  desc "Start PostgreSQL container for production-like run (base compose only)"
  task prod_db_up: :prepare_env do
    sh "#{BASE_COMPOSE} up -d postgres"
  end

  desc "Start Redis container for production-like run (base compose only)"
  task prod_redis_up: :prepare_env do
    sh "#{BASE_COMPOSE} up -d redis"
  end

  desc "Start infrastructure for production-like run (base compose only)"
  task prod_infra_up: %i[prod_db_up prod_redis_up]

  desc "Start Sidekiq worker container for production-like run (base compose only)"
  task prod_worker_up: :prepare_env do
    sh "#{BASE_COMPOSE} up -d worker"
  end

  desc "Start web container for production-like run (base compose only)"
  task prod_web_up: :prepare_env do
    sh "#{BASE_COMPOSE} up -d web"
  end
end
