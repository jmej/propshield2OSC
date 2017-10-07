import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

float yaw = 0;
float pitch = 0;
float roll = 0;

void setup()
{
  size(600, 500, P3D);

  oscP5 = new OscP5(this,9999);
  
  textSize(16); // set text size
  textMode(SHAPE); // set text mode to shape
}

void draw()
{
  background(255); // set background to white
  lights();

  translate(width/2, height/2); // set position to centre

  pushMatrix(); // begin object

  float c1 = cos(radians(roll));
  float s1 = sin(radians(roll));
  float c2 = cos(radians(-pitch));
  float s2 = sin(radians(-pitch));
  float c3 = cos(radians(yaw));
  float s3 = sin(radians(yaw));
  applyMatrix( c2*c3, s1*s3+c1*c3*s2, c3*s1*s2-c1*s3, 0,
               -s2, c1*c2, c2*s1, 0,
               c2*s3, c1*s2*s3-c3*s1, c1*c3+s1*s2*s3, 0,
               0, 0, 0, 1);

  drawPropShield();
  //drawArduino();

  popMatrix(); // end of object

}



void drawArduino()
{
  /* function contains shape(s) that are rotated with the IMU */
  stroke(0, 90, 90); // set outline colour to darker teal
  fill(0, 130, 130); // set fill colour to lighter teal
  box(300, 10, 200); // draw Arduino board base shape

  stroke(0); // set outline colour to black
  fill(80); // set fill colour to dark grey

  translate(60, -10, 90); // set position to edge of Arduino box
  box(170, 20, 10); // draw pin header as box

  translate(-20, 0, -180); // set position to other edge of Arduino box
  box(210, 20, 10); // draw other pin header as box
}

void drawPropShield()
{
  // 3D art by Benjamin Rheinland
  stroke(0); // black outline
  fill(0, 128, 0); // fill color PCB green
  box(190, 6, 70); // PCB base shape

  fill(255, 215, 0); // gold color
  noStroke();

  //draw 14 contacts on Y- side
  translate(65, 0, 30);
  for (int i=0; i<14; i++) {
    sphere(4.5); // draw gold contacts
    translate(-10, 0, 0); // set new position
  }

  //draw 14 contacts on Y+ side
  translate(10, 0, -60);
  for (int i=0; i<14; i++) {
    sphere(4.5); // draw gold contacts
    translate(10, 0, 0); // set position
  }

  //draw 5 contacts on X+ side (DAC, 3v3, gnd)
  translate(-10,0,10);
  for (int i=0; i<5; i++) {
    sphere(4.5);
    translate(0,0,10);
  }

  //draw 4 contacts on X+ side (G C D 5)
  translate(25,0,-15);
  for (int i=0; i<4; i++) {
    sphere(4.5);
    translate(0,0,-10);
  }

  //draw 4 contacts on X- side (5V - + GND)
  translate(-180,0,10);
  for (int i=0; i<4; i++) {
    sphere(4.5);
    translate(0,0,10);
  }

  //draw audio amp IC
  stroke(128);
  fill(24);    //Epoxy color
  translate(30,-6,-25);
  box(13,6,13);

  //draw pressure sensor IC
  stroke(64);
  translate(32,0,0);
  fill(192);
  box(10,6,18);

  //draw gyroscope IC
  stroke(128);
  translate(27,0,0);
  fill(24);
  box(16,6,16);

  //draw flash memory IC
  translate(40,0,-15);
  box(20,6,20);

  //draw accelerometer/magnetometer IC
  translate(-5,0,25);
  box(12,6,12);

  //draw 5V level shifter ICs
  translate(42.5,2,0);
  box(6,4,8);
  translate(0,0,-20);
  box(6,4,8);
}

void oscEvent(OscMessage theOscMessage) {
  /* check if theOscMessage has the address pattern we are looking for. */
  
  if(theOscMessage.checkAddrPattern("/motion")==true) {
    /* check if the typetag is the right one. */
    /* parse theOscMessage and extract the values from the osc message arguments. */
    pitch = theOscMessage.get(0).floatValue(); 
    println("pitch: "+pitch);
    yaw = theOscMessage.get(1).floatValue();
    println("yaw: "+yaw);
    roll = theOscMessage.get(2).floatValue();
    println("roll: "+roll);
    //print("### received an osc message /motion with typetag ifs.");
    //println(" values: "+firstValue+", "+secondValue+", "+thirdValue);
    return;
  } 
  //println("### received an osc message. with address pattern "+theOscMessage.addrPattern()+" and typetag "+theOscMessage.typetag());
}