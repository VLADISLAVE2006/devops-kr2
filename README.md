# КР2 — вариант 2

Flask + Redis: `https://notes.devops.local`, порт приложения 8002, STUDENT=Ivanov.

На хосте имя `notes.devops.local` должно указывать на Host-only адрес VM
(`192.168.56.103` на проверенном стенде). SSH: пользователь devops, порт 2222,
аутентификация ключом. UFW оставляется без изменений.

Доставить проект в `~/kr2`, исключив `.git` и `.env` из rsync, в том числе
из удаления с `--delete`. Далее на VM от имени devops:

```bash
cd ~/kr2
bash scripts/prepare-env.sh
docker compose config --quiet
docker compose up -d --build
bash scripts/publish-nginx.sh
docker compose ps
docker compose exec -T --interactive=false app id
docker compose exec -T --interactive=false app getent hosts redis
```

Сценарий создаёт новый случайный пароль в серверном `.env` с правами 600.
Существующий файл сохраняется. Пароль из истории исходного шаблона не применяется.
Не выводить полный `docker compose config`: он содержит подставленный секрет.
Приложение публикуется только на `127.0.0.1:8002`, Redis не публикуется.
Данные Redis сохраняются в томе `kr2_redis_data` с AOF.

Клиентская проверка после копирования только открытого сертификата:

```bash
scp devops:/etc/ssl/certs/kr2.crt ~/kr2.crt
curl -I http://notes.devops.local/
curl --fail --cacert ~/kr2.crt https://notes.devops.local/
curl --fail --cacert ~/kr2.crt https://notes.devops.local/whoami
```

`/whoami` должен показывать `scheme: https` и `host: notes.devops.local`.
Без доверия самоподписанному сертификату ожидается ошибка TLS.
Проверка сохранения данных: запросить счётчик, выполнить `docker compose down`
без `-v`, затем `docker compose up -d` и повторить запрос. `down -v` удаляет данные.

Расширенный аудит сервера из репозитория курса:

```bash
cd ~/devops-course-2026
sudo env HOME=/home/devops bash scripts/audit.sh 8
```

Проверены UID 999 приложения, DNS Redis, отказ NOAUTH без пароля, сохранение
счётчика после пересоздания и перезагрузки VM, SAN сертификата, HTTP 301,
недоступность внешних портов 8002/6379, неизменность UFW и прежних ресурсов.
Аудит: 23 успешные проверки; неправильная публикация 8002 обнаруживается с кодом 1.
Pull Request остаётся открытым до защиты.
