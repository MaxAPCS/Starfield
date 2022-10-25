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
  long held = Math.max(System.currentTimeMillis() - heldSince, 1000);
  heldSince = -1;
  particles.add(new Firework(width/2, (int)Math.ceil(held/500f)));
}
abstract class Particle {
  protected float[] loc;
  private final int radius;
  private color colour;
  protected Particle(int x, int y, int r, color c) {
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
  public Projectile(int x, int vx, int vy, color c) {
    this(x, 5, c, new double[]{vx, vy});
  }
  protected Projectile(int x, int r, color c, double[] vel) {
    super(x, height, r, c);
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
  public Firework(int x, int r) {
    super(x, r, color(Math.round(Math.random()*255), 255, 255), new double[]{(Math.random()*20-10), Math.random()*100+50});
  }
}
