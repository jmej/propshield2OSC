/*
    connects to a wifi network
    reads pitch, yaw and roll from the teensy prop shield
    sends as OSC messages /motion pitch yaw roll
    
    Jesse Mejia
    Parallel Studio
    2017
 */
#include <SPI.h>
#include <WiFi101.h>
#include <WiFiUdp.h>    
#include <OSCMessage.h>

#include <NXPMotionSense.h>
#include <Wire.h>
#include <EEPROM.h>

NXPMotionSense imu;
NXPSensorFusion filter;

int status = WL_IDLE_STATUS;
char ssid[] = "****"; //  your network SSID (name)
char pass[] = "****";    // your network password (use for WPA, or use as key for WEP)

//the Arduino's IP
IPAddress ip(128, 32, 122, 252);
//destination IP
IPAddress outIp(192, 168, 1, 50);
const unsigned int outPort = 9999;

WiFiUDP Udp;

void setup() {
  //Initialize serial and wait for port to open:
  Serial.begin(9600);
  delay(5000);
  imu.begin();
  filter.begin(100);
  WiFi.setPins(10,6,5); // CS, irq, rst
//  while (!Serial) {
//   Serial.println("waiting for serial..."); // wait for serial port to connect. Needed for native USB port only
//  }

  Serial.println("Serial port connected");
  // check for the presence of the shield:
  Serial.println(WiFi.status());
  if (WiFi.status() == WL_NO_SHIELD) {
    Serial.println("WiFi shield not present");
    // don't continue:
//    while (true);
  }
  Serial.println(WiFi.status());
  // attempt to connect to WiFi network:
  while ( status != WL_CONNECTED) {
    Serial.print("Attempting to connect to SSID: ");
    Serial.println(ssid);
    // Connect to WPA/WPA2 network. Change this line if using open or WEP network:
    status = WiFi.begin(ssid, pass);

    // wait 10 seconds for connection:
    delay(10000);
  }
  Serial.println("Connected to wifi");
  printWiFiStatus();

  Serial.println("\nStarting connection to server...");
  // if you get a connection, report back via serial:
  Udp.begin(outPort);
}



void loop(){
  float ax, ay, az;
  float gx, gy, gz;
  float mx, my, mz;
  float roll, pitch, yaw, heading;

  if (imu.available()) {
    // Read the motion sensors
    imu.readMotionSensor(ax, ay, az, gx, gy, gz, mx, my, mz);

    // Update the SensorFusion filter
    filter.update(gx, gy, gz, ax, ay, az, mx, my, mz);

    // print the heading, pitch and roll
    roll = filter.getRoll();
    pitch = filter.getPitch();
    yaw = filter.getYaw();
    heading = filter.getYaw();
//    Serial.print("Orientation: ");
//    Serial.print(heading);
//    Serial.print(" ");
//    Serial.print(pitch);
//    Serial.print(" ");
//    Serial.println(roll);
    //the message wants an OSC address as first argument
    OSCMessage msg("/motion");
    msg.add(pitch);
    msg.add(yaw);
    msg.add(roll);
    Udp.beginPacket(outIp, outPort);
    msg.send(Udp); // send the bytes to the SLIP stream
    Udp.endPacket(); // mark the end of the OSC Packet
    msg.empty(); // free space occupied by message
  }
}

void printWiFiStatus() {
  // print the SSID of the network you're attached to:
  Serial.print("SSID: ");
  Serial.println(WiFi.SSID());

  // print your WiFi shield's IP address:
  IPAddress ip = WiFi.localIP();
  Serial.print("IP Address: ");
  Serial.println(ip);

  // print the received signal strength:
  long rssi = WiFi.RSSI();
  Serial.print("signal strength (RSSI):");
  Serial.print(rssi);
  Serial.println(" dBm");
}


