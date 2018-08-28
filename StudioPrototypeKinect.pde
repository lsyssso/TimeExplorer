/*
This program requires library KinectPV2 to run, if you do not have it, 
please download it from Processing library manager.
*/

import KinectPV2.*;
import java.util.Collections;
import java.util.List;
import java.util.Arrays;
import processing.sound.*;
SoundFile file;
//each item specified the properties of different type of messages
//item 0 represents the properties of modern letter
//item 1 represents the properties of vintage letter
//item 2 represents the properties of postcard
int[][] MSG_SIZE = new int[][]{new int[]{186, 135, 372, 593}, new int[]{181, 106, 362, 596}, new int[]{187, 120, 374, 241}};
//the index to get different property from the an item of MSG_SIZE
int MSG_WIDTH = 0;
int MSG_HEIGHT = 1;
int MSG_OPEN_WIDTH = 2;
int MSG_OPEN_HEIGHT = 3;

//Specified how maximum number of people that program will draw their hands
int MAX_PLAYER_NUMBER = 3;
//Maximum number of message to be display at the same time
int MAX_DISPLAY_NO = 4;

//The position of the text, relative to the origin of the message
int LETTER_TEXT_X = 40;
int LETTER_TEXT_Y = 70;
int OLD_LETTER_TEXT_X = 70;
int OLD_LETTER_TEXT_Y = 70;
int POSTCARD_TEXT_X = 30;
int POSTCARD_TEXT_Y = 100;

//The number of characters to fit in one line, for each type of messages
int LETTER_LINE_LENGTH = 23;
int POSTCARD_LINE_LENGTH = 17;

//size of the hand icon which represents the hand of player
int HAND_ICON_SIZE = 70;

//There are four preset spawn locations, where messages will appear
int[][] SPAWN_LOC = new int[][]{new int[]{600, -300}, new int[]{1500, -300}, new int[]{1000, -300}, new int[]{200, -300}};

//Directory to graphical elements
String GRAPHICS_DIRECTORY = "graphics/";

//The Url of data server
String URL = "http://209.97.175.95:8082";

//Envelope colours
String[] ENVELOPE_STYLE = new String[]{"Ivory", "Yellow", "Pink", "Caramel", "Purple", "Greenish", "Brown"};

//For controlling which spawn location is used for next created message
int spawnLocController = 0;

//visualelements stores non-interactable visuals
ArrayList<Drawable> visualElements = new ArrayList<Drawable>();
//messageBuffer stores the messages created from loaded data
ArrayList<Message> messageBuffer = new ArrayList<Message>();
//detectionPoints stores the actual messages to be shown on screen
ArrayList<Message> detectionPoints = new ArrayList<Message>();

//control whether to show the vision of Kinect
boolean displayCapture = false;
//control whether to show the boundary of detection areas
boolean displayDetectionBoundary = false;
//To tell whether the buffer has been updated
boolean messageBufferUpdated = false;
//To store an image showing instruction
PImage bubble;

//To store visual elements representing hand
PImage[] hands = new PImage[3];

int reloadCountDown = 255;

KinectPV2 kinect;



void setup()
{
  //P3D has better performance
  fullScreen(P3D);
  //setup font size and style
  textFont(createFont("Georgia", 20));
  frameRate(60);
  file = new SoundFile(this, "C:\\Users\\stewa\\Desktop\\StudioPrototypeKinect\\clock.wav");
  file.loop();
  //initialize Kinect
  kinect = new KinectPV2(this);
  kinect.enableSkeletonColorMap(true);
  kinect.enableColorImg(true);
  kinect.init();
  //Loading non-interactive visuals
  loadVisuals();
  //Setting up other visuals
  bubble = loadAndResize(GRAPHICS_DIRECTORY + "bubble.png", 200, 200);
  hands[0] = loadAndResize(GRAPHICS_DIRECTORY + "hand0.png", HAND_ICON_SIZE, HAND_ICON_SIZE);
  hands[1] = loadAndResize(GRAPHICS_DIRECTORY + "hand1.png", HAND_ICON_SIZE, HAND_ICON_SIZE);
  hands[2] = loadAndResize(GRAPHICS_DIRECTORY + "hand2.png", HAND_ICON_SIZE, HAND_ICON_SIZE);
  //updating message every 10 mins, running on another thread
  thread("checkUpdate");
}


