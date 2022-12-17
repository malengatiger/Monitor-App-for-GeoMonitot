echo "🔵🔵starting LocalDriver ..."
echo "🔵🔵setting LocalDriver environment variables ..."

export urlPrefix=http://localhost:8080/
export intervalInSeconds=10
export minutesAgo=60
export periodInMinutes=60
export upperCount=250

echo "🔵🔵 cd to LocalDriver jar folder location ..."
cd /Users/aubreymalabie/Work/localdriver_jar || exit

echo "🔵🔵🔴 running LocalDriver ... 🔴"
java -jar localdriver.jar

echo "🔵🔵Are we there yet? 🔴"

