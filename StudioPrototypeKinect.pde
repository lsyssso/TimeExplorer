import KinectPV2.KJoint;
import KinectPV2.*;

int MSG_WIDTH = 0;
int MSG_HEIGHT = 1;
int MSG_OPEN_WIDTH = 2;
int MSG_OPEN_HEIGHT = 3;
int MAX_PLAYER_NUMBER = 3;
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
int HAND_ICON_SIZE = 70;
int[][] MSG_SIZE = new int[][]{new int[]{186, 135, 372, 593}, new int[]{181, 106, 362, 596}, new int[]{187, 120, 374, 241}};
int[][] SPAWN_LOC = new int[][]{new int[]{600, 300}, new int[]{1500, 500}, new int[]{1000, 700}, new int[]{200, 200}};
String GRAPHICS_DIRECTORY = "graphics/";
String URL = "http://209.97.175.95:8081";

int spawnLocController = 0;

ArrayList<Message> messageBuffer = new ArrayList<Message>();
ArrayList<Drawable> visualElements = new ArrayList<Drawable>();
ArrayList<Message> detectionPoints;

boolean displayCapture = false;
boolean displayDetectionBoundary = false;
boolean messageBufferUpdated = false;
String mouseLoc;
PImage bubble;
PImage[] hands = new PImage[3];
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
  bubble = loadAndResize(GRAPHICS_DIRECTORY + "bubble.png", 200, 200);
  hands[0] = loadAndResize(GRAPHICS_DIRECTORY + "hand0.png", HAND_ICON_SIZE, HAND_ICON_SIZE);
  hands[1] = loadAndResize(GRAPHICS_DIRECTORY + "hand1.png", HAND_ICON_SIZE, HAND_ICON_SIZE);
  hands[2] = loadAndResize(GRAPHICS_DIRECTORY + "hand2.png", HAND_ICON_SIZE, HAND_ICON_SIZE);
  loadMessages();
  loadFromBuffer();
  thread("checkUpdate");
}


