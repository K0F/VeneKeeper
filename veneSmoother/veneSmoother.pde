import peasy.*;



Parser parser;
ArrayList nodes = new ArrayList(0);
PeasyCam cam;

float minval = 1000000;
float maxval = 0;

float centerX,centerY;

int blockNum = 48;


float radius = 340.0;

boolean result = false;

void setup(){
    size(1024,768,P3D);

    centerX = 0;
    centerY = 0;

    parser = new Parser(nodes);


    cam = new PeasyCam(this, 10000);

    float [] rot = {
        -1.0961999, -0.8072881, 0.23353978
    };
    cam.rotateX(rot[0]);
    cam.rotateY(rot[1]);
    cam.rotateZ(rot[2]);
}

void draw(){
    background(0);


    pushMatrix();

    translate(-centerX,-centerY,0);

    stroke(0);

    getMinMax();

    for(int i = 0 ; i < nodes.size();i++){
        Node n = (Node)nodes.get(i);
        n.draw();
        n.approx(100);

    }

    popMatrix();
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


                centerX+= parseFloat(coords[0]);
                centerY+= parseFloat(coords[1]);

                PVector pos = new PVector(parseFloat(coords[0]),parseFloat(coords[1]),parseFloat(coords[2]));
                float val1 = parseFloat(vals[0]);
                float val2 = parseFloat(vals[1]);

                _nodes.add(new Node(cnt,i,pos,val1,val2));
                cnt++;
            }

        }

        centerX /= (cnt+0.0);
        centerY /= (cnt+0.0);
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
        sval = val1 = _val1;//+1600*(noise(_pos.x/3000.0,_pos.y/3000.0)*noise(_pos.x/229.0,_pos.y/229.0));// _val1;
        nval = 0;
        val2 = _val2;
    }

    void draw(){


        stroke(255,100);
        line(pos.x,pos.y,val1-2+pos.z,pos.x,pos.y,val1+2+pos.z);
        stroke(#ffcc00,100);
        line(pos.x,pos.y,sval-2+pos.z,pos.x,pos.y,sval+2+pos.z);
        stroke(#FF0000,100);
        line(pos.x,pos.y,nval-2+pos.z,pos.x,pos.y,nval+2+pos.z);

    }


    void approx(int kolik){



        if(!result){
            nval += ((val1-sval)*120.0-nval)/3000.0;
            for(int i = 0 ;i<kolik;i++){
                int sel = (int)random(0,nodes.size());
                Node other = (Node)nodes.get(sel);


                float d = dist(pos.x,pos.y,other.pos.x,other.pos.y);
                if(d < radius){
                    sval += (other.val1-sval)/(d/10.0+1.0);//dist(pos.x,pos.y,other.pos.x,other.pos.y);

                }

            }

        }else{
            int sel = (int)random(0,nodes.size());
            Node other = (Node)nodes.get(sel);



            float d = dist(pos.x,pos.y,other.pos.x,other.pos.y);
            if(d < radius){
                nval += (lerp(map(other.nval,minval,maxval,0,1600),other.val1,map(pos.x,0,centerX*2,0,1))-nval)/(d/10.0+1.0);//dist(pos.x,pos.y,other.pos.x,other.pos.y);

            }


        }
    }
}
void getMinMax(){

    minval = 100000;
    maxval = -100000;


    for(int i = 0 ;i<nodes.size();i++){

        Node n = (Node)nodes.get(i);

        maxval = max(maxval,n.nval);
        minval = min(minval,n.nval);
    }


}


