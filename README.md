# leshan-client-demo

Updated the leshan client demo example from the following github

https://github.com/eclipse/leshan

- Added Humidity smart object from https://github.com/IPSO-Alliance/pub/blob/master/reg/xml/3304.xml
- Added new params
  * device: tmp for temperature or hum for humidity
  * frq: Measurement send frequency in secs (optional, default is 10)

  * src: Source file to read measurements from

  OR

  * val: start value for measurement
  * min: allowed minimum
  * max: allowed maximum

  Usage of one of the src or min-max-val is mandatory, but not together.

- Updated random value calculation, it was negative oriented. Now it should be equally distributed.
- Possible to use source file as measurement input

Example usage:

 - Random generation:

   java -jar leshan-client-demo-1.0.0-SNAPSHOT-jar-with-dependencies.jar -u URL -n DEVICENAME -device hum -val 50 -min 0 -max 100

 From file:

   java -jar leshan-client-demo-1.0.0-SNAPSHOT-jar-with-dependencies.jar -u URL -n DEVICENAME -device hum -frq 10 -src file.txt

    File content should be as follows;

    timestamp1;value1
    timestamp2;value2
    ...


There is also a shell script to run a bunch of clients to do the following;
- Kill the existing client process if exists
- Start the new client
- Run the curl command to start observation

