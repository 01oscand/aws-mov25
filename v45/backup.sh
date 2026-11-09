#!/usr/bin/env bash
# Novatrix v45: kör PÅ EC2. Använd: bash backup.sh <RDS-ENDPOINT>
# Skriver INGA lösenord i kod, filer eller kommandoradsargument.
set -euo pipefail
if [[ $# -ne 1 ]]; then echo "Använd: bash backup.sh <RDS-ENDPOINT>" >&2; exit 2; fi
RDS_ENDPOINT="$1"
BUCKET="novatrix-backup-01oscand-01"
if command -v mariadb-dump >/dev/null 2>&1; then DUMP=mariadb-dump;
elif command -v mysqldump >/dev/null 2>&1; then DUMP=mysqldump;
else echo 'Installera MariaDB-klienten först.' >&2; exit 1; fi
umask 077
TMP_FILE="$(mktemp /tmp/novatrix-wordpress-v45-XXXXXX.sql)"
trap 'rm -f "$TMP_FILE"' EXIT
"$DUMP" --single-transaction --quick --host="$RDS_ENDPOINT" --user=admin -p wordpress > "$TMP_FILE"
OBJECT="wordpress-$(date -u +%Y%m%dT%H%M%SZ).sql"
aws s3 cp "$TMP_FILE" "s3://$BUCKET/backup/$OBJECT" --region eu-north-1
aws s3 ls "s3://$BUCKET/backup/" --region eu-north-1
echo "Backup uppladdad: backup/$OBJECT (lokal temporär fil raderas)."
