public class Postcard extends Message
{
  //store an image for stamp
  PImage stamp;
  
  
  public Postcard(int[] r, String m, int yspeed, String from, int textX, int textY, String stampFileName)
  {
    super(r, m, yspeed, from, textX, textY);
    stamp = loadImage("graphics/" + stampFileName);
    stamp.resize(51, 45);
  } 
  
  public void render()
  /*
  Basically the same as Message.render(), just that Postcard will render the stamp as well.
  
  ***Can be refactored.
  */
  {
    if(status > 0)
    {
      if(transforming == 1)
      {
        tint(255, opacity);
        if(opacity > 255)
        {
          opacity = 255;
          transforming = 2;
        }
        opacity += 25;
      }
      status -= 1;
      images.get(1).render();
      fill(0);
      pushMatrix();
      translate(range[0], range[2]);
      image(stamp, 300, 45);
      popMatrix();
      text(this.message, images.get(1).x + textX, images.get(1).y + textY);
      text(this.timeStamp, images.get(1).x + textX, images.get(1).y + textY + 100);
    }
    else if(status == 0)
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
    } //<>//
    else if(status < 0)
    {
      tint(255, opacity);
      images.get(0).render();
      opacity -= 1;
    }
    tint(255, 255);
  }
}