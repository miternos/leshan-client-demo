package org.eclipse.leshan.client.demo;

import java.util.Random;

/**
 * Created by miternos on 9/22/17.
 */
public class test {

    private static final Random rng = new Random();

    public static void main(String[] args) {
        float delta;

        while(true){
            delta = (rng.nextInt(20) - 10) / 10f;
            System.out.println(delta);
            if ( delta < -10 ){
                break;
            }

            try {
                Thread.sleep(0);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }
}
