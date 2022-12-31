package com.boha;

import com.boha.models.*;
import com.boha.util.E;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import org.joda.time.DateTime;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.*;
import java.util.concurrent.TimeUnit;
import java.util.logging.Logger;

import static java.time.temporal.ChronoUnit.MINUTES;
import static java.time.temporal.ChronoUnit.SECONDS;

public class LocalDriver {

    private static final Logger LOGGER = Logger.getLogger(LocalDriver.class.getSimpleName());
    private static final Gson GSON = new GsonBuilder().serializeSpecialFloatingPointValues()
            .serializeNulls()
            .setPrettyPrinting().create();
    private static String urlPrefix;
    private static int minutesAgo;
    private static int upperCount, maximumTicks, dashboardMinutes;
    private static String callBigJob;
    private static boolean isVerbose = true;
    private static int periodInMinutes;

    private static final List<Integer> upperCounts = new ArrayList<>();
    private static final Random random = new Random(System.currentTimeMillis());

    public static void main(String[] args) throws Exception {
        LOGGER.info("\uD83C\uDF3C\uD83C\uDF3C\uD83C\uDF3C " +
                "LocalDriver starting, get environment parameters .... \uD83E\uDD6C\uD83E\uDD6C");
        //create list
        upperCounts.add(150);
        upperCounts.add(200);
        upperCounts.add(410);
        upperCounts.add(140);
        upperCounts.add(160);
        upperCounts.add(80);
        upperCounts.add(130);
        upperCounts.add(240);
        upperCounts.add(100);
        upperCounts.add(250);

        Map<String, String> env = System.getenv();
        urlPrefix = env.get("urlPrefix");
        periodInMinutes = Integer.parseInt(env.get("periodInMinutes"));
        minutesAgo = Integer.parseInt(env.get("minutesAgo"));
//        upperCount = Integer.parseInt(env.get("upperCount"));
        maximumTicks = Integer.parseInt(env.get("maximumTicks"));
        dashboardMinutes = Integer.parseInt(env.get("dashboardMinutes"));
        callBigJob = env.get("callBigJob");
        String v = env.get("isVerbose");
        isVerbose = v.equalsIgnoreCase("true");

        LOGGER.info("\uD83D\uDD35\uD83D\uDD35 urlPrefix: " + urlPrefix + " minutesAgo: " + minutesAgo);
        LOGGER.info("\uD83D\uDD35\uD83D\uDD35 "
                + " periodInMinutes: " + periodInMinutes + " \uD83D\uDD35\uD83D\uDD35 upperCount: " + upperCount);

        httpClient = HttpClient.newHttpClient();
        try {
            startGeneration();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private static HttpClient httpClient;
    //create new dashboard at periodic intervals
    private static DashboardData startDashboard() {
        LOGGER.info(E.AMP+E.AMP+E.AMP+E.AMP+
                " starting Dashboard ........... " + DateTime.now().toDateTimeISO().toString());
        DashboardData data = null;
        try {
            HttpResponse<String> res = sendRequest("addDashboardData?minutesAgo="
                    + dashboardMinutes, 900);
            if (res.statusCode() == 200) {
                data = GSON.fromJson(res.body(), DashboardData.class);
                LOGGER.info(E.AMP+E.AMP+E.AMP+E.AMP
                        + " DashboardData: " + GSON.toJson(data) + "\n");
            } else {
                LOGGER.severe("Problem, statusCode: " + res.statusCode() + " - " + res.body());
            }

        } catch (Exception e) {
            LOGGER.severe("\uD83D\uDD34 \uD83D\uDD34 \uD83D\uDD34 We have a network or server problem: " + e.getMessage());
            throw new RuntimeException(e);
        }
        return data;
    }

    private static void sendGenerateDataRequest(int upperCount) throws Exception {

        HttpRequest request = HttpRequest.newBuilder()
                .uri(new URI(urlPrefix + "generateData?upperCount="+upperCount))
                .timeout(Duration.of(60, MINUTES))
                .GET()
                .build();

        LOGGER.info("\uD83C\uDF00\uD83C\uDF00 final url to send: " + request.uri().toString());
        long start = System.currentTimeMillis();

        try {
            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() == 200) {
                GenerationResultsBag bag = GSON.fromJson(response.body(), GenerationResultsBag.class);

                long end = System.currentTimeMillis();
                double elapsed = Double.parseDouble(String.valueOf((end - start) / 1000));
                LOGGER.info(E.PEAR+E.PEAR+E.PEAR+" Response statusCode:"
                        + response.statusCode() + " " + E.AMP + E.AMP
                        + " Elapsed time: " + elapsed + " seconds");

                LOGGER.info("\uD83D\uDD06\uD83D\uDD06\uD83D\uDD06 " +
                        "The Big Job (sendGenerateDataRequest) has completed: elapsedSeconds: "
                        + elapsed);

                if (isVerbose) {
                    LOGGER.info(GSON.toJson(bag));
                }

                LOGGER.info("\n\n\uD83D\uDD06\uD83D\uDD06\uD83D\uDD06 " +
                        "The Big Job(sendGenerateDataRequest) has completed, waiting for the next cycle, "
                        + " \uD83D\uDD34 "
                        + " elapsedSeconds: " + elapsed + " - time: "
                        + " \uD83D\uDD34 "
                        + DateTime.now().toDateTimeISO().toString() + " \n\n");
            } else {
                LOGGER.severe(E.RED_DOT +E.RED_DOT + " Probable bad status code: "
                        + response.statusCode());
                LOGGER.info(response.body());
            }
        } catch (Exception e) {
            LOGGER.severe(E.RED_DOT +E.RED_DOT +"We have a problem: "
                    + E.RED_DOT + " " + e.getMessage());
            e.printStackTrace();
        }

    }

    private static HttpResponse<String> sendRequest(String urlSuffix, int timeOutInSeconds) throws Exception {
        HttpRequest request = HttpRequest.newBuilder()
                .uri(new URI(urlPrefix + urlSuffix))
                .timeout(Duration.of(timeOutInSeconds, SECONDS))
                .GET()
                .build();

        LOGGER.info("\uD83C\uDF00\uD83C\uDF00 final url to send: " + request.uri().toString());
        long start = System.currentTimeMillis();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());

        long end = System.currentTimeMillis();
        double elapsed = Double.parseDouble(String.valueOf((end - start) / 1000));
        LOGGER.info("\uD83C\uDF50\uD83C\uDF50 Response statusCode:"
                + response.statusCode() + " " + E.AMP + E.AMP + " Elapsed time: " + elapsed + " seconds");

        return response;
    }

