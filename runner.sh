echo "🔵🔵starting LocalDriver ..."
echo "🔵🔵setting LocalDriver environment variables ..."

export urlPrefix=http://localhost:8080/
export minutesAgo=180
export periodInMinutes=60
export upperCount=300
export maximumTicks=25
export callBigJob=true

echo "🔵🔵 cd to LocalDriver jar folder location ..."
cd /Users/aubreymalabie/Work/localdriver_jar || exit

echo "🔵🔵 🔴 ... running LocalDriver ... 🔴"
java -jar localdriver.jar

echo "🔵🔵 🔴 ....... Are we there yet? 🔴"

