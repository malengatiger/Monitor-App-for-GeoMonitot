echo "🔵🔵starting LocalDriver ..."
echo "🔵🔵setting LocalDriver environment variables ..."

export urlPrefix=http://localhost:8080/
export periodInMinutes=60
export minutesAgo=120
export upperCount=300
export maximumTicks=36
export callBigJob=true
export isVerbose=false

echo "🔵🔵 cd to LocalDriver jar folder location ..."
cd /Users/aubreymalabie/Work/localdriver_jar || exit

echo "🔵🔵 🔴 ... running LocalDriver ... 🔴"
java -jar localdriver.jar

echo "🔵🔵 🔴 ....... Are we there yet? 🔴"

