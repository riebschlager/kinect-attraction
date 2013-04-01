import SimpleOpenNI.*;

SimpleOpenNI context;
boolean autoCalib = true;
Mover[] movers = new Mover[3];
Attractor attractor;
int[] colors = new int[5];
int[] distances;
int currentColor = 0;
PGraphics canvas, people;
boolean isWhite = false;

void setup() {
  context = new SimpleOpenNI(this);

  if (context.enableDepth() == false)
  {
    println("Can't open the depthMap, maybe the camera is not connected!"); 
    exit();
    return;
  }

  context.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
  context.setMirror(true);

  background(255);
  size(1280, 800);
  canvas = createGraphics(width, height);
  canvas.beginDraw();
  canvas.noStroke();
  canvas.endDraw();

  people = createGraphics(width, height);
  people.beginDraw();
  people.endDraw();
  movers[0] = new Mover(1.5, new PVector(random(width), random(height)), 0.00095);
  movers[1] = new Mover(1.0, new PVector(random(width), random(height)), 0.00075);
  movers[2] = new Mover(0.5, new PVector(random(width), random(height)), 0.00025);
  attractor = new Attractor();
  colors[0] = color(70, 100);
  colors[1] = color(255, 117, 0, 100);
  colors[2] = color(12, 107, 161, 100);
  distances = new int[movers.length];
}

void draw() {
  background(255);
  context.update();
  people.beginDraw();
  people.background(0, 0);
  people.endDraw();

  int[] userList = context.getUsers();
  for (int i=0;i<userList.length;i++)
  {
    if (context.isTrackingSkeleton(userList[i]))
      drawSkeleton(userList[i]);
  }
  canvas.beginDraw();
  if (frameCount % 250 == 0) {
    isWhite = !isWhite;
  }
  if (frameCount % 100 == 0) {
    if (context.getUsers().length==0) {
      attractor.updateLocation(new PVector(random(width), random(height)));
    }
  }
  for (int j = 0; j < 5; j++) {
    for (int i = 0; i < movers.length; i++) {
      movers[i].applyForce(attractor.attract(movers[i]));
      movers[i].update();
      canvas.fill(colors[i]);

      canvas.stroke(0, 10);
      canvas.strokeWeight(10);
      if (isWhite) {
        canvas.fill(0x99FFFFFF);
      }
      if (movers[i].distance > 10) canvas.ellipse(movers[i].location.x, movers[i].location.y, movers[i].radius, movers[i].radius);
      canvas.stroke(0, 10);
      canvas.strokeWeight(1);
      canvas.line(movers[0].location.x, movers[0].location.y, movers[1].location.x, movers[1].location.y);
    }
  }

  canvas.endDraw();
  image(canvas, 0, 0);
  image(people, 0, 0);
}

void nextColor() {
  currentColor++;
  currentColor = (currentColor >= colors.length) ? 0 : currentColor;
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

  people.stroke(0);
  people.strokeWeight(10);
  people.line(head.pos.x, head.pos.y, neck.pos.x, neck.pos.y);
  people.line(neck.pos.x, neck.pos.y, leftShoulder.pos.x, leftShoulder.pos.y);
  people.line(leftShoulder.pos.x, leftShoulder.pos.y, leftElbow.pos.x, leftElbow.pos.y);
  people.line(leftElbow.pos.x, leftElbow.pos.y, leftHand.pos.x, leftHand.pos.y);
  people.line(neck.pos.x, neck.pos.y, rightShoulder.pos.x, rightShoulder.pos.y);
  people.line(rightShoulder.pos.x, rightShoulder.pos.y, rightElbow.pos.x, rightElbow.pos.y);
  people.line(rightElbow.pos.x, rightElbow.pos.y, rightHand.pos.x, rightHand.pos.y);
  people.ellipse(head.pos.x, head.pos.y, 100, 100);
  people.endDraw();

  attractor.updateLocation(new PVector(rightHand.pos.x, rightHand.pos.y));
}


// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(int userId)
{
  println("onNewUser - userId: " + userId);
  println("  start pose detection");

  if (autoCalib)
    context.requestCalibrationSkeleton(userId, true);
  else    
    context.startPoseDetection("Psi", userId);
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

  if (successfull) 
  { 
    println("  User calibrated !!!");
    context.startTrackingSkeleton(userId);
  } 
  else 
  { 
    println("  Failed to calibrate user !!!");
    println("  Start pose detection");
    context.startPoseDetection("Psi", userId);
  }
}

void onStartPose(String pose, int userId)
{
  println("onStartPose - userId: " + userId + ", pose: " + pose);
  println(" stop pose detection");

  context.stopPoseDetection(userId); 
  context.requestCalibrationSkeleton(userId, true);
}

void onEndPose(String pose, int userId)
{
  println("onEndPose - userId: " + userId + ", pose: " + pose);
}

