import processing.opengl.*;
import peasy.*;
import processing.pdf.*;


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

void capture() {
  capturing = true;
}

void keyPressed() {
  if(keyCode == UP) {
    cut+=2;
  }
  else if(keyCode == DOWN) {
    cut-=2;
  }
  else if(key == ' ') {
    capture();
  }
  else if(key == 'w') {
    dump.dumpBlocks(false);
  }
  else if(keyCode== DELETE) {
    smoothAll(0.3,20.0);
  }

  cut = constrain(cut,0,160);
}


void getMiniMaxi() {
  mini = 1000000;
  maxi = 0;

  for(int i = 0; i< blocks.size();i++) {
    Block b =  (Block)blocks.get(i);

    for(int ii = 0 ; ii < b.nodes.size();ii++) {
      Node n = (Node)b.nodes.get(ii);
      mini = min(n.sum,mini);
      maxi = max(n.sum,maxi);
    }
  }

  println("got values: minimal: "+mini+" maximal: "+maxi);
}


void analyze() {
  for(int i = 0; i< blocks.size();i++) {
    Block b =  (Block)blocks.get(i);

    for(int ii = 0 ; ii < b.nodes.size();ii++) {
      Node n = (Node)b.nodes.get(ii);




      for(int q= 0 ; q<b.nodes.size();q++) {
        Node n2 = (Node)b.nodes.get(q);
        if(dist(n.x,n.y,n2.x,n2.y)<15.0) {
          if(n.sum-n2.sum>2000.0) {
            stroke(#FF0000);
            n.zmetek = true;
          }
        }
      }
    }
  }
}

void draw() {

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

  //float[] rot = cam.getRotations();
  //println(rot[0]+" "+rot[1]+" "+rot[2]);
}



class Block {
  int id;

  float cx,cy;

  float hladina = 0;

  ArrayList nodes;

  Block(int _id) {
    id = _id;
    nodes = new ArrayList(0);

    loadVals();
  }

  void loadVals() {
    String raw[] = loadStrings(sketchPath+"/blocks/b"+nf(id,3)+".2dg");

    cx = 0;
    cy = 0;


    float num = 0;
    for(int i = 1 ; i < raw.length;i+=2) {
      String coor[] = splitTokens(raw[i-1],":,; ");
      String vals[] = splitTokens(raw[i]," ;:,"); 
      float X = parseFloat(coor[0])/scale;
      float Y = parseFloat(coor[1])/scale;
      float Z = parseFloat(coor[2])/scale;
      float V = parseFloat(vals[0])/scale;
      float SUM = parseFloat(vals[1]);

      nodes.add(new Node(globId,X,Y,Z,V,SUM));

      //mini = min(mini,SUM);
      //maxi = max(maxi,SUM);


      //if(i%101==0)
      //  println(SUM);

      hladina += SUM;

      cx += X;
      cy += Y;
      num += 1.0;

      W = max(W,X);
      H = max(H,Y);

      globId ++;
    }

    hladina /= num;

    cx /= num;
    cy /= num;
  }

  void remap() {
    for(int i = 0 ;i<nodes.size();i++) {
      Node n = (Node)nodes.get(i);
      n.sum = map(n.sum,mini,maxi,0,160);
    }
  }

  void correct() {
    for(int i =0 ;i<nodes.size();i++) {
      Node n = (Node)nodes.get(i);
      if(n.zmetek) {
        n.sum = lerp(n.sum,hladina,0.95);
      }
    }
  }
}

class Node {
  int id;
  float x,y,z;
  float val;
  boolean zmetek = false;

  float sum;


  Node(int _id,float _x,float _y,float _z,float _val,float _sum) {
    id = _id;
    x = _x;
    y = _y;
    z = _z;
    val = _val;
    sum = _sum;
  }

  void setVal(float _val) {
    val = _val;
  }
}

void smoothAll(float kolik,float perimeter) {

  ArrayList temp = new ArrayList(0);

  for(int Y = 0;Y<6;Y+=1) {
    for(int i = 0;i<blocks.size();i+=6) {
      Block b = (Block)blocks.get(i+Y);

      for(int ii = 0 ;ii<b.nodes.size();ii++) {
        Node n = (Node)b.nodes.get(ii);
        temp.add(n);
      }
    }
  }



  for(int i = 0;i<temp.size();i++) {

    Node cur = (Node)temp.get(i);


    for(int q = 0;q<temp.size();q++) {

      if(i!=q) {

        Node tmp = (Node)temp.get(q);
        float dis = dist(cur.x,cur.y,tmp.x,tmp.y);

        if(dis < perimeter) {
          cur.sum += (tmp.sum-cur.sum)/(dis*kolik);
        }
      }
    }
  }
}

