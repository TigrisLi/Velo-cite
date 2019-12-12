import processing.serial.*;
import cc.arduino.*;

PFont font;

Serial myPort;
String portName = "/dev/tty.usbserial-A50285BI";
PImage img;

int one_byte = 0;
int[] eight_pixels = new int[8];


Serial arduinoPort; // creates local serial object from serial library

int number = 0;

int lf = 10; // Linefeed in ASCII
float arduinoData; // float for storing converted ASCII serial data
String myString = null; // variable to collect serial data


void setup(){
  printArray(Serial.list());
  background (255);
  smooth();
  size(700, 700);
  
  myPort = new Serial(this, "/dev/cu.usbserial-A50285BI", 19200);
  
  arduinoPort = new Serial(this, "/dev/cu.usbmodem14101", 9600);
  myString = arduinoPort.readStringUntil('\n');
  
  //font = loadFont("SFProDisplay-Regular-12.vlw");
  //textFont(font, 12);
  
}


void draw(){
  stroke(0);
  strokeWeight(3.5);
  noFill();
  
  while (arduinoPort.available() > 0) {
    myString = arduinoPort.readStringUntil('\n');

    if (myString != null) {
      arduinoData = float(myString);
      //println(arduinoData);
      
      //arduinoData = arduinoData/100 *height;
      
      drawCircle();
      drawArc();
      drawMountain();
      drawTextC();
    }
  }
  
}

void drawCircle() {
  //text(myString, arduinoData*random(10), arduinoData*random(2));
  
  ellipse(arduinoData*random(arduinoData), arduinoData*random(arduinoData), arduinoData*random(180), arduinoData*random(200));
  ellipse(arduinoData/random(1.5), arduinoData*random(17.5, 300), arduinoData*random(700), arduinoData*random(180));
  //ellipse(arduinoData/random(1.5), arduinoData*random(17.5, 300), arduinoData, arduinoData*random(180));
  ellipse(random(width), random(height), arduinoData*1.5, arduinoData*1.5);
  //text(myString, arduinoData*3, arduinoData*random(width));
  
}

void drawArc() { //  arc(x, y, width, height, start, stop)

  arc(arduinoData/3, arduinoData/55, arduinoData, arduinoData, 0, HALF_PI);
  noFill();
  arc(arduinoData/random(2), arduinoData/random(55), arduinoData*random(17.5), arduinoData*random(60), HALF_PI, PI);
  arc(arduinoData/random(2.5), arduinoData/random(25), arduinoData*random(35), arduinoData*random(3), PI, PI+QUARTER_PI);
  arc(arduinoData/random(17.5), arduinoData/random(5), arduinoData*random(20), arduinoData*random(80), PI+QUARTER_PI, TWO_PI);
}

void drawMountain() {
  //line(arduinoData*random(width), arduinoData*random(50), arduinoData, arduinoData);
  
  float yMountain = 700;
     //triangle(arduinoData*random(width), random(height), arduinoData*random(0, 17.5), yMountain, arduinoData*random(17.5, 35), yMountain);

  triangle(arduinoData*random(0,20), arduinoData*random(17.5, 35), arduinoData*random(0, 17.5), yMountain, arduinoData*random(2, 35), yMountain);
}

void drawTextC() {
  
  float radius = arduinoData;
  
  //text(myString, arduinoData*2, arduinoData*4);
  
  //so we are rotating around the center, rather than (0,0):
  translate(width/arduinoData, height/arduinoData*2); 
  for (int i = 0; i < myString.length(); i++) {
    radius += 2;
    rotate(10/radius); // change 10 to some other number for a different spacing. 
//    text(myString.charAt(i), 0, radius); // drawing at (0,radius) because we're drawing onto a rotated canvas
  }
}


void keyPressed() {
  if (key == 's') {   //save drawing
    //println("Saving...");
    String sFile = "Specimen" + nf(number, 3) + ".jpg";
    println(sFile);
    save(sFile);
    
    // img = loadImage(sFile);
    
    number++;
    println("Done Saving.");

    
    printFile(sFile);
    background(255);
    
  }
  delay(5);
}

void printFile(String fileName) {

  PImage img = loadImage(fileName);
  
  img.resize(384, 0);
  img.loadPixels();
  
  for (int y = 0; y < img.height; y++) {
    myPort.write(18);
    myPort.write(42);
    myPort.write(1);
    myPort.write(48);
     for (int x = 0; x < 384; x++) {
         int loc = x + y*384;
           
         float r = red(img.pixels[loc]);
         float g = green(img.pixels[loc]);
         float b = blue(img.pixels[loc]);
           
         int rgb = int(r+g+b);
         
         if(rgb > 382){
            eight_pixels[7-(x%8)] = 0;
         }else{
            eight_pixels[7-(x%8)] = 1;
         }
         if((x+1)%8==0){
           one_byte = eight_pixels[0] | (eight_pixels[1] << 1) | (eight_pixels[2] << 2) | (eight_pixels[3] << 3) | (eight_pixels[4] << 4) | (eight_pixels[5] << 5) | (eight_pixels[6] << 6) | (eight_pixels[7] << 7);
           myPort.write((byte)one_byte);
           //delay(1);
         }
     }
     //delay(20);
  }
  myPort.write(" \n");
  delay(500);
  myPort.write(" \n");
  delay(500);
  myPort.write(" \n");
  delay(500);
  myPort.write(" \n");
  delay(500);
}
