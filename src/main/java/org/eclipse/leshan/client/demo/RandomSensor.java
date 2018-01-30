package org.eclipse.leshan.client.demo;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Map;
import java.util.Random;
import java.util.TreeMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

import org.eclipse.leshan.client.resource.BaseInstanceEnabler;
import org.eclipse.leshan.core.response.ExecuteResponse;
import org.eclipse.leshan.core.response.ReadResponse;
import org.eclipse.leshan.util.NamedThreadFactory;
import org.eclipse.leshan.util.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class RandomSensor extends BaseInstanceEnabler {

    private static final Logger LOG = LoggerFactory.getLogger(RandomSensor.class);


    private static final int SENSOR_VALUE = 5700;
    private static final int UNITS = 5701;
    private static final int MAX_MEASURED_VALUE = 5602;
    private static final int MIN_MEASURED_VALUE = 5601;
    private static final int RESET_MIN_MAX_MEASURED_VALUES = 5605;
    private final ScheduledExecutorService scheduler;
    private final Random rng = new Random();

    private String unit = "cel";
    private double currentValue = 20d;
    private double minMeasuredValue;
    private double maxMeasuredValue;

    private double allowedMinValue = -273 ;
    private double allowedMaxValue = 1000 ;

    private String sourceFile;
    private Long lastSentTimestamp = 0L;

    private TreeMap<Long,Double> dataMap = new TreeMap<>();

    public RandomSensor(String sensorUnit, double currentValueIn, double allowedMinValueIn, double allowedMaxValueIn, String source, long period) {

        unit = sensorUnit;

        allowedMinValue = allowedMinValueIn ;
        allowedMaxValue = allowedMaxValueIn ;

        if ( StringUtils.isEmpty(source) ){
            currentValue = currentValueIn;


            minMeasuredValue = currentValue;
            maxMeasuredValue = currentValue;



            this.scheduler = Executors.newSingleThreadScheduledExecutor(new NamedThreadFactory("Sensor"));
            scheduler.scheduleAtFixedRate(new Runnable() {

                @Override
                public void run() {
                    adjustTemperature();
                }
            }, 1, period, TimeUnit.MILLISECONDS);
        } else {
            sourceFile = source;
            readDataMap();
            this.scheduler = Executors.newSingleThreadScheduledExecutor(new NamedThreadFactory("Sensor"));
            scheduler.scheduleAtFixedRate(new Runnable() {

                @Override
                public void run() {
                    adjustTemperatureFromFile();
                }
            }, 1, period, TimeUnit.SECONDS);

        }


    }

    /**
     * Read the file and put into treemap, only
     */
    private void readDataMap() {
        BufferedReader reader;
        try {
            reader = new BufferedReader(new FileReader(sourceFile));
            String line = reader.readLine();
            while (!StringUtils.isEmpty(line)) {
                String[] arr = line.split(";");
                if (arr.length == 2){
                    try {
                        Long timeStamp = Long.valueOf(arr[0]);
                        Double sensValue = Double.valueOf(arr[1]);

                        if ( timeStamp > lastSentTimestamp && ( dataMap.size() == 0 || timeStamp > dataMap.lastKey() ) ){
                            dataMap.put(timeStamp,sensValue);
                        }

                    } catch (NumberFormatException e){
                        System.out.println(e.getMessage());
                    }
                }
                line = reader.readLine();
            }
            reader.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @Override
    public synchronized ReadResponse read(int resourceId) {
        switch (resourceId) {
            case MIN_MEASURED_VALUE:
                return ReadResponse.success(resourceId, getTwoDigitValue(minMeasuredValue));
            case MAX_MEASURED_VALUE:
                return ReadResponse.success(resourceId, getTwoDigitValue(maxMeasuredValue));
            case SENSOR_VALUE:
                return ReadResponse.success(resourceId, getTwoDigitValue(currentValue));
            case UNITS:
                return ReadResponse.success(resourceId, unit);
            default:
                return super.read(resourceId);
        }
    }

    @Override
    public synchronized ExecuteResponse execute(int resourceId, String params) {
        switch (resourceId) {
            case RESET_MIN_MAX_MEASURED_VALUES:
                resetMinMaxMeasuredValues();
                return ExecuteResponse.success();
            default:
                return super.execute(resourceId, params);
        }
    }

    private double getTwoDigitValue(double value) {
        BigDecimal toBeTruncated = BigDecimal.valueOf(value);
        return toBeTruncated.setScale(2, RoundingMode.HALF_UP).doubleValue();
    }

    private synchronized void adjustTemperature() {



        float delta = (rng.nextInt(21) - 10) / 10f;
        currentValue += delta;

        // Do not allow beyond borders
        while ( currentValue > allowedMaxValue || currentValue < allowedMinValue ){
            delta = (rng.nextInt(21) - 10) / 10f;
            currentValue += delta;
        }

        Integer changedResource = adjustMinMaxMeasuredValue(currentValue);
        if (changedResource != null) {
            fireResourcesChange(SENSOR_VALUE, changedResource);
        } else {
            fireResourcesChange(SENSOR_VALUE);
        }
        LOG.info("Fired resource change");
    }

    private synchronized void adjustTemperatureFromFile(){

        if ( dataMap.size() == 0 ){
            readDataMap();
            if ( dataMap.size() == 0 ){
                System.out.println("File finished exit");
                System.exit(0);
            }
        }



        /* Get the first value in map */
        currentValue = dataMap.firstEntry().getValue();

        Integer changedResource = adjustMinMaxMeasuredValue(currentValue);
        if (changedResource != null) {
            fireResourcesChange(SENSOR_VALUE, changedResource);
        } else {
            fireResourcesChange(SENSOR_VALUE);
        }

        LOG.info("Inserted value(" + endpoint + ") " + ((Double)currentValue).longValue());

        /* Update the last timestamp so that we won't record or send it again */
        lastSentTimestamp = dataMap.firstKey();

        /* Remove data from map */
        dataMap.remove(lastSentTimestamp);
    }

    private Integer adjustMinMaxMeasuredValue(double newTemperature) {

        if (newTemperature > maxMeasuredValue) {
            maxMeasuredValue = newTemperature;
            return MAX_MEASURED_VALUE;
        } else if (newTemperature < minMeasuredValue) {
            minMeasuredValue = newTemperature;
            return MIN_MEASURED_VALUE;
        } else {
            return null;
        }
    }

    private void resetMinMaxMeasuredValues() {
        minMeasuredValue = currentValue;
        maxMeasuredValue = currentValue;
    }
}
