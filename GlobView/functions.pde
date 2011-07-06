
//////////////////// functions

void capture() {
  capturing = true;
}

//////////////////// keys

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
    //smoothAll(smoothing,radius);
  }

  cut = constrain(cut,0,160);
}

//////////////////// getMiniMaxi

void getMiniMaxi(ArrayList _blocks) {
  mini = 1000000;
  maxi = 0;

  for(int i = 0; i< _blocks.size();i++) {
    Block b =  (Block)_blocks.get(i);

    for(int ii = 0 ; ii < b.nodes.size();ii++) {
      Node n = (Node)b.nodes.get(ii);
      mini = min(n.sum,mini);
      maxi = max(n.sum,maxi);
    }
  }
  println("got values: minimal: "+mini+" maximal: "+maxi);
}

//////////////////// analyze

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

//////////////////// smoothAll

void smoothAll(ArrayList _blocks,float kolik,float perimeter) {

  ArrayList temp = new ArrayList(0);

  for(int Y = 0;Y<6;Y+=1) {
    for(int i = 0;i<_blocks.size();i+=6) {
      Block b = (Block)_blocks.get(i+Y);

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
          cur.sum += (tmp.sum2-cur.sum)/(dis*kolik);
        }
      }
    }
  }

  getMiniMaxi(_blocks);

  for(int i = 0;i<_blocks.size();i++) {
    Block b = (Block)_blocks.get(i);
    b.remap();
  }
}

