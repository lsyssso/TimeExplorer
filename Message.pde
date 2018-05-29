public class Message extends Drawable
{
  int[] range;
  int imgIndex = 0;
  ArrayList<Drawable> images = new ArrayList<Drawable>();
  String message;
  int status = 0;
  int speedY = 1;
  //int speedX = 0;
  int transforming = 0;
  int opacity = 5;
  int textX;
  int textY;
  String timeStamp = "";
  
  
  public Message(int[] r, String m, int yspeed, String from, int textX, int textY)
  {
    super();
    this.range = r;
    this.message = m;
    //this.speedX = xspeed;
    this.speedY = yspeed;
    this.timeStamp = from;
    this.textX = textX;
    this.textY = textY;
  }
  
  public boolean move()
  {
    range[2] += this.speedY;
    range[3] += this.speedY;
    for(Drawable d : images)
    {
      d.y += speedY;
    }
    if(range[2] > height)
    {
      range[3] = -300 + (range[3] - range[2]);
      range[2] = -300;

      for(Drawable d : images)
      {

        d.y = range[2];
      }
      return true;
    }
    return false;
  }
  

  
  public void render()
  {
    if(status > 0)
    {
      if(transforming == 1)
      {
        tint(255, opacity);
        if(opacity > 255)
        {
          transforming = 2;
        }
        opacity += 25;
      }
      status -= 1;
      images.get(1).render();
      //println(textX, textY);
      fill(0);
      text(this.message, images.get(1).x + textX, images.get(1).y + textY);
      text(this.timeStamp, images.get(1).x + textX, images.get(1).y + textY + 200);
    }
    else
    {
      resetDetectionArea();
      move();
      images.get(0).render();
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
  {
    if(status < 10)
    {
      if(status == 0)
      {
        transforming = 1;
      }
      status = 10;
      enlargeDetectionArea();
    }
  }
  
  public void breakText(int charPerLine)
  {
    int lines = this.message.length() / charPerLine;
    int offset = 0;
    String newString = "";
    for(int i = 1; i <= lines; i++)
    {
      newString = newString + this.message.substring(offset, offset + charPerLine) + "\n";
      offset = charPerLine * i;
    }
    newString = newString + this.message.substring(offset, this.message.length());
    //println(newString);
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