import SimpleOpenNI.*;

SimpleOpenNI context;
ArrayList<Mover> moversL = new ArrayList<Mover>();
ArrayList<Mover> moversR = new ArrayList<Mover>();
ArrayList<PShape> shapes = new ArrayList<PShape>();
Attractor attractorL, attractorR;
PGraphics canvas, people;
String[] srcPaths = {
  "bitmap/img0.jpg", "bitmap/img1.jpg", "bitmap/img2.jpg", "bitmap/img3.jpg", "bitmap/motm.png"
};
PImage[] src = new PImage[srcPaths.length];
int currentSrc = 0;

void setup() {
  size(displayWidth, displayHeight, P2D);
  noCursor();
  loadVectors("ornaments", true);

  for (int i=0;i<srcPaths.length;i++) {
    src[i] = loadImage(srcPaths[i]);
    src[i].resize(width,height);
    src[i].loadPixels();
  }

  context = new SimpleOpenNI(this);
  if (context.enableDepth() == false)
  {
    exit();
    return;
  }

  context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
  context.setMirror(true);

  canvas = createGraphics(width, height);
  canvas.beginDraw();
  canvas.endDraw();

  people = createGraphics(width, height);
  people.beginDraw();
  people.endDraw();

  for (int i = 0; i < 1; i++) {
    moversL.add(new Mover(random(2), new PVector(random(width), random(height)), random(0.0001, 0.01)));
    moversR.add(new Mover(random(2), new PVector(random(width), random(height)), random(0.0001, 0.01)));
  }

  attractorL = new Attractor();
  attractorR = new Attractor();
}



void draw() {

  if (frameCount % 100 == 0) currentSrc = (int) random(srcPaths.length);

  context.update();

  people.beginDraw();
  people.clear();
  people.endDraw();

  int[] userList = context.getUsers();
  for (int i=0; i < userList.length; i++)
  {
    if (context.isTrackingSkeleton(userList[i])) drawSkeleton(userList[i]);
  }
  canvas.beginDraw();

  if (frameCount % 30 == 0 && context.getUsers().length == 0) {
    attractorL.updateLocation(new PVector(random(width), random(height)));
    attractorR.updateLocation(new PVector(random(width), random(height)));
  }
  for (int j=0; j<5; j++) {
    for (int i = 0; i < moversL.size(); i++) {
      updateAndDrawPoint(moversL.get(i), attractorL);
    }
    for (int i = 0; i < moversR.size(); i++) {
      updateAndDrawPoint(moversR.get(i), attractorR);
    }
  }
  
  canvas.endDraw();
  background(255);
  image(canvas, 0, 0);
  image(people, 0, 0);
}

void updateAndDrawPoint(Mover m, Attractor a) {
  m.applyForce(a.attract(m));
  m.update();
  color c = src[currentSrc].get((int) m.location.x, (int) m.location.y);
  PShape shape = shapes.get((int) random(shapes.size()));
  shape.resetMatrix();
  shape.disableStyle();
  shape.scale(random(0.5));
  shape.rotate(random(PI));
  canvas.stroke(255);
  canvas.fill(red(c), green(c), blue(c), 255);
  canvas.strokeWeight(0.5 * (1 / m.radius));
  canvas.shape(shape, m.location.x, m.location.y);
}

//----------------------------------------------------------------------
// Load vectors from given files and folders
//----------------------------------------------------------------------

void loadVectors(String folderName, boolean loadChildrenAsShapes) {
  File folder = new File(this.sketchPath+"/data/vector/" + folderName);
  File[] listOfFiles = folder.listFiles();
  for (File file : listOfFiles) {
    if (file.isFile()) {
      PShape shape = loadShape(file.getAbsolutePath());
      if (loadChildrenAsShapes) {
        for (PShape layer : shape.getChildren()) {
          if (layer!=null) shapes.add(layer);
        }
      } 
      else {
        shapes.add(shape);
      }
    }
  }
}

