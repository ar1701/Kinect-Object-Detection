import SimpleOpenNI.*;

SimpleOpenNI context;
PImage depthImage;

void setup() {
  size(640, 480);
  context = new SimpleOpenNI(this);
  if (context.isInit() == false) {
    println("Can't init SimpleOpenNI, maybe the camera is not connected!");
    exit();
    return;
  }
  context.enableDepth();
  depthImage = createImage(context.depthWidth(), context.depthHeight(), RGB);
}

void draw() {
  context.update();
  depthImage.loadPixels();
  int[] depthValues = context.depthMap();
  for (int i = 0; i < depthValues.length; i++) {
    if (depthValues[i] > 500 && depthValues[i] < 1500) { // Change the values as needed
      depthImage.pixels[i] = color(0, 255, 0); // Green for floor
    } else if (depthValues[i] >= 1500 && depthValues[i] < 2000) {
      depthImage.pixels[i] = color(255, 0, 0); // Red for obstacles
    } else {
      depthImage.pixels[i] = color(0, 0, 0); // Black for everything else
    }
  }
  depthImage.updatePixels();
  image(depthImage, 0, 0);
}
