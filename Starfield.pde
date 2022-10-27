private java.util.List<Particle> particles = new ArrayList<Particle>();
void setup() {
  size(1900, 1000);
  noStroke();
  colorMode(HSB);
}
void draw() {
  fill(0x22000000);
  rect(0, 0, width, height);
  for (Particle particle : new ArrayList<Particle>(particles))
    particle.update();
  for (Particle particle : particles)
    particle.draw();
}
long heldSince = -1;
void mousePressed() {
  heldSince = System.currentTimeMillis();
}
void mouseReleased() {
  long held = Math.max(System.currentTimeMillis() - heldSince, Math.round(950+Math.random()*100));
  heldSince = -1;
  particles.add(new Firework(width/2, (int)Math.ceil(held/250f), Math.sqrt(held)*2.3, Math.random()*radians(40)+radians(70)));
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
  private long ltime;
  public Projectile(float x, int vx, int vy, color c) {
    this(x, height, 5, c, new double[]{vx, vy});
  }
  protected Projectile(float x, float y, int r, color c, double[] vel) {
    super(x, y, r, c);
    this.vel = vel;
    this.ltime = System.currentTimeMillis();
  }
  public void update() {
    if (this.loc[1] > height) {particles.remove(this); return;}
    long ctime = System.currentTimeMillis();
    float mult = (ctime-ltime)/1000f;
    ltime = ctime;
    this.vel[1] -= 9.8 * mult;
    super.loc[0] += this.vel[0] * mult;
    super.loc[1] -= this.vel[1] * mult;
  }
}
class Firework extends Projectile {
  private float colourVel; // storage
  public Firework(int x, int r, double v, double dir) {
    super(x, height, r, color(Math.round(Math.random()*255), 255, 255), new double[]{v*Math.cos(dir), v*Math.sin(dir)});
    this.colourVel = (float)(Math.random()/4);
  }
  private Firework(float x, float y, int r, color c, double[] vel, float colourVel) {
    super(x, y, r, c, vel);
    this.colourVel = colourVel;
  }
  public void update() {
    if (this.loc[1] > height) {particles.remove(this); return;}
    super.update();
    if (Math.abs(super.vel[1]) < 4) {
      particles.remove(this);
      int v = (int)Math.ceil(15+Math.random()*7);
      for (double dir = radians(10); dir < TWO_PI; dir += radians(20)+radians(20)*Math.random())
        particles.add(super.radius > 10 & dir < radians(180)
          ? new Firework( super.loc[0], super.loc[1], super.radius/2, super.colour, new double[]{v*Math.cos(dir)*1.5+super.vel[0]*0.5, v*Math.sin(dir)*1.5+super.vel[1]*1.2}, this.colourVel)
          : new Firework2(super.loc[0], super.loc[1], super.radius/2, super.colour, new double[]{v*Math.cos(dir)+super.vel[0]*0.7, v*Math.sin(dir)+super.vel[1]}, this.colourVel)
        );
      return;
    }
  }
}
class Firework2 extends Projectile {
  private float colourVel;
  public Firework2(float x, float y, int r, color c, double[] vel, float dc) {
    super(x, y, r, c, vel);
    this.colourVel = dc;
  }
  public void update() {
    if (this.loc[1] > height || alpha(this.colour) <= 0) {particles.remove(this); return;}
    super.update();
    this.colour = color(hue(this.colour)+this.colourVel, saturation(this.colour), brightness(this.colour), alpha(this.colour)-1);
  }
}
