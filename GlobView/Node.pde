
// Node class

class Node {
  int id;
  float x,y,z;
  float origSum;
  boolean zmetek = false;

  float sum,sum2;


  Node(int _id,float _x,float _y,float _z,float _sum) {
    id = _id;
    x = _x;
    y = _y;
    z = _z;
    sum2 = origSum = sum = _sum;
  }

}


