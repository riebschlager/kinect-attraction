import SimpleOpenNI.*;

SimpleOpenNI context;
ArrayList<Mover> moversL = new ArrayList<Mover>();
ArrayList<Mover> moversR = new ArrayList<Mover>();
//ArrayList<Attractor> attractors = new ArrayList<Attractor>();
Attractor attractorL, attractorR;
ArrayList<Integer> colors = new ArrayList<Integer>();
PGraphics canvas, people;

void setup() {
  size(displayWidth, displayHeight);
  background(255);
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
  canvas.noStroke();
  canvas.endDraw();

  people = createGraphics(width, height);
  people.beginDraw();
  people.endDraw();

  moversL.add(new Mover(1.5, new PVector(random(width), random(height)), 0.00095));
  moversL.add(new Mover(1.0, new PVector(random(width), random(height)), 0.00075));
  moversL.add(new Mover(0.5, new PVector(random(width), random(height)), 0.00025));

  moversR.add(new Mover(1.5, new PVector(random(width), random(height)), 0.00095));
  moversR.add(new Mover(1.0, new PVector(random(width), random(height)), 0.00075));
  moversR.add(new Mover(0.5, new PVector(random(width), random(height)), 0.00025));

  attractorL = new Attractor();
  attractorR = new Attractor();

  colors.add(color(0x224C2B2F));
  colors.add(color(0x22E57152));
  colors.add(color(0x22E8D367));
  colors.add(color(0x22FFEFC3));
  colors.add(color(0x22C0CCAB));
  colors.add(color(0x22666666));
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
  if (frameCount % 100 == 0) {
    if (context.getUsers().length==0) {
      //attractor.updateLocation(new PVector(random(width), random(height)));
    }
  }
  for (int j = 0; j < 10; j++) {
    for (int i = 0; i < moversL.size(); i++) {
      Mover m = moversL.get(i);
      m.applyForce(attractorL.attract(m));
      m.update();
      canvas.fill(colors.get(i));
      canvas.stroke(0, 10);
      canvas.strokeWeight(10);
      canvas.noStroke();
      canvas.ellipse(m.location.x, m.location.y, m.radius, m.radius);
    }
    for (int i = 0; i < moversR.size(); i++) {
      Mover m = moversR.get(i);
      m.applyForce(attractorR.attract(m));
      m.update();
      canvas.fill(colors.get(i+3));
      canvas.stroke(0, 10);
      canvas.strokeWeight(10);
      canvas.noStroke();
      canvas.ellipse(m.location.x, m.location.y, m.radius, m.radius);
    }
  }

  canvas.endDraw();
  image(canvas, 0, 0);
  image(people, 0, 0);
}

void nextColor() {
  //currentColor++;
  //currentColor = (currentColor >= colors.length) ? 0 : currentColor;
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