    //create new city aggregates at periodic intervals
    private static CityAggregate[] startAggregate() {
        LOGGER.info(E.AMP+E.AMP+E.AMP+E.AMP+" ... creating Aggregates: "
                + DateTime.now().toDateTimeISO().toString() + ", " +
                "\uD83D\uDD34\uD83D\uDD34\uD83D\uDD34 this may take a few minutes to calculate ... ");

        long start = System.currentTimeMillis();
        CityAggregate[] cityAggregates = null;
        try {
            HttpResponse<String> res = sendRequest("createAggregatesForAllCities?minutesAgo="
                    + dashboardMinutes, 9000);
            if (res.statusCode() == 200) {
                cityAggregates = GSON.fromJson(res.body(), CityAggregate[].class);
                long end = System.currentTimeMillis();
                double elapsed = Double.parseDouble(String.valueOf((end - start) / 1000));
                LOGGER.info(E.AMP+E.AMP+E.AMP+E.AMP+" " +
                        "Total city aggregates calculated: "
                        + cityAggregates.length + ", elapsed time: " + elapsed + " seconds");

                if (cityAggregates.length > 0) {
                    LOGGER.info(E.AMP+E.AMP+E.AMP+E.AMP+" " +
                            "First aggregate(sample): " + GSON.toJson(cityAggregates[0]));
                }
                for (CityAggregate ca : cityAggregates) {
                    String name = ca.getCityName();
                    if (name.contains("Cape Town")
                            || name.contains("Sandton")) {
                        LOGGER.info(E.AMP+E.AMP+E.AMP+E.AMP+" " +
                                name + " - Aggregate: " + GSON.toJson(ca));
                    }
                }
            } else {
                LOGGER.severe(E.RED_DOT+" We have a problem, statusCode: " + res.statusCode());
            }
        } catch (Exception e) {
            LOGGER.severe("\uD83D\uDD34 \uD83D\uDD34 \uD83D\uDD34 " +
                    "We have a network or server problem: " + e.getMessage());
            throw new RuntimeException(e);
        }
        return cityAggregates;
    }
    private static int tickCounter = 0;
    private static City[] cityArray = null;
    public static void startGeneration() throws Exception {

        LOGGER.info("\n\n\uD83D\uDD06\uD83D\uDD06\uD83D\uDD06\uD83D" +
                "\uDD06\uD83D\uDD06\uD83D\uDD06\uD83D\uDD06\uD83D\uDD06" +
                " ... starting Generator ..." + DateTime.now().toDateTimeISO().toString());

        if (callBigJob.equalsIgnoreCase("false")) {
            HttpResponse<String> result = sendRequest("getCities", 90000);
            LOGGER.info("\uD83D\uDD06\uD83D\uDD06\uD83D\uDD06  \uD83E\uDD6C cities json: \n"
                    + result.body());
            if (result.statusCode() == 200) {
                cityArray = GSON.fromJson(result.body(), City[].class);
                LOGGER.info("\uD83D\uDD06\uD83D\uDD06\uD83D\uDD06  \uD83E\uDD6C cities found: " + cityArray.length);
            }
        }

        tickCounter = 0;
        dashTickCounter = 0;

        final Timer dashboardTimer = new Timer();
        final Timer timer = new Timer();

        final long dashPeriod = TimeUnit.MINUTES.toMillis(dashboardMinutes);
        final long period = TimeUnit.MINUTES.toMillis(periodInMinutes);
        final long dashDelay = TimeUnit.MINUTES.toMillis(3);

        try {
            LOGGER.info("\n\n\n\uD83D\uDD06\uD83D\uDD06\uD83D\uDD06 " +
                    "Setting up Generation Timer ... periodInMinutes: " + periodInMinutes);
            timer.scheduleAtFixedRate(new GenerationTask(),0, period);

            LOGGER.info("\n\uD83D\uDD06\uD83D\uDD06\uD83D\uDD06 " +
                    "Setting up Dashboard Timer ... dashboardMinutes: " + dashboardMinutes);
            dashboardTimer.scheduleAtFixedRate(new DashboardTask(),dashDelay, dashPeriod);

        } catch (Exception e) {
            LOGGER.severe("\uD83D\uDD34 \uD83D\uDD34 \uD83D\uDD34 " +
                    "We have a network or server problem: " + e.getMessage());
            throw new RuntimeException(e);
        }
    }

