
//////////////////// Block class

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

