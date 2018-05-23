import KinectPV2.KJoint;
import KinectPV2.*;

int MSG_WIDTH = 0;
int MSG_HEIGHT = 1;
int MSG_OPEN_HEIGHT = 2;
int MAX_DISPLAY_NO = 4;
//int FALLINGSPEED = 2;
int LETTER_TEXT_X = 40;
int LETTER_TEXT_Y = 70;
int OLD_LETTER_TEXT_X = 70;
int OLD_LETTER_TEXT_Y = 70;
int LETTER_LINE_LENGTH = 23;
int POSTCARD_LINE_LENGTH = 17;
int POSTCARD_TEXT_X = 30;
int POSTCARD_TEXT_Y = 100;
int[][] MSG_SIZE = new int[][]{new int[]{372, 270, 593}, new int[]{362, 213, 596}, new int[]{374, 241, 241}};
int[][] SPAWN_LOC = new int[][]{new int[]{500, 300}, new int[]{1500, 500}, new int[]{1000, 700}, new int[]{100, 200}};
String GRAPHICS_DIRECTORY = "graphics/";

int spawnLocController = 0;

ArrayList<Drawable> visualElements = new ArrayList<Drawable>();
ArrayList<Message> detectionPoints = new ArrayList<Message>();

boolean displayCapture = false;
boolean displayDetectionBoundary = false;
String mouseLoc;

KinectPV2 kinect;



void setup()
{
  fullScreen(P3D);
  textFont(createFont("Georgia", 20));
  frameRate(60);
  
  kinect = new KinectPV2(this);
  kinect.enableSkeletonColorMap(true);
  kinect.enableColorImg(true);
  kinect.init();
  loadVisuals();
  
  loadMessages();
}


void draw()
{
  
  clear();
  background(0);
  
  
  //println(faces.length);
  int[] location;
  ArrayList<KSkeleton> skeletonArray =  kinect.getSkeletonColorMap();
  KJoint[] joints;
  KJoint hand;
  if(displayDetectionBoundary)
  {
    noFill();
    stroke(0, 255, 0);
    strokeWeight(3);
    for(Message d : detectionPoints)
    {
      rect(d.range[0], d.range[2], d.range[1] - d.range[0], d.range[3] - d.range[2]);
    }
  }
  for(Message d : detectionPoints)
  {
    for (int i = 0; i < skeletonArray.size(); i++) {
      KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
      if (skeleton.isTracked()) {
        joints = skeleton.getJoints();
        hand = joints[KinectPV2.JointType_HandTipRight];
        color col  = skeleton.getIndexColor();
        fill(col);
        stroke(col);
        location = new int[]{int(hand.getX()), int(hand.getY())};
        drawJoint(joints, KinectPV2.JointType_HandTipRight); //<>//
        if(isBetween(d.range, location))
        {
          d.switchImg();
        }
      }
    }
  }
  
  renderAll();
  if(displayCapture)
  {
    image(kinect.getColorImage(), width - width/4, height - height/4, width/4, height/4);
  }
  fill(255);
  mouseLoc = mouseX + ", " + mouseY;
  text(mouseLoc, mouseX, mouseY);
  //println(frameRate);
}

boolean isBetween(int[] range, int[] location)
{
  if(location[0] > range[0] && location[0] < range[1]
  && location[1] > range[2] && location[1] < range[3])
  {
    return true;
  }
  else
  {
    return false;
  }
}

void renderAll()
{
  for(Drawable d : visualElements)
  {
    d.render();
  }
}

void drawJoint(KJoint[] joints, int jointType) {
  pushMatrix();
  translate(joints[jointType].getX(), joints[jointType].getY(), joints[jointType].getZ());
  ellipse(0, 0, 25, 25);
  popMatrix();
}

void loadVisuals()
{
  visualElements.add(new Drawable(width/2 - 250, height/2 - 250, 0, 500, 500, "graphics/frame.png"));
  visualElements.add(new Rotatable(width/2 + 60, height/2 + 30, 0, 180, 180, 1.05, "graphics/gear1.png", -90, -90));
  visualElements.add(new Rotatable(width/2 - 40, height/2 + 25, 0, 300, 300, -1, "graphics/gear2.png", -150, -150));
  visualElements.add(new Rotatable(width/2, height/2 - 70, 0, 220, 220, 1.05, "graphics/gear3.png", -110, -110));
  visualElements.add(new Drawable(width/2 - 125, height/2 - 125, 0, 250, 250, "graphics/element1.png"));
  visualElements.add(new Rotatable(width/2 + 7, height/2 - 5, 0, 100, 100, -1, "graphics/hour.png", 0, 0));
  visualElements.add(new Drawable(width/2 - 250, height/2 - 250, 0, 500, 500, "graphics/element2.png"));
}

void loadMessages()
{
  try
  {
    String[] lines = loadStrings("http://localhost:1234");
    for(String s : lines)
    {
      createMessage(s);
    }
  }
  catch(Exception e)
  {
    println(e.getMessage());
  }
}

void createMessage(String s)
{
  JSONObject msg = parseJSONObject(s);
  int spawnLocX = SPAWN_LOC[spawnLocController % MAX_DISPLAY_NO][0];
  int spawnLocY = SPAWN_LOC[spawnLocController % MAX_DISPLAY_NO][1];
  int msgtype = msg.getInt("msgtype");
  int newMsgWidth = MSG_SIZE[msgtype][MSG_WIDTH];
  int newMsgHeight =  MSG_SIZE[msgtype][MSG_HEIGHT];
  int newMsgOpenHeight = MSG_SIZE[msgtype][MSG_OPEN_HEIGHT];
  String newMsgCover =  GRAPHICS_DIRECTORY + msg.getString("cover");
  String newMsgMsg = msg.getString("message");
  String newMsgBack;
  int textX;
  int textY;
  int newMsgLineLength;
  String newMsgFrom = msg.getString("fromDate").substring(0, 10);
  //println(newMsgFrom);
  if(msgtype == 0 || msgtype == 1)
  {
    newMsgLineLength = LETTER_LINE_LENGTH;
    newMsgBack = newMsgCover + "-open.png";
    if(msgtype == 0)
    {
      textX = LETTER_TEXT_X;
      textY = LETTER_TEXT_Y;
    }
    else
    {
      textX = OLD_LETTER_TEXT_X;
      textY = OLD_LETTER_TEXT_Y;
    }
    
  }
  else
  {
    newMsgLineLength = POSTCARD_LINE_LENGTH;
    newMsgBack = GRAPHICS_DIRECTORY + "postback.png";
    textX = POSTCARD_TEXT_X;
    textY = POSTCARD_TEXT_Y;
  }
  newMsgCover += ".png";
  Message newMsg = new Message(new int[]{spawnLocX, spawnLocX + newMsgWidth, spawnLocY, spawnLocY + newMsgHeight}, newMsgMsg, int(random(1, 4)), newMsgFrom, textX, textY);
  newMsg.breakText(newMsgLineLength);
  newMsg.addDrawable(new Drawable(spawnLocX, spawnLocY, 0, newMsgWidth, newMsgHeight, newMsgCover));
  newMsg.addDrawable(new Drawable(spawnLocX, spawnLocY, 0, newMsgWidth, newMsgOpenHeight, newMsgBack));
  detectionPoints.add(newMsg);
  visualElements.add(newMsg);
  spawnLocController += 1;
}

public void keyPressed()
{
  if(key == 'c')// when r is pressed, the tree is regenerated
  {
    displayCapture = !displayCapture;
  }
  else if(key == 'd')
  {
    displayDetectionBoundary = !displayDetectionBoundary;
  }
}