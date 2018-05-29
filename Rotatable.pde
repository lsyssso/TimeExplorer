public class Rotatable extends Drawable
{
  float rotationZ;
  float rotateSpeed;
  int rotateAroundX;
  int rotateAroundY;
  float rotationY;
  public Rotatable(int x, int y, int z, int newWidth, int newHeight, float rotationZspeed, String imgUrl, int rotateAroundX, int rotateAroundY)
  {
    super(x, y, z, newWidth, newHeight, imgUrl);
    this.rotationZ = 0;
    this.rotateSpeed = rotationZspeed;
    this.rotateAroundX = rotateAroundX;
    this.rotateAroundY = rotateAroundY;
  }
  
  public Rotatable(int x, int y, int z, int newWidth, int newHeight, String imgUrl)
  {
    super(x, y, z, newWidth, newHeight, imgUrl);
    this.rotateAroundX = -newWidth / 2;
    this.rotateAroundY = -newHeight / 2;
  }
  
  public Rotatable(){}
  public void tick()
  {
    this.rotationZ += this.rotateSpeed;
  }
  
  public void render()
  {
    tick();
    pushMatrix();
    translate(this.x, this.y);
    rotate(radians(this.rotationZ));
    rotate(radians(this.rotationY));
    image(this.img, this.rotateAroundX, this.rotateAroundY, this.sizeWidth, this.sizeHeight);
    popMatrix();
  }
}