    static int dashTickCounter = 0;
    private static void generate(City[] cityArray) {
        LOGGER.info("\uD83D\uDD06\uD83D\uDD06\uD83D\uDD06\uD83D\uDD06\uD83D\uDD06\uD83D\uDD06" +
                " Generating .....  \uD83C\uDF00\uD83C\uDF00 " +
                "Timer tickCounter: " + tickCounter + " \uD83C\uDF4E\uD83C\uDF4E\uD83C\uDF4E\uD83C\uDF4E" );
        long start = System.currentTimeMillis();
        for (City city : cityArray) {
            int mCount = random.nextInt(upperCount);
            if (mCount == 0) mCount = 100;
            LOGGER.info("\uD83D\uDD06\uD83D\uDD06\uD83D\uDD06\uD83D\uDD06" +
                    " Generating " + mCount + " events for city: " + city.getCity());

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
            if (name.contains("George")) {
                mCount = mCount + 200;
            }
            try {
                HttpResponse<String> res = sendRequest(
                        "generateEventsByCity?cityId=" + city.getId()
                                + "&count=" + mCount, 90000);
                if (res.statusCode() == 200) {
                    GenerationMessage gm = GSON.fromJson(res.body(), GenerationMessage.class);
                    LOGGER.info(E.BLUE_HEART + E.BLUE_HEART + E.BLUE_HEART
                            + " GenerationMessage: " + GSON.toJson(gm));
                } else {
                    LOGGER.severe("We have a problem, statusCode: " + res.statusCode() +
                            " - " + res.body());
                }
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        }
        long end = System.currentTimeMillis();
        double elapsed = Double.parseDouble(String.valueOf((end - start) / 1000));
        LOGGER.info("\uD83D\uDD06\uD83D\uDD06\uD83D\uDD06 ... " +
                "Generation elapsed time: " + elapsed + " seconds, will start dashboard & aggregates");

        LOGGER.info("\n\n\uD83C\uDF00\uD83C\uDF00\uD83C\uDF00\uD83C\uDF00\uD83C\uDF00\uD83C\uDF00" +
                " Everything wrapped up for this cycle - " + DateTime.now().toDateTimeISO().toString() +
                " Timer tick #"+tickCounter+" \uD83C\uDF00\uD83C\uDF00\uD83C\uDF00\uD83C\uDF00\n\n");
    }

    public static class GenerationTask  extends TimerTask {
        static Timer timer = new Timer();
        @Override
        public void run() {
            LOGGER.info("\n\n\n\uD83D\uDD06\uD83D\uDD06\uD83D\uDD06 " +
                    "Generator: Generation Timer tick: " + new DateTime().toDateTimeISO().toString());
            int x = random.nextInt(upperCounts.size() - 1);
            upperCount = upperCounts.get(x);
            tickCounter++;
            if (tickCounter <= maximumTicks) {
                if (callBigJob.equalsIgnoreCase("true")) {
                    try {
                        LOGGER.info("\uD83D\uDD06\uD83D\uDD06\uD83D\uDD06 " +
                                "calling The Big Job! timer tick: " + tickCounter);
                        sendGenerateDataRequest( upperCount);
                    } catch (Exception e) {
                        throw new RuntimeException(e);
                    }
                } else {
                    generate(cityArray);
                }
            } else {
                LOGGER.info("\n\n\uD83D\uDD06\uD83D\uDD06\uD83D\uDD06 " + "Generation work completed!");
                timer.cancel();
                System.exit(200);
            }
        }
    }
    public static class DashboardTask  extends TimerTask {
        @Override
        public void run() {
            dashTickCounter++;
            LOGGER.info("\n\n" + E.RED_APPLE+E.RED_APPLE+E.RED_APPLE+E.RED_APPLE +
                    " Generator: DashboardTimer tick: " + dashTickCounter + " - "
                    + new DateTime().toDateTimeISO().toString());
            try {

                DashboardData dd = startDashboard();
                LOGGER.info(E.RED_APPLE+E.RED_APPLE+" Dashboard created OK - "
                        + GSON.toJson(dd));
                CityAggregate[] list = startAggregate();
                LOGGER.info(E.RED_APPLE+E.RED_APPLE+" Aggregates created OK - "
                        + list.length + " aggregates" );

                LOGGER.info("\n\n" + E.LEAF+E.LEAF+E.LEAF+E.LEAF+E.LEAF
                        + " Dashboard and CityAggregates completed, waiting for next tick, time: "
                        + DateTime.now().toDateTimeISO().toString()+"\n\n");
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        }
    }

}



