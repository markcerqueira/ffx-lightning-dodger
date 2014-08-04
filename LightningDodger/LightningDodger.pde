import java.awt.AWTException;
import java.awt.event.KeyEvent;
import java.awt.Robot;

import org.openkinect.*;
import org.openkinect.processing.*;

Kinect kinect;
Robot robot;

// point your Kinect at your TV and then ensure this array contains points that are within 
// the bounds of the TV
Point[] trackingPoints = { new Point(100, 100), new Point(200, 200), new Point(300, 300)};

// designates the size of the circles that will be drawn to represent the points in the
// trackingPoints array
int TRACKER_POINT_SIZE = 10;

// used for lightning detection - the RGB values of points will all need to be above this
// value for the a lightning bolt to be registered
int WHITE_THRESHOLD = 220;

// number of calls to the draw method that will be "ignored" following detection of a
// lightning bolt
int WHITE_COOLDOWN = 20;

void setup() {
  size(640, 480);
  
  kinect = new Kinect(this);
  kinect.start();
  kinect.enableRGB(true);
  
  try {
    robot = new Robot();  
  }
  catch(AWTException e) {
    println(e);
  } 
}

String colorToString(color c) {
    return red(c) + ", " + green(c) + ", " + blue(c);
}

boolean isWhite(color c) { 
  boolean isWhite = red(c) > WHITE_THRESHOLD && green(c) > WHITE_THRESHOLD && blue(c) > WHITE_THRESHOLD;
  
  /* if(isWhite) {
     println(colorToString(c)); 
  } */
  
  return isWhite;
}


int lightningBoltsDetectedSoFar = 0;
int cooldown = 0;
int ticks = 0;

void draw() { 
  ticks++;
  
  // TODO - for debugging in case this application GOES ROGUE!
  if(ticks > 9000) {
     exit();
  }
  
  if(cooldown == 0 && ticks % 2 == 0) {
     moveTidus(); 
  }
  
  PImage img = kinect.getVideoImage();
  
  image(img, 0, 0);
  
  // draw circles to show where we are tracking the color
  for(int i = 0; i < trackingPoints.length; i++) {
    Point p = trackingPoints[i];
    ellipse(p.x, p.y, TRACKER_POINT_SIZE, TRACKER_POINT_SIZE);
  }  
  
  // if a lightning bolt was recently detected, we're done for now
  if(cooldown > 0) {
    cooldown--;
    return; 
  }
  
  // check each of the trackingPoints to see if they are white
  int whiteCount = 0;
  for(int i = 0; i < trackingPoints.length; i++) {
    Point p = trackingPoints[i];
    if(isWhite(img.get(p.x, p.y))) {
       whiteCount++; 
    }
  }
  
  // TODO - make this more than "just zero" ?
  if(whiteCount > 0) {
     lightningBoltsDetectedSoFar++; 
     println("Lightning detected! Total detections so far = " + lightningBoltsDetectedSoFar);
     cooldown = WHITE_COOLDOWN;
     dodgeBolt();
  }
}

boolean moveUp = true;
int MAX_STEPS = 100;
int currentSteps = 0;

void moveTidus() {
  if(currentSteps < MAX_STEPS) {
      currentSteps++;
      return;
  }
  
  currentSteps = 0;
  moveUp = !moveUp;
  
  if(moveUp) {
     robot.keyPress(KeyEvent.VK_U);
  } else {
     robot.keyPress(KeyEvent.VK_D);
  }  
}

void dodgeBolt() {
  robot.keyRelease(KeyEvent.VK_U);  
  robot.keyRelease(KeyEvent.VK_D);  

  pressKey(KeyEvent.VK_X);
}

void pressKey(int c) {
  robot.keyPress(c);
  robot.keyRelease(c);  
}

void stop() {
  kinect.quit();
  
  super.stop();
}