void drawSkeleton(int userId)
{
  people.beginDraw();
  ScaledJoint head = new ScaledJoint(context, userId, SimpleOpenNI.SKEL_HEAD);
  ScaledJoint neck = new ScaledJoint(context, userId, SimpleOpenNI.SKEL_NECK);
  ScaledJoint leftShoulder = new ScaledJoint(context, userId, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  ScaledJoint leftElbow = new ScaledJoint(context, userId, SimpleOpenNI.SKEL_LEFT_ELBOW);
  ScaledJoint leftHand = new ScaledJoint(context, userId, SimpleOpenNI.SKEL_LEFT_HAND);
  ScaledJoint leftHip = new ScaledJoint(context, userId, SimpleOpenNI.SKEL_LEFT_HIP);
  ScaledJoint leftKnee = new ScaledJoint(context, userId, SimpleOpenNI.SKEL_LEFT_KNEE);
  ScaledJoint leftFoot = new ScaledJoint(context, userId, SimpleOpenNI.SKEL_LEFT_FOOT);
  ScaledJoint rightShoulder = new ScaledJoint(context, userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  ScaledJoint rightElbow = new ScaledJoint(context, userId, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  ScaledJoint rightHand = new ScaledJoint(context, userId, SimpleOpenNI.SKEL_RIGHT_HAND);
  ScaledJoint rightHip = new ScaledJoint(context, userId, SimpleOpenNI.SKEL_RIGHT_HIP);
  ScaledJoint rightKnee = new ScaledJoint(context, userId, SimpleOpenNI.SKEL_RIGHT_KNEE);
  ScaledJoint rightFoot = new ScaledJoint(context, userId, SimpleOpenNI.SKEL_RIGHT_FOOT);
  ScaledJoint torso = new ScaledJoint(context, userId, SimpleOpenNI.SKEL_TORSO);

  people.stroke(255);
  people.fill(255);
  people.strokeWeight(5);
  people.line(head.pos.x, head.pos.y, neck.pos.x, neck.pos.y);
  people.line(neck.pos.x, neck.pos.y, leftShoulder.pos.x, leftShoulder.pos.y);
  people.line(leftShoulder.pos.x, leftShoulder.pos.y, leftElbow.pos.x, leftElbow.pos.y);
  people.line(leftElbow.pos.x, leftElbow.pos.y, leftHand.pos.x, leftHand.pos.y);
  people.line(neck.pos.x, neck.pos.y, rightShoulder.pos.x, rightShoulder.pos.y);
  people.line(rightShoulder.pos.x, rightShoulder.pos.y, rightElbow.pos.x, rightElbow.pos.y);
  people.line(rightElbow.pos.x, rightElbow.pos.y, rightHand.pos.x, rightHand.pos.y);
  people.ellipse(head.pos.x, head.pos.y, 80, 80);
  color c = src[currentSrc].get((int) rightHand.pos.x, (int) rightHand.pos.y);
  people.strokeWeight(1);
  people.fill(c);
  people.ellipse(rightHand.pos.x, rightHand.pos.y, 30, 30);
  color d = src[currentSrc].get((int) leftHand.pos.x, (int) leftHand.pos.y);
  people.fill(d);
  people.ellipse(leftHand.pos.x, leftHand.pos.y, 30, 30);
  people.endDraw();

  attractorR.updateLocation(new PVector(rightHand.pos.x, rightHand.pos.y));
  attractorL.updateLocation(new PVector(leftHand.pos.x, leftHand.pos.y));
}


// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(int userId)
{
  println("onNewUser - userId: " + userId);
  context.requestCalibrationSkeleton(userId, true);
}

void onLostUser(int userId)
{
  println("onLostUser - userId: " + userId);
}

void onExitUser(int userId)
{
  println("onExitUser - userId: " + userId);
}

void onReEnterUser(int userId)
{
  println("onReEnterUser - userId: " + userId);
}

void onStartCalibration(int userId)
{
  println("onStartCalibration - userId: " + userId);
}

void onEndCalibration(int userId, boolean successfull)
{
  println("onEndCalibration - userId: " + userId + ", successfull: " + successfull);
  if (successfull) context.startTrackingSkeleton(userId);
  else context.requestCalibrationSkeleton(userId, true);
}

