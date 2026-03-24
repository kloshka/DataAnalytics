# BigDataSnowflake

Лабораторная работа №1 по Big Data: нормализация исходных CSV данных в модель снежинка.

## Что есть в проекте

1. 10 исходных CSV файлов в папке `исходные данные`.
2. `docker-compose.yml` для запуска PostgreSQL.
3. Один SQL-скрипт `sql/init/init.sql`, в котором:
	- создается staging-таблица `public.mock_data`;
	- загружаются данные из 10 CSV;
	- создаются таблицы измерений и таблица фактов;
	- выполняется заполнение измерений и факта;
	- есть базовые проверки и простые аналитические запросы.

## Быстрый запуск

```bash
docker compose up -d
```

## Проверка, что загрузка прошла

```bash
docker exec -it bdsnowflake-postgres psql -U bds_user -d bdsnowflake -c "SELECT COUNT(*) AS mock_data_rows FROM public.mock_data;"
docker exec -it bdsnowflake-postgres psql -U bds_user -d bdsnowflake -c "SELECT COUNT(*) AS fact_rows FROM fact_sales;"
```

Ожидаемо:

1. `mock_data_rows = 10000`
2. `fact_rows = 10000`

## Если нужно пересоздать БД с нуля

```bash
docker compose down -v
docker compose up -d
```
