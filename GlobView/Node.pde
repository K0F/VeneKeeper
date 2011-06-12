
// Node class

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


