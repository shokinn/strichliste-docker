#!/bin/bash
set -eu -o pipefail

# original source Lyman Lai
# http://002.yaha.me/item/22728a58-c967-46d5-93eb-2649d684a9aa/
# edited by G Pugh 2019-01-15
# edited by Philip Henning 2022-06-02


STORE_FOLDER="/db_backups"

TODAY=$(date +"%Y-%m-%d")
DAILY_DELETE_NAME="daily-"`date +"%Y-%m-%d" --date '7 days ago'`
WEEKLY_DELETE_NAME="weekly-"`date +"%Y-%m-%d" --date '5 weeks ago'`
MONTHLY_DELETE_NAME="monthly-"`date +"%Y-%m-%d" --date '12 months ago'`

MHOST=${MYSQL_CONTAINER_NAME}
MPASS=${MYSQL_ROOT_PASSWORD}
MUSER=root

databases=($(/usr/bin/mysql -h ${MHOST} -u ${MUSER} -p${MPASS} -Bse "show databases" | grep -i -v "_schema" | grep -i -v "sys" | grep -i -v "mysql"))

function do_backups() {
  # Get db name or "all"
  backup_db=$1

  # run dump
  if [ "$backup_db" == "all" ]; then
    BACKUP_PATH=$STORE_FOLDER/all
    [[ ! -d "$BACKUP_PATH" ]] && mkdir -p "$BACKUP_PATH"
  	echo "   Creating $BACKUP_PATH/daily-$TODAY.sql.gz"
    /usr/bin/mysqldump -h ${MHOST} -u ${MUSER} -p${MPASS} --all-databases | gzip -9 > $BACKUP_PATH/daily-$TODAY.sql.gz
  else
    BACKUP_PATH=$STORE_FOLDER/$db
    [[ ! -d "$BACKUP_PATH" ]] && mkdir -p "$BACKUP_PATH"
  	echo "   Creating $BACKUP_PATH/daily-$TODAY.sql.gz"
    /usr/bin/mysqldump -h ${MHOST} -u ${MUSER} -p${MPASS} $db | gzip -9 > $BACKUP_PATH/daily-$TODAY.sql.gz
  fi

  # delete old backups
  if [ -f "$BACKUP_PATH/$DAILY_DELETE_NAME.sql.gz" ]; then
  	echo "   Deleting $BACKUP_PATH/$DAILY_DELETE_NAME.sql.gz"
  	rm -rf $BACKUP_PATH/$DAILY_DELETE_NAME.sql.gz
  fi
  if [ -f "$BACKUP_PATH/$WEEKLY_DELETE_NAME.sql.gz" ]; then
	echo "   Deleting $BACKUP_PATH/$WEEKLY_DELETE_NAME.sql.gz"
    rm -rf $BACKUP_PATH/$WEEKLY_DELETE_NAME.sql.gz
  fi
  if [ -f "$BACKUP_PATH/$MONTHLY_DELETE_NAME.sql.gz" ]; then
	echo "   Deleting $BACKUP_PATH/$MONTHLY_DELETE_NAME.sql.gz"
    rm -rf $BACKUP_PATH/$MONTHLY_DELETE_NAME.sql.gz
  fi

  # make weekly
  if [ `date +%u` -eq 7 ];then
    cp $BACKUP_PATH/daily-$TODAY.sql.gz $BACKUP_PATH/weekly-$TODAY.sql.gz
  fi

  # make monthly
  if [ `date +%d` -eq 25 ];then
    cp $BACKUP_PATH/daily-$TODAY.sql.gz $BACKUP_PATH/monthly-$TODAY.sql.gz
  fi

}

echo "*** MySQL Backups"
echo
echo "To be deleted if present:"
echo "   $DAILY_DELETE_NAME"
echo "   $WEEKLY_DELETE_NAME"
echo "   $MONTHLY_DELETE_NAME"
echo

# Entire backup
echo "Starting complete MySQL backup..."
do_backups all

# Individual db backups
for db in "${databases[@]}"; do
  echo "Starting $db MySQL backup..."
  do_backups $db
done
