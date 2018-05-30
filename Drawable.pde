public class Drawable
{
  //basic attributes
  int x;
  int y;
  //z is not used, but for the sake of extensibility, I leave it here
  int z;
  int sizeWidth;
  int sizeHeight;
  PImage img;
  
  public Drawable(int x, int y, int z, int newWidth, int newHeight, String imgUrl)
  {
    this.x = x;
    this.y = y;
    this.z = z;
    this.sizeWidth = newWidth;
    this.sizeHeight = newHeight;
    setImg(imgUrl);
  }
  
  public Drawable()
  {
  }
  
   public void render()
  {
    pushMatrix();
    translate(this.x, this.y);
    image(this.img, 0, 0, this.sizeWidth, this.sizeHeight);
    popMatrix();
  }
  
  public void setImg(String newImg)
  {
    this.img = loadImage(newImg);
    img.resize(sizeWidth, sizeHeight);
  }
}