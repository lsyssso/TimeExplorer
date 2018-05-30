public class Message extends Drawable
{
  //range represents the range of detection area of the message
  //range[0] = x1, range[1] = x2, range[2] = y1, range[3] = y2
  int[] range;
  //stores a list of images to represent different state of the message
  //In this program the size of it won't get greater than 2
  ArrayList<Drawable> images = new ArrayList<Drawable>();
  //the text message
  String message;
  //status tells what's the state of this message
  //status > 0 means it's been triggered
  int status = 0;
  //falling speed
  int speedY;
  //animation state, 0 means the message is closed
  //1 means the message is opening
  //2 means the message is opened
  int transforming = 0;
  
  int opacity = 5;
  
  //position of text
  int textX;
  int textY;
  //when the message is from
  String timeStamp = "";
  
  
  public Message(int[] r, String m, int yspeed, String from, int textX, int textY)
  {
    super();
    this.range = r;
    this.message = m;
    this.speedY = yspeed;
    this.timeStamp = from;
    this.textX = textX;
    this.textY = textY;
  }
  
  public void move()
  {
    //change y1 and y2 of detection range
    range[2] += this.speedY;
    range[3] += this.speedY;
    //increment y value for every image
    for(Drawable d : images)
    {
      d.y += speedY;
    }
    //when y1 value of message is out of the screen
    if(range[2] > height)
    {
      //place it to the top of the screen
      range[3] = -300 + (range[3] - range[2]);
      range[2] = -300;

      for(Drawable d : images)
      {
        //reset images y value as well
        d.y = range[2];
      }
    }
  }
  

  
  public void render()
  {
    //check the status
    if(status > 0)//message is triggered by user
    {
      //check animation status
      if(transforming == 1)//is opening
      {
        //adjust the opacity to create a fade in effect
        tint(255, opacity);
        if(opacity > 255)
        {
          opacity = 255;
          //letter is opened, change animation status
          transforming = 2;
        }
        opacity += 25;
      }
      //once a message triggered, the status is set to 10, and each frame this number will be decremented
      //the effect of this is to create a more natural reaction to users, there is a instant short delay after
      //users move their hands away from the letter/postcard before start playing the animation
      status -= 1;
      images.get(1).render();
      //println(textX, textY);
      fill(0);
      text(this.message, images.get(1).x + textX, images.get(1).y + textY);
      text(this.timeStamp, images.get(1).x + textX, images.get(1).y + textY + 200);
    }
    else
    {
      //when the message is opened, detection areas is enlarged due to the change of image size
      //so when the the message is closed, the area is reseted.
      resetDetectionArea();
      move();
      images.get(0).render();
      //the message was at the state of fully opened
      //play with the opacity to create a fade out effect
      if(transforming == 2)
      {
        tint(255, opacity);
        if(opacity < 5)
        {
          transforming = 0;
          opacity = 5;
        }
        opacity -= 25;
        images.get(1).render();
        fill(0);
      } 
    }
    tint(255, 255);
  }
  
  public void addDrawable(Drawable d)
  {
    images.add(d);
  }
  
  public void switchImg()
  /*
  This method is called when user move hand into detection range
  */
  {
    if(status == 0) //the message is closed, switch animation state to 1
    {
      transforming = 1;
    }
    status = 10; //set status to 10
    enlargeDetectionArea();
  }
  
  public void breakText(int charPerLine)
  /*
  Due to the difference between letter and postcard in terms of size,
  we need to break the text into several lines based on the number of
  characters can fit into one line.
  */
  {
    //compute how many lines we need
    int lines = this.message.length() / charPerLine;
    int offset = 0;
    String newString = "";
    //break the text into lines
    for(int i = 1; i <= lines; i++)
    {
      newString = newString + this.message.substring(offset, offset + charPerLine) + "\n";
      offset = charPerLine * i;
    }
    //adding the last bit that is not long enough to fill a line
    newString = newString + this.message.substring(offset, this.message.length());
    this.message = newString;
  }
  
  protected void enlargeDetectionArea()
  {
    range[3] = range[2] + images.get(1).sizeHeight;
    range[1] = range[0] + images.get(1).sizeWidth;
  }
  
  protected void resetDetectionArea()
  {
    range[3] = range[2] + images.get(0).sizeHeight;
    range[1] = range[0] + images.get(0).sizeWidth;
  }
}