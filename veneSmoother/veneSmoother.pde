//import processing.opengl.*;
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

boolean repair = false;

boolean smoothing = false;

boolean adjusting = false;


String inputFolder = "blocks";
String outputFolder = "repair";


void setup(){
    size(1024,768,P3D);


    noiseSeed(19);

    centerX = 0;
    centerY = 0;

    parser = new Parser(nodes);

    selErrors();

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
        //    if(!n.zmetek)
        n.draw();

        if(repair && n.zmetek){
            n.repair(100);
        }

        if(smoothing){
            n.noisify();

        }

        if(adjusting){
            n.adjust();
        }
    }

    popMatrix();
}

void keyPressed(){
    if(key==' '){
        result = !result;
    }else if(key=='r'){
        repair = !repair;
    }else if(key =='s'){
        saveRepaired();

    }else if(key == 't'){
        smoothing = !smoothing;
    }else if(key == 'y'){
        adjusting = !adjusting;
    }

}

void saveRepaired(){
    


    for(int b = 0;b<blockNum;b++){


    ArrayList block = new ArrayList(0);


    for(int i = 0 ;i<nodes.size();i++){
        Node n = (Node)nodes.get(i);
        if(n.blockId==b){
            block.add(n);
        }

    }


    ArrayList raw = new ArrayList(0);
    for(int i = 0;i<block.size();i++){
        Node n = (Node)block.get(i);
        
        raw.add(""+n.pos.x+":"+n.pos.y+":"+n.pos.z);
        raw.add(" "+n.val1+";"+n.val2+";");

    }


    String[] lines = new String[raw.size()];
    for(int i = 0;i<raw.size();i++){
            lines[i] = (String)raw.get(i);
    }

    saveStrings(outputFolder+"/b"+nf(b,3)+".2dg",lines);
    
    }
}

class Parser{

    String path = "";
    ArrayList raw;

    Parser(ArrayList _nodes){
        path = sketchPath+"/"+inputFolder+"/";


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

    boolean zmetek = false;
    boolean sel = false;

    Node(int _id,int _blockId,PVector _pos,float _val1,float _val2){
        id = _id;
        blockId = _blockId;
        pos = _pos;
        sval = val1 = _val1;//+1600*(noise(_pos.x/3000.0,_pos.y/3000.0)*noise(_pos.x/229.0,_pos.y/229.0));// _val1;
        nval = 0;
        val2 = _val2;
    }

    void draw(){


        if( dist(screenX(pos.x,pos.y,val1),screenY(pos.x,pos.y,val1),mouseX,mouseY)< 25 ){
            sel = true;

            if(keyPressed&&key=='n'){
                zmetek = false;
            }else if(keyPressed&&key=='m'){
                zmetek = true;
            }


        }else{
            sel = false;
        }

        if(sel){

            stroke(#FFCC00);

        }else{
            if(!zmetek){
                stroke(255,100);
            }else{
                stroke(#FF0000,100);

            }
        }

        line(pos.x,pos.y,val1-2+pos.z,pos.x,pos.y,val1+2+pos.z);
       

        if(smoothing || adjusting){
           stroke(#ffcc00,100);
           line(pos.x,pos.y,sval-2+pos.z,pos.x,pos.y,sval+2+pos.z);
           stroke(#FF0000,100);
           line(pos.x,pos.y,nval-2+pos.z,pos.x,pos.y,nval+2+pos.z);
        }
    }


void repair(int _kolik){
            for(int i = 0 ;i<_kolik;i++){
                int sel = (int)random(0,nodes.size());
                Node other = (Node)nodes.get(sel);


                float d = dist(pos.x,pos.y,other.pos.x,other.pos.y);
                if(d < radius){
                    val1 += (other.val1-val1)/(d/10.0+1.0);//dist(pos.x,pos.y,other.pos.x,other.pos.y);

                }

            }

}

void noisify(){
    nval += (lerp(noise(pos.x/10000+pos.x/2000.0+pos.x/730.23,pos.y/10000+pos.y/2000.0+pos.y/730.23)*1600,val1,map(pos.x,0,centerX*2,0,1))-nval)/100.0;

}

void adjust(){
    val1 += (nval-val1)/100.0;

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




ArrayList selErrors(){
    ArrayList tmp = new ArrayList(0);


    for(int i = 0 ;i<nodes.size();i++){
        Node n = (Node)nodes.get(i);

        for(int ii = 0;ii<nodes.size();ii++){
            Node other = (Node)nodes.get(ii);


            if(i!=ii){
                if(dist(n.pos.x,n.pos.y,other.pos.x,other.pos.y)<200){



                    if((n.val1-200>other.val1)){
                        tmp.add(n);
                        n.zmetek = true;
                    }

                }
            }
        }
    }

    return tmp;

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


