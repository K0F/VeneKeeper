import processing.opengl.*;
import peasy.*;
import processing.pdf.*;

//////////////////// global scope


float smoothing = 50.0;
float radius = 100.0;

ArrayList blocks;
int globId = 0;
int numBlocks = 48;

float scale = 10.0;

float W,H;

float mini = 10000000;
float maxi = 0;

float cut = 50.0;

boolean capturing = false;
boolean plot = false;

PeasyCam cam;
DataDump dump;

//////////////////// setup

void setup() {
  size(1024,768,OPENGL);


  textFont(createFont("Verdana",12));

  W = 0;
  H = 0;

  blocks = new ArrayList(0);
  for(int i = 0 ; i<numBlocks;i++) {
    blocks.add(new Block(i));
  }




  cam = new PeasyCam(this, 1000);

  float [] rot = {
    -1.0961999, -0.8072881, 0.23353978
  };
  //cam.rotateX(radians(45));
  cam.rotateX(rot[0]);
  cam.rotateY(rot[1]);
  cam.rotateZ(rot[2]);


  getMiniMaxi();
  analyze();

  for(int i = 0 ; i<numBlocks;i++) {
    Block b= (Block)blocks.get(i);
    b.correct();
    //b.remap();
  }

  getMiniMaxi();

  for(int i = 0 ; i<numBlocks;i++) {
    Block b= (Block)blocks.get(i);
    //        b.correct();
    b.remap();
  }

  dump = new DataDump("N/A");
}

//////////////////// draw

void draw() {
  
  cam.rotateY(0.01);

  if(capturing) {
    beginRaw(PDF,"map.pdf");
    plot = true;
  }

  background(255);

  stroke(255,50);

  pushMatrix();

  translate(-W/2.0,-H/2.0);

  for(int i = 0; i< blocks.size();i++) {
    Block b =  (Block)blocks.get(i);

    fill(127);
    text(b.id,b.cx,b.cy);

    float nnum = 0;
    float prum = 0;

    for(int ii = 0 ; ii < b.nodes.size();ii++) {
      Node n = (Node)b.nodes.get(ii);

      pushMatrix();
      translate(n.x,n.y,n.sum);
      /*
               if(dist(screenX(0,0,0),screenY(0,0,0),mouseX,mouseY)<20){
       Node rnd = (Node)b.nodes.get((int)random(b.nodes.size()));
       prum += (rnd.sum-prum)/300.0;
       
       stroke(255,0,0);
       
       }else{
       */
      stroke(0,n.sum);

      line(-1,-1,0,1,1,0);
      line(1,-1,0,-1,1,0);
      popMatrix();
    }
  }

  popMatrix();

  if(capturing && plot) {
    endRaw();
    plot = false;
    capturing = false;
    save("map.png");
  }
}

//////////////////// 

