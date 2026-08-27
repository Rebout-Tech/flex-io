# FlexIo

Микросервис файлового хранилища организации [Crossdyne](https://github.com/crossdyne).  
Простое и надёжное HTTP API для загрузки, скачивания и управления файлами в S3-совместимых хранилищах. Построен по архитектуре **портов и адаптеров** — бизнес-логика отделена от инфраструктурных деталей.

## Что делает

- Принимает файлы через HTTP API двумя способами: `multipart/form-data` или `base64`.
- Загружает их в S3-совместимое хранилище (RustFS, AWS S3, MinIO, Ceph и др.) через адаптер `ExAws`.
- Отдаёт файлы напрямую бинарным потоком или выдаёт presigned URL для временного доступа.
- Поддерживает batch-генерацию URL для списка файлов (до 100 за раз).
- Валидирует параметры (`bucket`, `folder`, `key`) для защиты от path traversal.
- Работает как supervised OTP-приложение — падает gracefully и перезапускается.

## Архитектура

```
┌─────────────┐     ┌─────────────────┐     ┌─────────────┐
│   Client    │────>│  FlexIoFiles    │────>│  S3 Store   │
│  (HTTP API) │<────│   (Phoenix)     │     │(MinIO/AWS)  │
└─────────────┘     └─────────────────┘     └─────────────┘
```

Основные модули:

| Модуль | Назначение |
|--------|------------|
| `FlexIoFiles.Application` | Точка входа. Запускает супервизор, PubSub и Endpoint. |
| `FlexIoFiles.Storage.Behaviour` | **Порт**. Определяет контракт (`upload`, `download`, `delete`, `generate_url`). |
| `FlexIoFiles.Storage.Service` | Доменный сервис. Валидация параметров, маршрутизация вызовов к адаптеру. |
| `FlexIoFiles.Storage.Adapters.S3` | **Адаптер**. Реализация хранилища через `ExAws.S3`. |
| `FlexIoFilesWeb.FileController` | Контроллер API. Обработка multipart, base64, batch-запросов. |
| `FlexIoFilesWeb.Router` | Маршрутизация endpoints (`/api/files/*`). |
| `FlexIoFilesWeb.Endpoint` | Phoenix endpoint на базе HTTP-сервера Bandit. |

## Требования

- **Elixir** ~> 1.18
- **Erlang/OTP** 25+
- S3-совместимое хранилище (AWS S3, MinIO, Ceph, Selectel и др.)

## Переменные окружения

Все S3-переменные обязательны (читаются в `runtime.exs`):

| Переменная | Описание | Пример |
|------------|----------|--------|
| `S3_ACCESS_KEY` | Access Key для S3-аутентификации | `admin` |
| `S3_SECRET_KEY` | Secret Key для S3-аутентификации | `PASSWORD` |
| `S3_SCHEME` | Протокол (`http://` или `https://`) | `https://` |
| `S3_HOST` | Хост S3-сервера | `s3.amazonaws.com` |
| `S3_PORT` | Порт S3-сервера | `443` |
| `SECRET_KEY_BASE` | Секретный ключ Phoenix (только `prod`)  | `***` (Генерация через `mix phx.gen.secret`) |
| `PHX_HOST` | Внешний хост приложения (только `prod`) | `files.example.com` |
| `PORT` | Порт HTTP-сервера (только `prod`, по умолчанию `4000`) | `4000` |

## Локальная конфигурация

Для локальной разработки создайте файл `.env` в корне сервиса (`services/flex_io_files/.env`):

```bash
S3_ACCESS_KEY=admin
S3_SECRET_KEY=password
S3_SCHEME=http://
S3_HOST=localhost
S3_PORT=8333
```

Переменные подхватываются автоматически (через `dotenvy` при старте приложения).

## API Endpoints

| Метод | Путь | Описание |
|-------|------|----------|
| `POST` | `/api/files/upload` | Загрузка файла (multipart или base64) |
| `GET`  | `/api/files` | Скачивание файла бинарным потоком |
| `DELETE` | `/api/files` | Удаление файла |
| `GET`  | `/api/files/url` | Получение presigned URL для одного файла |
| `POST` | `/api/files/urls` | Batch-генерация presigned URL (до 100 файлов) |

### Формат запросов

**Загрузка (multipart):**
```bash
curl -X POST http://localhost:4000/api/files/upload \
  -F "bucket=my-bucket" \
  -F "folder=uploads/2024" \
  -F "key=document.pdf" \
  -F "file=@/path/to/document.pdf"
```

**Загрузка (base64):**
```json
{
  "bucket": "my-bucket",
  "folder": "uploads/2024",
  "key": "document.pdf",
  "file": "JVBERi0xLjQK...",
  "content_type": "application/pdf"
}
```

**Скачивание / Удаление / URL:**
```
GET    /api/files?bucket=my-bucket&folder=uploads/2024&key=document.pdf
DELETE /api/files?bucket=my-bucket&folder=uploads/2024&key=document.pdf
GET    /api/files/url?bucket=my-bucket&folder=uploads/2024&key=document.pdf&expires=7200
```

**Batch URL:**
```json
POST /api/files/urls
{
  "files": [
    {"bucket": "my-bucket", "folder": "uploads/2024", "key": "a.pdf"},
    {"bucket": "my-bucket", "folder": "uploads/2024", "key": "b.pdf"}
  ],
  "expires": 3600
}
```

Параметр `expires` опционален, по умолчанию `3600` секунд.

## Запуск

### Локально

```bash
cd services/flex_io_files

# Получить зависимости
mix deps.get

# Запуск (переменные из .env подтягиваются автоматически)
mix phx.server
```

### Через Docker

Переменные окружения прокидываются через `docker-compose` (секция `environment` или внешний `.env`-файл для compose):

```bash
# Сборка
docker-compose -f deployment/docker-compose.build.yml build

# Деплой
docker-compose -f deployment/docker-compose.deploy.yml up -d
```

## Структура репозитория

```
flex-io/
├── deployment/                 # Docker Compose для сборки и деплоя
├── services/flex_io_files/     # Исходный код сервиса
│   ├── config/                 # Конфигурация (dev, prod, runtime)
│   ├── lib/
│   │   └── flex_io_files/
│   │       └── storage/
│   │           ├── behaviour.ex      # Порт — контракт хранилища
│   │           ├── service.ex        # Доменная логика и валидация
│   │           └── adapters/
│   │               └── s3.ex         # Адаптер S3
│   ├── lib/flex_io_files_web/
│   │   ├── controllers/
│   │   │   └── file_controller.ex    # HTTP API
│   │   ├── router.ex
│   │   └── endpoint.ex
│   ├── Dockerfile
│   └── mix.exs
└── README.md
```

## Примечания

- **Архитектура портов и адаптеров:** Бизнес-логика (`Storage.Service`) зависит только от поведения (`Storage.Behaviour`). Текущая реализация — S3-адаптер (`ExAws`), но при необходимости можно добавить адаптер для локальной файловой системы, GCS, Azure Blob и т.д., не меняя код сервиса.
- **Тесты:** В проекте отсутствуют тесты — они были сгенерированы шаблоном Phoenix, но удалены, так как сервис достаточно простой. При необходимости в будущем будут добавлены `ExUnit`-тесты для `Storage.Service` и `FileController` с использованием `Mox` для мокирования адаптера.
- **HTML / LiveView:** Отсутствуют. Сервис работает исключительно как JSON API. Модули `FlexIoFilesWeb` содержат минимальный набор для Phoenix-контроллеров.
- **Permanent mode:** В `mix.exs` установлен `start_permanent: Mix.env() == :prod`, поэтому в production-окружении приложение запускается в permanent-режиме OTP.
- **Path Traversal:** Сервис отклоняет ключи, содержащие `..` или начинающиеся с `/`, предотвращая выход за пределы заданной папки в хранилище.