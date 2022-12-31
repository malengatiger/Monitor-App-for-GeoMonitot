echo "🔵🔵starting LocalDriver ..."
echo "🔵🔵setting LocalDriver environment variables ..."

export urlPrefix=http://localhost:8080/
export periodInMinutes=10
export minutesAgo=30
export maximumTicks=120
export callBigJob=true
export isVerbose=false
export dashboardMinutes=30

echo "🔵🔵 cd to LocalDriver jar folder location ..."
cd /Users/aubreymalabie/Work/localdriver_jar || exit

echo "🔵🔵 🔴 ... running LocalDriver ... 🔴"
java -jar localdriver.jar

echo "🔵🔵 🔴 ....... Are we there yet? 🔴"