void draw()
{
  
  clear();
  background(0);
  if(messageBufferUpdated)
  {
    loadFromBuffer();
  }
  int[] rightHandLoc;
  int[] leftHandLoc;
  ArrayList<KSkeleton> skeletonArrayAll =  kinect.getSkeletonColorMap();
  ArrayList<KSkeleton> skeletonArray = new ArrayList<KSkeleton>();
  int numberOfPlayers = MAX_PLAYER_NUMBER;
  if(skeletonArrayAll.size() <= 3)
  {
    numberOfPlayers = skeletonArrayAll.size();
  }
  for(int i = 0; i < numberOfPlayers; i++)
  {
    skeletonArray.add(skeletonArrayAll.remove(skeletonArrayAll.size() - 1));
  }

  KJoint[] joints;
  KJoint rightHand;
  KJoint leftHand;
  renderBackground();
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
  image(bubble, 0, height - 200);
  fill(0);
  text("Try waving \nyour hand!", 20, height - 150);
  renderMessages();
  float rightX;
  float leftX;
  float rightY;
  float leftY;
  for(Message d : detectionPoints)
  {
    for (int i = 0; i < skeletonArray.size(); i++) {
      KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
      if (skeleton.isTracked()) {
        joints = skeleton.getJoints();
        rightHand = joints[KinectPV2.JointType_HandTipRight];
        leftHand = joints[KinectPV2.JointType_HandTipLeft];
        color col  = skeleton.getIndexColor();
        fill(col);
        stroke(col);
        rightX = map(rightHand.getX(), 360, 1600, 0, 1900);
        leftX = map(leftHand.getX(), 360, 1600, 0, 1900);
        rightY = rightHand.getY();
        leftY = leftHand.getY();
        rightHandLoc = new int[]{int(rightX), int(rightY)};
        leftHandLoc = new int[]{int(leftX), int(leftY)};
        drawJoint(rightX, rightY, i, true); //<>//
        drawJoint(leftX, leftY, i, false);
        if(isBetween(d.range, rightHandLoc) || isBetween(d.range, leftHandLoc))
        {
          d.switchImg();
        }
      }
    }
  }
  
  
  if(displayCapture)
  {
    image(kinect.getColorImage(), width - width/4, height - height/4, width/4, height/4);
  }
  //fill(255);
  //mouseLoc = mouseX + ", " + mouseY;
  //text(mouseLoc, mouseX, mouseY);
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

void renderBackground()
{
  for(Drawable d : visualElements)
  {
    d.render();
  }
}

void renderMessages()
{
  for(Message m : detectionPoints)
  {
    m.render();
  }
}

void drawJoint(float x, float y, int index, boolean isRightHand) {
  pushMatrix();
  translate(x, y);
  if(isRightHand)
  {
    scale(-1, 1);
  }
  image(hands[index], 0, 0);
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
  println("loading messages...");
  try
  {
    String[] lines = loadStrings(URL);
    messageBuffer = new ArrayList<Message>();
    for(String s : lines)
    {
      createMessage(s);
    }
    messageBufferUpdated = true;
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
  int newMsgOpenWidth = MSG_SIZE[msgtype][MSG_OPEN_WIDTH];
  int newMsgOpenHeight = MSG_SIZE[msgtype][MSG_OPEN_HEIGHT];
  String newMsgStamp;
  String newMsgCover =  GRAPHICS_DIRECTORY + msg.getString("cover");
  String newMsgMsg = msg.getString("message");
  String newMsgBack;
  int textX;
  int textY;
  int newMsgLineLength;
  String newMsgFrom = msg.getString("fromDate").substring(0, 10);
  Message newMsg;
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
    newMsgCover += ".png";
    newMsg = new Message(new int[]{spawnLocX, spawnLocX + newMsgWidth, spawnLocY, spawnLocY + newMsgHeight}, newMsgMsg, int(random(2, 10)), newMsgFrom, textX, textY);
  }
  else
  {
    newMsgStamp = msg.getString("stamp");
    newMsgLineLength = POSTCARD_LINE_LENGTH;
    newMsgBack = GRAPHICS_DIRECTORY + "postback.png";
    textX = POSTCARD_TEXT_X;
    textY = POSTCARD_TEXT_Y;
    newMsgCover += ".png";
    newMsg = new Postcard(new int[]{spawnLocX, spawnLocX + newMsgWidth, spawnLocY, spawnLocY + newMsgHeight}, newMsgMsg, int(random(2, 10)), newMsgFrom, textX, textY, newMsgStamp);
  }
  newMsg.breakText(newMsgLineLength);
  newMsg.addDrawable(new Drawable(spawnLocX, spawnLocY, 0, newMsgWidth, newMsgHeight, newMsgCover));
  newMsg.addDrawable(new Drawable(spawnLocX, spawnLocY, 0, newMsgOpenWidth, newMsgOpenHeight, newMsgBack));
  messageBuffer.add(newMsg);
  //visualElements.add(newMsg);
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
  else if(key == 'r')
  {
    thread("loadMessages");
  }
}

public void loadFromBuffer()
{
  int quantity = messageBuffer.size();
  if(quantity > MAX_DISPLAY_NO)
  {
    quantity = MAX_DISPLAY_NO;
  }
  detectionPoints = new ArrayList<Message>();
  for(int i = 0; i < quantity; i++)
  {
    detectionPoints.add(messageBuffer.get(i));
  }
  messageBufferUpdated = false;
}

PImage loadAndResize(String directory, int newWidth, int newHeight)
{
  PImage newImage = loadImage(directory);
  newImage.resize(newWidth, newHeight);
  return newImage;
}

public void checkUpdate()
{
  while(true)
  {
    delay(600000);
    println("updating...");
    loadMessages();
  }
}