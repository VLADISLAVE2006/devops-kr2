#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
if [[ -e .env ]]; then
    echo 'Файл .env уже существует; сохранён без изменений.'
    exit 0
fi
umask 077
set -o noclobber
printf 'REDIS_PASSWORD=%s\n' "$(openssl rand -hex 32)" > .env
echo 'Создан .env с правами 600. Значение пароля не выводится.'
