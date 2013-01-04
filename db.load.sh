#############################################################################################
# MySQL Database Loader Script
#
# By David Lohmeyer
# vilepickle@gmail.com
# Vilepickle.com
# 1/4/13
# Version 1.0
#
#############################################################################################
#
# INSTRUCTIONS
# Configure the variables below as required. The MySQL server, user, and password are required.
# Configure the prompt variable if you want to be asked the database file and the database
# name upon execution.  Useful for multiple DB loading.
#
# Place your database file in .gz format alongside this script and execute the script
# to import your DB.
#
# Your DB will be cleared out (not dropped) if it exists and re-loaded from the file.
# If the DB does not exist it will be created first and then loaded.
#
#############################################################################################
#
# Copyright (c) 2013 David Lohmeyer
#
# Permission is hereby granted, free of charge, to any person obtaining a copy 
# of this software and associated documentation files (the "Software"), to deal 
# in the Software without restriction, including without limitation the rights to 
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of 
# the Software, and to permit persons to whom the Software is furnished to do so, 
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all 
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
#############################################################################################

# Define your server variables for MySQL.

SERVER="localhost"
USER="root"
PW="overworked"

#############################################################################################
# If PROMPT is set to 1, the script will ask for DB file
# and DB values.  If not, change the variables below.
PROMPT=0

DBFILENAME="drupal7_acton_es.gz"
DATABASE="drupal7_acton_es"

#############################################################################################
# No need to edit below this line.

if [ $PROMPT = 1 ]
	then
		echo -n "Enter the database .gz file relative to this script..."
		read -e DBFILENAME
		if [ -s $DBFILENAME ]
			then
				echo "File does exist, proceeding..."
			else
				echo "File does not exist!"
				exit 1
		fi

		echo -n "Enter the name of your database..."
		read -e DATABASE
fi

# Check to see if database exists
DBS=`mysql -u$USER -p$PW -h $SERVER -Bse 'show databases'| egrep -v 'information_schema|mysql'`
FOUNDDB=0
for db in $DBS; do
	if [ $db = $DATABASE ]
		then
			# Remove the existing database in favor of the new file.
			# Instead of dropping the DB itself, iterate through
			# the tables and remove them
			# Thanks http://www.thingy-ma-jig.co.uk/blog/10-10-2006/mysql-drop-all-tables for the tip
			FOUNDDB=1
		 	echo "Found the database '$DATABASE', proceeding with removal..."
		 	mysqldump -u$USER -p$PW -h $SERVER --add-drop-table --no-data $DATABASE | grep ^DROP | mysql -u$USER -p$PW -h $SERVER $DATABASE
	fi
done
if [ $FOUNDDB = 0 ]
	then
		# Create a new database
		echo "Didn't find the database, creating '$DATABASE'..."
		mysqladmin -u$USER -p$PW -h $SERVER create $DATABASE
fi

# Load the DB
echo "Importing new database from file '$DBFILENAME'..."
gzip -d $DBFILENAME | mysql -u $USER -p$PW -h $SERVER $DATABASE < $DATABASE
gzip $DATABASE