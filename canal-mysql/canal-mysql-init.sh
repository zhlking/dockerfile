#!/bin/bash

#设置数据库变量
MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD
DB_NAME=$CANAL_ADMIN_DATABASE
DB_USER=$CANAL_ADMIN_USER
DB_PASSWD=$CANAL_ADMIN_PASSWORD

# sql脚本
# usage: docker_process_sql [--dont-use-mysql-root-password] [mysql-cli-args]
#    ie: docker_process_sql --database=mydb <<<'INSERT ...'
#    ie: docker_process_sql --dont-use-mysql-root-password --database=mydb <my-file.sql
docker_process_sql() {
	passfileArgs=()
	if [ '--dont-use-mysql-root-password' = "$1" ]; then
		passfileArgs+=( "$1" )
		shift
	fi

	mysql --defaults-extra-file=<( _mysql_passfile "${passfileArgs[@]}") -uroot -hlocalhost "$@"
}

_mysql_passfile() {
	# echo the password to the "file" the client uses
	# the client command will use process substitution to create a file on the fly
	# ie: --defaults-extra-file=<( _mysql_passfile )
	if [ -n "$MYSQL_ROOT_PASSWORD" ]; then
		cat <<-EOF
			[client]
			password="${MYSQL_ROOT_PASSWORD}"
		EOF
	fi
}

#创建数据库已经用户权限
docker_setup_db() {
  #创建数据库
	if [ -n "$DB_NAME" ]; then
		mysql_note "创建数据库： ${DB_NAME}"
		docker_process_sql --database=mysql <<<"CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` ;"
	fi
  #创建用户
	if [ -n "$DB_USER" ] && [ -n "$DB_PASSWD" ]; then
		mysql_note "创建用户： ${DB_USER}"
		docker_process_sql --database=mysql <<<"CREATE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASSWD' ;"

		if [ -n "$DB_NAME" ]; then
			mysql_note "授权 ${DB_USER} 访问 ${DB_NAME} 库"
			docker_process_sql --database=mysql <<<"GRANT ALL ON \`${DB_NAME//_/\\_}\`.* TO '$DB_USER'@'%' ;"
		fi

    docker_process_sql --dont-use-mysql-root-password --database="${DB_NAME}" </tmp/canal_manager.sql

		docker_process_sql --database=mysql <<<"FLUSH PRIVILEGES ;"
		mysql_note "${DB_NAME}数据库创建完成，已授权给${DB_USER}"
	fi
}

/etc/init.d/mysql restart
docker_setup_db