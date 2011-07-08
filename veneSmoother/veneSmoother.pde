import peasy.*;



Parser parser;
ArrayList nodes = new ArrayList(0);
PeasyCam cam;

float minval = 1000000;
float maxval = 0;

int blockNum = 48;


float radius = 150.0;

boolean result = false;

void setup(){
    size(1024,768,P3D);

    parser = new Parser(nodes);


    cam = new PeasyCam(this, 1000);

    float [] rot = {
        -1.0961999, -0.8072881, 0.23353978
    };
    cam.rotateX(rot[0]);
    cam.rotateY(rot[1]);
    cam.rotateZ(rot[2]);
}

void draw(){
    background(0);



    stroke(0);

    for(int i = 0 ; i < nodes.size();i++){
        Node n = (Node)nodes.get(i);
        n.draw();
        n.approx(10);

    }
}

void keyPressed(){
    if(key==' '){
        result = !result;
    }

}

class Parser{

    String path = "";
    ArrayList raw;

    Parser(ArrayList _nodes){
        path = sketchPath+"/blocks/";


        println("-------------------");
        println(path);

        raw = new ArrayList(0);

        int cnt = 0;
        for(int i =0;i<blockNum;i++){
            String [] tmp = loadStrings(path+"b"+nf(i,3)+".2dg");

            for(int ln = 1;ln < tmp.length; ln+=2){
                String coords[] = splitTokens(tmp[ln-1],":");
                String vals[] = splitTokens(tmp[ln],"; ");

                PVector pos = new PVector(parseFloat(coords[0]),parseFloat(coords[1]),parseFloat(coords[2]));
                float val1 = parseFloat(vals[0]);
                float val2 = parseFloat(vals[1]);

                _nodes.add(new Node(cnt,i,pos,val1,val2));
                cnt++;
            }

        }
    }
}


class Node{
    int id;
    int blockId;
    PVector pos;
    float sval,nval,val1,val2;


    Node(int _id,int _blockId,PVector _pos,float _val1,float _val2){
        id = _id;
        blockId = _blockId;
        pos = _pos;
        sval = val1 = _val1;
        nval = 0;
        val2 = _val2;
    }

    void draw(){


        /*    stroke(255,100);
              line(pos.x,pos.y,val1-2+pos.z,pos.x,pos.y,val1+2+pos.z);
              stroke(#ffcc00,100);
              line(pos.x,pos.y,sval-2+pos.z,pos.x,pos.y,sval+2+pos.z);
         */  stroke(#FF0000,100);
        line(pos.x,pos.y,nval-2+pos.z,pos.x,pos.y,nval+2+pos.z);

    }

    void approx(int kolik){


        if(!result){
            nval += ((val1-sval)*40.0-nval)/3000.0;
            for(int i = 0 ;i<kolik;i++){
                int sel = (int)random(0,nodes.size());
                Node other = (Node)nodes.get(sel);


                float d = dist(pos.x,pos.y,other.pos.x,other.pos.y);
                if(d < radius){
                    sval += (other.val1-sval)/3.0;//dist(pos.x,pos.y,other.pos.x,other.pos.y);

                }

            }

        }else{
            int sel = (int)random(0,nodes.size());
            Node other = (Node)nodes.get(sel);


            float d = dist(pos.x,pos.y,other.pos.x,other.pos.y);
            if(d < radius){
                nval += (other.nval-nval)/3.0;//dist(pos.x,pos.y,other.pos.x,other.pos.y);

            }


        }
    }

}
