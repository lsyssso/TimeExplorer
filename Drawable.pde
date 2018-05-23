public class Drawable
{
  int x;
  int y;
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
    img = loadImage(imgUrl);
    img.resize(newWidth, newHeight);
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