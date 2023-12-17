import SimpleOpenNI.*;
import java.util.ArrayList;
import java.util.Stack;

SimpleOpenNI kinect;

ArrayList<ObjectBoundary> objectBoundaries;
float pixelToCmX = 0.05; // Example conversion factor for X-axis
float pixelToCmY = 0.05; // Example conversion factor for Y-axis

void setup() {
  size(640, 480);
  kinect = new SimpleOpenNI(this);
  kinect.enableDepth();
  kinect.setMirror(true);
  objectBoundaries = new ArrayList<>();
}

void draw() {
  kinect.update();
  background(0);

  int[] depthValues = kinect.depthMap();
  processDepthMap(depthValues);

  for (ObjectBoundary boundary : objectBoundaries) {
    boundary.display();
  }
}

void processDepthMap(int[] depthMap) {
  boolean[][] processedPixels = new boolean[kinect.depthWidth()][kinect.depthHeight()];
  objectBoundaries.clear();

  int objectCount = 0;

  for (int y = 0; y < kinect.depthHeight(); y += 10) {
    for (int x = 0; x < kinect.depthWidth(); x += 10) {
      int i = x + y * kinect.depthWidth();
      int depth = depthMap[i];

      if (depth > 500 && depth < 1500 && !processedPixels[x][y]) {
        ArrayList<PVector> objectPixels = new ArrayList<>();
        Stack<PVector> stack = new Stack<>();
        stack.push(new PVector(x, y));

        while (!stack.isEmpty()) {
          PVector currentPixel = stack.pop();
          int currentX = (int) currentPixel.x;
          int currentY = (int) currentPixel.y;

          if (currentX >= 0 && currentX < kinect.depthWidth() && currentY >= 0 && currentY < kinect.depthHeight() &&
              depthMap[currentX + currentY * kinect.depthWidth()] > 500 &&
              depthMap[currentX + currentY * kinect.depthWidth()] < 1500 &&
              !processedPixels[currentX][currentY]) {

            objectPixels.add(currentPixel);
            processedPixels[currentX][currentY] = true;

            stack.push(new PVector(currentX + 1, currentY));
            stack.push(new PVector(currentX - 1, currentY));
            stack.push(new PVector(currentX, currentY + 1));
            stack.push(new PVector(currentX, currentY - 1));
          }
        }

        if (objectPixels.size() > 0) {
          // Assign a fixed color to each object
          int boundaryColor = color(255, 0, 0); // Red color, you can customize this

          ObjectBoundary newBoundary = new ObjectBoundary(objectCount++, objectPixels, depth, boundaryColor);
          objectBoundaries.add(newBoundary);

          // Print object information to console with units
          println("Object " + newBoundary.getObjectNumber() +
                  ": Depth " + newBoundary.getDepth() + " cm" +
                  " at (" + newBoundary.getCenterX() * pixelToCmX + " cm, " + newBoundary.getCenterY() * pixelToCmY + " cm)");
        }
      }
    }
  }
}

void keyPressed() {
  if (key == ESC) {
    kinect.dispose();
    exit();
  }
}

class ObjectBoundary {
  private int objectNumber;
  private ArrayList<PVector> pixels;
  private int depth;
  private int boundaryColor;

  ObjectBoundary(int objectNumber, ArrayList<PVector> pixels, int depth, int boundaryColor) {
    this.objectNumber = objectNumber;
    this.pixels = pixels;
    this.depth = depth;
    this.boundaryColor = boundaryColor;
  }

  void display() {
    stroke(boundaryColor);
    noFill();
    beginShape();
    for (PVector pixel : pixels) {
      vertex(pixel.x, pixel.y);
    }
    endShape(CLOSE);

    fill(255);
    textSize(18);
    textAlign(CENTER, CENTER);
    text(objectNumber, getCenterX(), getCenterY());

    // Print object distance and coordinates
    println("Object " + objectNumber +
            ": Depth " + depth + " cm" +
            " at (" + getCenterX() * pixelToCmX + " cm, " + getCenterY() * pixelToCmY + " cm)");
  }

  int getObjectNumber() {
    return objectNumber;
  }

  int getDepth() {
    return depth;
  }

  float getCenterX() {
    float sumX = 0;
    for (PVector pixel : pixels) {
      sumX += pixel.x;
    }
    return sumX / pixels.size();
  }

  float getCenterY() {
    float sumY = 0;
    for (PVector pixel : pixels) {
      sumY += pixel.y;
    }
    return sumY / pixels.size();
  }
}
