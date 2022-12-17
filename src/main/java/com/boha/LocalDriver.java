package com.boha;

import com.boha.models.City;
import com.boha.models.CityAggregate;
import com.boha.models.DashboardData;
import com.boha.models.GenerationMessage;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import org.joda.time.DateTime;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.Map;
import java.util.Random;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.TimeUnit;
import java.util.logging.Logger;

import static java.time.temporal.ChronoUnit.SECONDS;

public class LocalDriver {

    static final Logger LOGGER = Logger.getLogger(LocalDriver.class.getSimpleName());
    static final Gson GSON = new GsonBuilder().setPrettyPrinting().create();
    static String urlPrefix;
    static int minutesAgo, intervalInSeconds, periodInMinutes;
    static int upperCount;

    public static void main(String[] args) throws Exception {
        LOGGER.info("\uD83C\uDF3C\uD83C\uDF3C\uD83C\uDF3C " +
                "LocalDriver starting, get environment parameters .... \uD83E\uDD6C\uD83E\uDD6C");

        //urlPrefix=http://localhost:8080/;periodInMinutes=60;intervalInSeconds=10;minutesAgo=60;upperCount=350
        Map<String, String> env = System.getenv();
        urlPrefix = env.get("urlPrefix");
        intervalInSeconds = Integer.parseInt(env.get("intervalInSeconds"));
        periodInMinutes = Integer.parseInt(env.get("periodInMinutes"));
        minutesAgo = Integer.parseInt(env.get("minutesAgo"));
        upperCount = Integer.parseInt(env.get("upperCount"));

        LOGGER.info("\uD83D\uDD35\uD83D\uDD35 urlPrefix: " + urlPrefix + " minutesAgo: " + minutesAgo);
        LOGGER.info("\uD83D\uDD35\uD83D\uDD35 intervalInSeconds: " + intervalInSeconds
                + " periodInMinutes: " + periodInMinutes + " upperCount: " + upperCount);

        httpClient = HttpClient.newHttpClient();
        try {
            startGeneration(TimeUnit.SECONDS.toMillis(intervalInSeconds),
                    TimeUnit.MINUTES.toMillis(periodInMinutes));
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    static HttpClient httpClient;

    //create new dashboard at periodic intervals
    private static void startDashboard() {
        LOGGER.info("\uD83C\uDF50\uD83C\uDF50\uD83C\uDF50\uD83C\uDF50 ....... " +
                "starting Dashboard ........... " + DateTime.now().toDateTimeISO().toString());
        try {
            String res = sendRequest("addDashboardData?minutesAgo=" + minutesAgo, 180);
            DashboardData data = GSON.fromJson(res, DashboardData.class);
            LOGGER.info(E.ORANGE_HEART + E.ORANGE_HEART + E.ORANGE_HEART
                    + " DashboardData: " + GSON.toJson(data));

        } catch (Exception e) {
            LOGGER.severe("\uD83D\uDD34 \uD83D\uDD34 \uD83D\uDD34 We have a network or server problem: " + e.getMessage());
            throw new RuntimeException(e);
        }
    }

    private static String sendRequest(String urlSuffix, int timeOut) throws Exception {
        HttpRequest request = HttpRequest.newBuilder()
                .uri(new URI(urlPrefix + urlSuffix))
                .timeout(Duration.of(timeOut, SECONDS))
                .GET()
                .build();
        LOGGER.info("\uD83C\uDF00\uD83C\uDF00 final url to send: " + request.uri().toString());
        long start = System.currentTimeMillis();
        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());


        long end = System.currentTimeMillis();
        double elapsed = Double.parseDouble(String.valueOf((end - start) / 1000));
        LOGGER.info("\uD83C\uDF50\uD83C\uDF50 Response statusCode:"
                + response.statusCode() + " " + E.AMP + E.AMP + " Elapsed time: " + elapsed + " seconds");

        return response.body();
    }

    //create new city aggregates at periodic intervals
    private static void startAggregate() {
        LOGGER.info("\uD83C\uDF3C\uD83C\uDF3C\uD83C\uDF3C ... creating Aggregates: "
                + DateTime.now().toDateTimeISO().toString() + ", " +
                "\uD83D\uDD34\uD83D\uDD34\uD83D\uDD34 this takes a few minutes to calculate ");

        try {
            String res = sendRequest("createAggregatesForAllCities?minutesAgo="
                    + (minutesAgo + 15), 9000);
            CityAggregate[] cityArray = GSON.fromJson(res, CityAggregate[].class);
            LOGGER.info("\uD83C\uDF3C\uD83C\uDF3C\uD83C\uDF3C " +
                    "Total city aggregates calculated: " + cityArray.length);

            if (cityArray.length > 0) {
                LOGGER.info("\uD83C\uDF3C\uD83C\uDF3C\uD83C\uDF3C " +
                        "First aggregate(sample): " + GSON.toJson(cityArray[0]));
            }
            for (CityAggregate ca : cityArray) {
                String name = ca.getCityName();
                if (name.contains("Cape Town")
                        || name.contains("Sandton")
                        || name.contains("Durban")) {
                    LOGGER.info("\uD83C\uDF3C\uD83C\uDF3C\uD83C\uDF3C " +
                            name + " - Aggregate: " + GSON.toJson(ca));
                }
            }
        } catch (Exception e) {
            LOGGER.severe("\uD83D\uDD34 \uD83D\uDD34 \uD83D\uDD34 " +
                    "We have a network or server problem: " + e.getMessage());
            throw new RuntimeException(e);
        }
    }

    public static void startGeneration(long delay, long period) throws Exception {
        LOGGER.info("\n\n\uD83D\uDD06\uD83D\uDD06\uD83D\uDD06\uD83D" +
                "\uDD06\uD83D\uDD06\uD83D\uDD06\uD83D\uDD06\uD83D\uDD06" +
                " ... starting Generator ..." + DateTime.now().toDateTimeISO().toString());
        String result = sendRequest("getCities", 90000);
        LOGGER.info("\uD83D\uDD06\uD83D\uDD06\uD83D\uDD06  \uD83E\uDD6C cities json: \n" + result);
        City[] cityArray = GSON.fromJson(result, City[].class);
        LOGGER.info("\uD83D\uDD06\uD83D\uDD06\uD83D\uDD06  \uD83E\uDD6C cities found: " + cityArray.length);

        try {
            Timer timer = new Timer();
            timer.scheduleAtFixedRate(new TimerTask() {
                @Override
                public void run() {
                    LOGGER.info("\uD83D\uDD06\uD83D\uDD06\uD83D\uDD06 " +
                            "Generator timer tick: " + new DateTime().toDateTimeISO().toString());
                    generate(cityArray);

                }
            }, delay, period);

        } catch (Exception e) {
            LOGGER.severe("\uD83D\uDD34 \uD83D\uDD34 \uD83D\uDD34 " +
                    "We have a network or server problem: " + e.getMessage());
            throw new RuntimeException(e);
        }
    }

    static Random random = new Random(System.currentTimeMillis());

    private static void generate(City[] cityArray) {
        long start = System.currentTimeMillis();
        for (City city : cityArray) {
            int mCount = random.nextInt(upperCount);
            if (mCount == 0) mCount = 100;
            LOGGER.info("\uD83D\uDD06\uD83D\uDD06 Generating " + mCount + " events for city: " + city.getCity());

            String name = city.getCity();
            if (name.contains("Cape Town")) {
                mCount = mCount + 500;
            }
            if (name.contains("Sandton")) {
                mCount = mCount + 500;
            }
            if (name.contains("Durban")) {
                mCount = mCount + 400;
            }
            if (name.contains("Rustenburg")) {
                mCount = mCount + 60;
            }
            if (name.contains("Jeffery")) {
                mCount = mCount + 200;
            }
            if (name.contains("Mossel")) {
                mCount = mCount + 100;
            }
            if (name.contains("Hermanus")) {
                mCount = mCount + 300;
            }
            if (name.contains("Centurion")) {
                mCount = mCount + 200;
            }
            if (name.contains("Klerksdorp")) {
                mCount = mCount + 50;
            }
            if (name.contains("Pretoria")) {
                mCount = mCount + 120;
            }
            try {
                String res = sendRequest(
                        "generateEventsByCity?cityId=" + city.getId()
                                + "&count=" + mCount, 90000);
                GenerationMessage gm = GSON.fromJson(res, GenerationMessage.class);
                LOGGER.info(E.BLUE_HEART + E.BLUE_HEART + E.BLUE_HEART
                        + " GenerationMessage: " + GSON.toJson(gm));
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        }
        long end = System.currentTimeMillis();
        double elapsed = Double.parseDouble(String.valueOf((end - start) / 1000));
        LOGGER.info("\uD83D\uDD06\uD83D\uDD06\uD83D\uDD06 ... " +
                "Generation elapsed time: " + elapsed + " seconds, will start dashboard & aggregates");
        //start the rest of the work
        startDashboard();
        startAggregate();
        LOGGER.info("\n\n\uD83C\uDF00\uD83C\uDF00\uD83C\uDF00\uD83C\uDF00\uD83C\uDF00\uD83C\uDF00" +
                " Everything wrapped up for this cycle - " + DateTime.now().toDateTimeISO().toString() +
                " \uD83C\uDF00\uD83C\uDF00\uD83C\uDF00\uD83C\uDF00\n\n");
    }
}

