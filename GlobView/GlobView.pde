import processing.opengl.*;
import peasy.*;
import processing.pdf.*;

//////////////////// global scope

boolean modify = false;

float smoothing = 2.0;
float radius = 35.0;

ArrayList blocks;
int globId = 0;
int numBlocks = 48;

ArrayList smoothed;
ArrayList corrected;

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
  size(1024,768,P3D);


  textFont(createFont("Verdana",12));

  W = 0;
  H = 0;

  blocks = new ArrayList(0);
  smoothed = new ArrayList(0);
  corrected = new ArrayList(0);
  for(int i = 0 ; i<numBlocks;i++) {
    blocks.add(new Block(i));
    smoothed.add(new Block(i));
    corrected.add(new Block(i));
  }




  cam = new PeasyCam(this, 1000);

  float [] rot = {
    -1.0961999, -0.8072881, 0.23353978
  };
  //cam.rotateX(radians(45));
  cam.rotateX(rot[0]);
  cam.rotateY(rot[1]);
  cam.rotateZ(rot[2]);


  getMiniMaxi(blocks);
  for(int i = 0 ; i<numBlocks;i++) {
    Block b= (Block)blocks.get(i);    
    b.remap();
    b = (Block)smoothed.get(i);    
    b.remap();
  }
  
  if(modify){
  analyze();

  for(int i = 0 ; i<numBlocks;i++) {
    Block b= (Block)blocks.get(i);
    b.correct();
    //b.remap();
  }

  getMiniMaxi(blocks);

  for(int i = 0 ; i<numBlocks;i++) {
    Block b= (Block)blocks.get(i);
    //        b.correct();
    b.remap();
  }

    }
    
    smoothAll(smoothed,smoothing,radius);


  for(int i =0 ;i<numBlocks;i++){
   Block b3 = (Block)corrected.get(i);
   Block b2 = (Block)smoothed.get(i);
   Block b1 = (Block)blocks.get(i);
      
   
   for(int q = 0 ;q<b1.nodes.size();q++){
    
    Node n3 = (Node)b3.nodes.get(q);
    Node n2 = (Node)b2.nodes.get(q);
    Node n1 = (Node)b1.nodes.get(q);
    
    n3.sum = (n1.sum - n2.sum);
   } 
    
  }
  
  getMiniMaxi(corrected);
  
  for(int i = 0 ; i<numBlocks;i++) {
    Block b= (Block)corrected.get(i);
    //        b.correct();
    b.remap();
  }
  
  getMiniMaxi(corrected);
  smoothAll(corrected,smoothing,radius);
  
  for(int i = 0 ; i<numBlocks;i++) {
    Block b= (Block)corrected.get(i);
    //        b.correct();
    b.remap();
  }

  dump = new DataDump("N/A");
}

//////////////////// draw

void draw() {
  
<<<<<<< HEAD
  //cam.rotateY(0.01);
=======
//  cam.rotateY(0.01);
>>>>>>> 05b44b76d1fface8701553f133c9d431dd9553c5

  if(capturing) {
    beginRaw(PDF,"map.pdf");
    plot = true;
  }

  background(255);

  stroke(255,50);

  drawBlocks(blocks,#ff1100);
  drawBlocks(smoothed,#00ff00);
  drawBlocks(corrected,#000000);

  if(capturing && plot) {
    endRaw();
    plot = false;
    capturing = false;
    save("map.png");
  }
}

//////////////////// 



void drawBlocks(ArrayList _blocks,color _c){
  pushMatrix();

  translate(-W/2.0,-H/2.0);

  for(int i = 0; i< _blocks.size();i++) {
    Block b =  (Block)_blocks.get(i);

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
      stroke(_c,n.sum);

      line(-1,-1,0,1,1,0);
      line(1,-1,0,-1,1,0);
      popMatrix();
    }
  }

  popMatrix();
  
}
