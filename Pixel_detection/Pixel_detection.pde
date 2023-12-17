import SimpleOpenNI.*;
import java.util.ArrayList;
import java.util.HashMap;

SimpleOpenNI kinect;

ArrayList<ObjectBoundary> objectBoundaries;
HashMap<Integer, Integer> objectColors; // Map object number to color

void setup() {
  size(640, 480);

  // Initialize Kinect
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();

  // Mirror the image (optional)
  kinect.setMirror(true);

  objectBoundaries = new ArrayList<>();
  objectColors = new HashMap<>();
}

void draw() {
  background(0);

  // Update Kinect
  kinect.update();

  // Get depth map
  int[] depthValues = kinect.depthMap();

  // Process depth map
  processDepthMap(depthValues);

  // Draw object boundaries
  for (ObjectBoundary boundary : objectBoundaries) {
    boundary.display();
  }
}

void processDepthMap(int[] depthMap) {
  objectBoundaries.clear(); // Clear previous object boundaries
  objectColors.clear();    // Clear previous object colors

  int objectCount = 0;

  for (int y = 0; y < kinect.depthHeight(); y += 10) {
    for (int x = 0; x < kinect.depthWidth(); x += 10) {
      int i = x + y * kinect.depthWidth();
      int depth = depthMap[i];

      if (depth > 1000 && depth < 2000) { // Customize depth range as needed
        // Check if the pixel belongs to an existing object
        boolean objectFound = false;
        for (ObjectBoundary boundary : objectBoundaries) {
          if (boundary.contains(x, y, depth)) {
            objectFound = true;
            break;
          }
        }

        if (!objectFound) {
          // Create a new object boundary
          int boundaryColor = getUniqueColor(objectCount);
          ObjectBoundary newBoundary = new ObjectBoundary(objectCount++, x, y, depth, boundaryColor);
          objectBoundaries.add(newBoundary);

          // Print object information
          println("Object " + newBoundary.getObjectNumber() +
                  " at depth " + depth +
                  " coordinates: (" + x + ", " + y + ")");
        }
      }
    }
  }
}

int getUniqueColor(int objectNumber) {
  // Generate a unique color for each object
  return color(random(255), random(255), random(255));
}

void keyPressed() {
  if (key == ESC) {
    kinect.dispose();
    exit();
  }
}

class ObjectBoundary {
  private int objectNumber;
  private int startX, startY;
  private int endX, endY;
  private int boundaryColor;  // Change variable name from "color" to "boundaryColor"

  ObjectBoundary(int objectNumber, int startX, int startY, int depth, int boundaryColor) {
    this.objectNumber = objectNumber;
    this.startX = startX;
    this.startY = startY;
    this.endX = startX + 10; // Adjust rectangle size as needed
    this.endY = startY + 10;
    this.boundaryColor = boundaryColor;
  }

  boolean contains(int x, int y, int depth) {
    return (x >= startX && x <= endX && y >= startY && y <= endY && depth > 1000 && depth < 2000);
  }

  void display() {
    fill(boundaryColor);  // Use the modified variable name here
    rect(startX, startY, 10, 10);

    fill(255);
    text(objectNumber, startX + 5, startY + 5);
  }

  int getObjectNumber() {
    return objectNumber;
  }
}