void draw()
{
  
  //refresh background
  background(20);
  //check if buffer is updated
  if(reloadCountDown > 0)
  {
    reloadCountDown -= 1;
  }
  if(messageBufferUpdated && reloadCountDown <= 0)
  {
    thread("loadFromBuffer");   
  }
  
  //initialize variables for calculation
  int[] rightHandLoc;
  int[] leftHandLoc;
  //Reading skeleton data
  ArrayList<KSkeleton> skeletonArrayAll =  kinect.getSkeletonColorMap();
  
  //Due the fact that Kinect will put most recent detected skeleton to the first position
  //We may run into a situation that user find Kinect lose track of them when the player number
  //reaches the limit set by us and a new user wants to join in.
  
  //create another skeleton array, which will be the one for calculation
  ArrayList<KSkeleton> skeletonArray = new ArrayList<KSkeleton>();
  //specify how many skeleton we want to get from the raw skeleton array
  int numberOfPlayers = MAX_PLAYER_NUMBER;
  if(skeletonArrayAll.size() <= MAX_PLAYER_NUMBER)
  {
    numberOfPlayers = skeletonArrayAll.size();
  }
  
  //pop one skeleton from the end of list each time
  //which prevents existing user being pushed out
  for(int i = 0; i < numberOfPlayers; i++)
  {
    skeletonArray.add(skeletonArrayAll.remove(skeletonArrayAll.size() - 1));
  }
  
  KJoint[] joints;
  KJoint rightHand;
  KJoint leftHand;
  renderBackground();
  
  //show detection boundary if we want to
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
  
  //display the instruction bubble
  image(bubble, 0, height - (frameCount % height));
  renderMessages();
  
  //preparing variables to map user's hand to the screen
  float rightX;
  float leftX;
  float rightY;
  float leftY;
  //start checking if there is hand within detection areas
  for(Message d : detectionPoints)
  {
    if(isBetween(d.range, new int[]{mouseX, mouseY})
    {
      d.switchImg();
    }
    //traverse every skeleton
    for (int i = 0; i < skeletonArray.size(); i++) {
      KSkeleton skeleton = (KSkeleton) skeletonArray.get(i);
      if (skeleton.isTracked()) {
        //get the joint for both hands
        joints = skeleton.getJoints();
        rightHand = joints[KinectPV2.JointType_HandTipRight];
        leftHand = joints[KinectPV2.JointType_HandTipLeft];
        
        //Kinect has a smaller resolution so we have to map the position of x value to bigger screen
        rightX = map(rightHand.getX(), 360, 1600, 0, 1900);
        leftX = map(leftHand.getX(), 360, 1600, 0, 1900);
        //Y value doesn't seem to be impacting a lot
        rightY = rightHand.getY();
        leftY = leftHand.getY();
        rightHandLoc = new int[]{int(rightX), int(rightY)};
        leftHandLoc = new int[]{int(leftX), int(leftY)};
        
        //draw the hands
        drawJoint(rightX, rightY, i, true);
        drawJoint(leftX, leftY, i, false); //<>//
        
        //check whether a hand is within the detection area
        if(isBetween(d.range, rightHandLoc) || isBetween(d.range, leftHandLoc))
        {
          //open the envelope/postcard
          d.switchImg();
        }
      }
    }
  }
  
  if(displayCapture)
  {
    image(kinect.getColorImage(), width - width/4, height - height/4, width/4, height/4);
  }
}

public boolean isBetween(int[] range, int[] location)
/* Check if a given pair of x and y is within given area.
*/
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

public void renderBackground()
/*
render each non-interactive elements
*/
{
  for(Drawable d : visualElements)
  {
    d.render();
  }
}

public void renderMessages()
/*
render each interactive messages
*/
{
  for(Message m : detectionPoints)
  {
    m.render();
  }
}


public void drawJoint(float x, float y, int colour, boolean isRightHand) 
/*
Draw a hand of user
*/
{
  pushMatrix();
  translate(x, y);
  if(isRightHand)
  {
    //flip the image
    scale(-1, 1);
  }
  image(hands[colour], 0, 0);
  popMatrix();
}

public void loadVisuals()
/*
Creating every non-interactive element
*/
{
  
  visualElements.add(new Drawable(width/2 - 135, height/2 - 350, 0, 250, 250, "graphics/frame.png"));
  visualElements.add(new Rotatable(width/2 + 15, height/2 - 205, 0, 90, 90, 1.05, "graphics/gear1.png", -45, -45));
  visualElements.add(new Rotatable(width/2 - 40, height/2 - 215, 0, 150, 150, -1, "graphics/gear2.png", -75, -75));
  visualElements.add(new Rotatable(width/2 - 15, height/2 - 250, 0, 110, 110, 1.05, "graphics/gear3.png", -55, -55));
  visualElements.add(new Drawable(width/2 - 78, height/2 - 288, 0, 125, 125, "graphics/element1.png"));
  visualElements.add(new Rotatable(width/2 - 10, height/2 - 225, 0, 50, 50, 2, "graphics/hour.png", 0, 0));
  visualElements.add(new Drawable(width/2 - 140, height/2 - 350, 0, 250, 250, "graphics/element2.png"));
  
  
  visualElements.add(new Drawable(width/2 - 450, height/2 - 250, 0, 500, 500, "graphics/frame.png"));
  visualElements.add(new Rotatable(width/2 - 140, height/2 + 30, 0, 180, 180, 1.05, "graphics/gear1.png", -90, -90));
  visualElements.add(new Rotatable(width/2 - 240, height/2 + 25, 0, 300, 300, -1, "graphics/gear2.png", -150, -150));
  visualElements.add(new Rotatable(width/2 - 200, height/2 - 70, 0, 220, 220, 1.05, "graphics/gear3.png", -110, -110));
  visualElements.add(new Drawable(width/2 - 325, height/2 - 125, 0, 250, 250, "graphics/element1.png"));
  visualElements.add(new Rotatable(width/2 - 193, height/2 - 5, 0, 100, 100, -1, "graphics/hour.png", 0, 0));
  visualElements.add(new Drawable(width/2 - 450, height/2 - 250, 0, 500, 500, "graphics/element2.png"));
  
  visualElements.add(new Drawable(width/2 - 45, height/2 - 50, 0, 250, 250, "graphics/frame.png"));
  visualElements.add(new Rotatable(width/2 + 105, height/2 + 95, 0, 90, 90, 1.05, "graphics/gear1.png", -45, -45));
  visualElements.add(new Rotatable(width/2 + 50, height/2 + 85, 0, 150, 150, -1, "graphics/gear2.png", -75, -75));
  visualElements.add(new Rotatable(width/2 + 75, height/2 + 50, 0, 110, 110, 1.05, "graphics/gear3.png", -55, -55));
  visualElements.add(new Drawable(width/2 + 12, height/2 + 12, 0, 125, 125, "graphics/element1.png"));
  visualElements.add(new Rotatable(width/2 + 80, height/2 + 75, 0, 50, 50, -5, "graphics/hour.png", 0, 0));
  visualElements.add(new Drawable(width/2 - 50, height/2 - 50, 0, 250, 250, "graphics/element2.png"));
  
  /*
  visualElements.add(new Drawable(width/2 - 250, height/2 - 250, 0, 500, 500, "graphics/frame.png"));
  visualElements.add(new Rotatable(width/2 + 60, height/2 + 30, 0, 180, 180, 1.05, "graphics/gear1.png", -90, -90));
  visualElements.add(new Rotatable(width/2 - 40, height/2 + 25, 0, 300, 300, -1, "graphics/gear2.png", -150, -150));
  visualElements.add(new Rotatable(width/2, height/2 - 70, 0, 220, 220, 1.05, "graphics/gear3.png", -110, -110));
  visualElements.add(new Drawable(width/2 - 125, height/2 - 125, 0, 250, 250, "graphics/element1.png"));
  visualElements.add(new Rotatable(width/2 + 7, height/2 - 5, 0, 100, 100, -1, "graphics/hour.png", 0, 0));
  visualElements.add(new Drawable(width/2 - 250, height/2 - 250, 0, 500, 500, "graphics/element2.png"));
  */
}

void loadMessages()
/*
try loading messages from the server and create Message objects
then saving objects to the buffer
*/
{
  println("loading messages...");
  try
  {
    List<String> lines = Arrays.asList(loadStrings(URL));
    //randomize the order
    Collections.shuffle(lines);
    //clean messagebuffer
    messageBuffer = new ArrayList<Message>();
    spawnLocController = 0;
    for(String s : lines)
    {
      createMessage(s);
    }
    
    messageBufferUpdated = true;
    //prepard from loading from buffer
    for(Message m : detectionPoints)
    {
      if(m.status == 0)
      {
        m.setOpacity(255);
        //Move detection range to an unreachable location 
        m.range = new int[]{-300, -300, -300, -300};
        m.status = -1;
      }
    }
    reloadCountDown = 85;
  }
  catch(Exception e)
  {
    println(e.getMessage());
  }
}

public void createMessage(String s)
/*
Given a JSON string, create a Message object and add to buffer
*/
{
  JSONObject msg = parseJSONObject(s);
  //loading properties of the message and store them in variables
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
  
  //Checking message type, 0 = modern letter, 1 = vintage letter, 2 = postcard
  if(msgtype == 0 || msgtype == 1) //letter
  {
    //Set the line length
    newMsgLineLength = LETTER_LINE_LENGTH;
    
    //Set text position depends on text type
    if(msgtype == 0)
    {
      textX = LETTER_TEXT_X;
      textY = LETTER_TEXT_Y;
      newMsgCover = GRAPHICS_DIRECTORY + ENVELOPE_STYLE[int(random(0, ENVELOPE_STYLE.length))];
    }
    else
    {
      textX = OLD_LETTER_TEXT_X;
      textY = OLD_LETTER_TEXT_Y;
    }
    
    newMsgBack = newMsgCover + "-open.png";
    newMsgCover += ".png";
    //Create new instance of messagew
    newMsg = new Message(new int[]{spawnLocX, spawnLocX + newMsgWidth, spawnLocY, spawnLocY + newMsgHeight}, newMsgMsg, int(random(2, 5)), newMsgFrom, textX, textY);
  }
  else //postcard
  {
    newMsgStamp = msg.getString("stamp");
    newMsgLineLength = POSTCARD_LINE_LENGTH;
    newMsgBack = GRAPHICS_DIRECTORY + "postback.png";
    textX = POSTCARD_TEXT_X;
    textY = POSTCARD_TEXT_Y;
    newMsgCover += ".png";
    newMsg = new Postcard(new int[]{spawnLocX, spawnLocX + newMsgWidth, spawnLocY, spawnLocY + newMsgHeight}, newMsgMsg, int(random(2, 5)), newMsgFrom, textX, textY, newMsgStamp);
  }
  //Process the text to fit in the area
  newMsg.breakText(newMsgLineLength);
  //Adding images each reflecting a state of message
  newMsg.addDrawable(new Drawable(spawnLocX, spawnLocY, 0, newMsgWidth, newMsgHeight, newMsgCover));
  newMsg.addDrawable(new Drawable(spawnLocX, spawnLocY, 0, newMsgOpenWidth, newMsgOpenHeight, newMsgBack));
  messageBuffer.add(newMsg);
  //determine where next generated message will spawn
  spawnLocController = (spawnLocController + 1) % MAX_DISPLAY_NO;
}


public void keyPressed()
{
  if(key == 'c')
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
/*
Loading messages from buffer, maximum allowed number of
messages will be loaded
*/
{
  int quantity = messageBuffer.size();
  if(quantity > MAX_DISPLAY_NO)
  {
    quantity = MAX_DISPLAY_NO;
  }
  if(detectionPoints.size() == 0)
  {
  //clean current messages
    detectionPoints = new ArrayList<Message>();
    for(int i = 0; i < quantity; i++)
    {
      detectionPoints.add(messageBuffer.remove(0));
    }
  }
  else
  {for(int i = 0; i < quantity; i++)
    {
      try
      {
        if(detectionPoints.get(i).status < 0)
        {
          detectionPoints.set(i, messageBuffer.get(i));
        }
      }
      catch(IndexOutOfBoundsException e)
      {
        detectionPoints.add(messageBuffer.get(i));
      }
    }
    
  }
  messageBufferUpdated = false;
}

PImage loadAndResize(String directory, int newWidth, int newHeight)
/*
A small unility to resize the loaded image for better performance
*/
{
  PImage newImage = loadImage(directory);
  newImage.resize(newWidth, newHeight);
  return newImage;
}

public void checkUpdate()
{
  while(true)
  {
    println("updating...");
    loadMessages();
    delay(60000);
  }
}