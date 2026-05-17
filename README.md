# Order Management System

Backend-сервис для операционного управления заказами интернет-магазина.
Система принимает заказы через API, сохраняет их в PostgreSQL, обрабатывает в фоне через Sidekiq и отправляет email-уведомления после успешной обработки.
Для внутренних пользователей есть админ-панель с ролевым доступом (`operator`, `manager`, `admin`).

## Что решает проект
- централизует полный жизненный цикл заказа от приема до финального статуса;
- предотвращает дубли заказов через идемпотентность по паре `source + external_id`;
- отделяет быстрый API-прием заказа от тяжелой фоновой обработки;
- дает прозрачную историю смены статусов и контролируемые ручные действия команды.

## Жизненный цикл заказа
Поддерживаемые статусы:
- `pending` — заказ принят;
- `processing` — заказ обрабатывается;
- `completed` — заказ успешно завершен;
- `failed` — обработка завершилась ошибкой;
- `cancelled` — заказ отменен.

Ключевые переходы:
- `pending -> processing -> completed|failed`;
- `pending|processing -> cancelled`;
- `failed -> processing` (ручной retry из админки).

## Роли в админке
- `operator`: просмотр списка/деталей, базовые действия со статусами;
- `manager`: всё как у operator + редактирование данных заказа и отмена заказа;
- `admin`: всё как у manager + soft delete заказов, управление пользователями и доступ к Sidekiq dashboard.

Подробное описание MVP:
- [docs/DESCRIPTION.md](/home/unix-user/projects/order-management-system/docs/DESCRIPTION.md)

Инструкция деплоя на VPS:
- [docs/DEPLOY_VPS.md](/home/unix-user/projects/order-management-system/docs/DEPLOY_VPS.md)

## Технологии
- Ruby
- Rails
- PostgreSQL
- Redis + Sidekiq
- Devise + Pundit
- RSpec
- Swagger/OpenAPI через rswag (dev)
- Docker Compose

## Быстрый старт (Docker)
1. Создайте `.env`:

```bash
cp .env.example .env
```

1. Убедитесь, что в `.env` выставлены контейнерные хосты:

```env
DB_HOST=postgres
DB_PORT=5432
REDIS_URL=redis://redis:6379/0
```

1. Поднимите инфраструктуру и приложение:

```bash
bin/rake docker:dev_infra_up
bin/rake docker:dev_web_up
bin/rake docker:dev_worker_up
```

1. Подготовьте БД и загрузите seed:

```bash
bin/rake db:prepare
bin/rake db:seed
```

## Локальные URL
- App: [http://localhost:3000](http://localhost:3000)
- Healthcheck: [http://localhost:3000/up](http://localhost:3000/up)
- Swagger UI (dev): [http://localhost:3000/docs](http://localhost:3000/docs)
- OpenAPI YAML (dev): [http://localhost:3000/api-docs/v1/swagger.yaml](http://localhost:3000/api-docs/v1/swagger.yaml)
- Sidekiq dashboard (только admin): [http://localhost:3000/sidekiq](http://localhost:3000/sidekiq)

## Данные для входа (seed)
После `db:seed`:
- admin: `admin@example.com` / `Password1!`
- manager: `manager@example.com` / `Password1!`
- operator: `operator@example.com` / `Password1!`

API токен (Bearer):
- `secret-token`

## Полезные команды
- Линтинг:

```bash
bin/rubocop
```

- Автоисправление линтинга:

```bash
bin/rubocop -A
```

- Тесты:

```bash
bundle exec rspec
```

- Только e2e:

```bash
bundle exec rspec spec/requests/e2e
```

- Генерация OpenAPI YAML:

```bash
bin/rake rswag:specs:swaggerize
```
