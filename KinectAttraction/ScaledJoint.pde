class ScaledJoint {
  PVector pos;
  ScaledJoint(SimpleOpenNI _context, int _userId, int _jointName) {
    pos = new PVector();
    _context.getJointPositionSkeleton(_userId, _jointName, pos);
    context.convertRealWorldToProjective(pos, pos);
    pos.mult(2);
  }
}

