private java.util.List<Particle> particles = new ArrayList<Particle>();
void setup() {
  size(1900, 1000);
  noStroke();
  colorMode(HSB);
  textSize(20);
  textAlign(BOTTOM, LEFT);
}
void draw() {
  fill(0x22000000);
  rect(0, 0, width, height);
  for (Particle particle : new ArrayList<Particle>(particles))
    particle.update();
  for (Particle particle : particles)
    particle.draw();
  fill(0xff000000);
  rect(0, height-20, textWidth(""+particles.size()), 20);
  fill(255);
  text(particles.size(), 0, height);
}
long heldSince = -1;
float[] mousePos;
void mousePressed() {
  heldSince = millis();
  mousePos = new float[]{mouseX, mouseY};
}
void mouseReleased() {
  long held = millis() - heldSince;
  double magn= 20*Math.log(dist(mousePos[0], mousePos[1], mouseX, mouseY));
  double dir = Math.atan((mouseY-mousePos[1])/( mousePos[0] - mouseX )) + (mousePos[0] > mouseX ? PI : 0);
  heldSince = -1;
  if (held < 1500) held = Math.round(1000+Math.random()*150);
  if (dir != dir) dir = radians(50)+Math.random()*radians(80);
  particles.add(new Firework(width/2, (int)Math.ceil(held/125f), Math.max(Math.min(magn, 300), 100), Math.min(Math.max(dir, radians(50)), radians(130))));
}
abstract class Particle {
  protected float[] loc;
  protected final int radius;
  protected color colour;
  protected Particle(float x, float y, int r, color c) {
    this.loc = new float[]{x, y};
    this.radius = r;
    this.colour = c;
  }
  public void draw() {
    fill(this.colour);
    ellipse(this.loc[0], this.loc[1], this.radius, this.radius);
  }
  abstract void update();
}
class Projectile extends Particle {
  private double[] vel;
  protected float time = 0;
  private long ltime;
  public Projectile(float x, int vx, int vy, color c) {
    this(x, height, 5, c, new double[]{vx, vy});
  }
  protected Projectile(float x, float y, int r, color c, double[] vel) {
    super(x, y, r, c);
    this.vel = vel;
    this.ltime = millis();
  }
  public void update() {
    if (this.loc[1] > height) {particles.remove(this); return;}
    long ctime = millis();
    float mult = (ctime-ltime)/1000f;
    this.ltime = ctime;
    this.time += mult;
    this.vel[1] -= 9.8 * mult;
    super.loc[0] += this.vel[0] * mult;
    super.loc[1] -= this.vel[1] * mult;
  }
}
class Firework extends Projectile {
  private float colourVel, alphaVel;
  private long fuse;
  public Firework(int x, int r, double v, double dir) {
    super(x, height, r, color(Math.round(Math.random()*255), 255, 255), new double[]{v*Math.cos(dir), v*Math.sin(dir)});
    this.colourVel = 0;
    this.alphaVel = 0;
    this.fuse = Math.max((long)Math.floor(v*Math.sin(dir)/9.8)-1, 2);
  }
  private Firework(float x, float y, int r, color c, double[] vel, float colourVel, float alphaVel, long fuse) {
    super(x, y, r, c, vel);
    this.colourVel = colourVel;
    this.alphaVel = alphaVel;
    this.fuse = fuse;
  }
  public void update() {
    if (this.loc[1] > height || alpha(this.colour) <= 0) {particles.remove(this); return;}
    super.update();
    this.colour = color(hue(this.colour)+this.colourVel, saturation(this.colour), brightness(this.colour), alpha(this.colour)-this.alphaVel);
    if (this.fuse > 0 && super.time >= this.fuse) {
      particles.remove(this);
      if (this.radius < 5) return;
      int v = (int)Math.ceil(15+Math.random()*7);
      for (double dir = radians(10); dir < TWO_PI; dir += radians(20)+radians(20)*Math.random())
        particles.add(super.radius > 10
          ? new Firework(super.loc[0], super.loc[1], super.radius/2, super.colour, new double[]{v*Math.cos(dir)*1.5+super.vel[0]*0.5, v*Math.sin(dir)*1.5+super.vel[1]*1.2}, this.colourVel, 3f/this.fuse, (long)Math.sqrt(this.fuse))
          : new Firework(super.loc[0], super.loc[1], super.radius/2, super.colour, new double[]{v*Math.cos(dir)+super.vel[0]*0.7, v*Math.sin(dir)+super.vel[1]}, this.colourVel, 0.5, -1)
        );
      return;
    }
  }
}
