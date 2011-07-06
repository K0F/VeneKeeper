
//////////////// DataDump class 

class DataDump {
  String filename;

  DataDump(String _filename) {
    filename = _filename;
  }


  void dumpBlocks(boolean time) {

    getMiniMaxi(blocks);

    String D = nf(day(),2)+"";
    String M = nf(month(),2)+"";
    String H = nf(hour(),2)+"";
    String MN = nf(minute(),2)+"";

    //ArrayList blocks = new ArrayList(0);

    //compute all nodes count
    int blockCnt = 0;
    for(int q = 0 ; q < blocks.size(); q++) {
      Block tmpblock = (Block)blocks.get(q);
      for(int i = 0;i<tmpblock.nodes.size();i++) {
        Node tmp = (Node)tmpblock.nodes.get(i);
        blockCnt = max(tmp.id+1,blockCnt);
      }
    }

    println("timestamp: "+D+"/"+M+" "+H+":"+MN+" ukladam bloky... pocet: "+blockCnt);

    /*
		   ArrayList temp = new ArrayList(0);
     		   for(int q = 0;q<blockCnt;q++){
     
     		   ArrayList oneBlockNodes = new ArrayList(0);
     		   boolean newBlock = false;
     
     		   for(int bl = 0;bl < blocks.size();bl++){	
     		   Block block = (Block)blocks.get(bl);
     		   for(int i = 0; i< block.nodes.size();i++){
     		   Node tmp = (Node)(block.nodes.get(i));
     		//if(i==0)
     		//println(q);
     
     		if(q==tmp.blockNo){
     		if(!newBlock){
     		newBlock = true;
     		temp.add(new Block(q));
     
     		}
     		oneBlockNodes.add(tmp);
     		}
     
     		}
     		}
     
     		//println("blok no.:"+q+" ma "+oneBlockNodes.size()+" nodu");
     		Block b = (Block)blocks.get(q);
     		b.fillNodes(oneBlockNodes);
     		}*/


    for(int i = 0;i<blocks.size();i++) {
      Block b = (Block)blocks.get(i);
      ArrayList raw = new ArrayList(0);
      for(int n =0;n<b.nodes.size();n++) {
        Node tmpnode = (Node)b.nodes.get(n);

        //coordinte hack
        raw.add(tmpnode.x*scale+":"+tmpnode.y*scale+":"+tmpnode.z*scale);

        raw.add(" "+map(tmpnode.sum,mini,maxi,0,1600)+";"+tmpnode.origSum+";");
      }

      String [] arr = new String[raw.size()]; 
      for(int ln = 0;ln<arr.length;ln++) {
        String line = (String)raw.get(ln);
        arr[ln] = line;
      }
      if(time) {
        saveStrings("repair/"+D+"_"+M+"-"+H+"_"+MN+"/b"+nf(i,3)+".2dg",arr);
        saveStrings("repair/b"+nf(i,3)+".2dg",arr);
      }
      else {
        saveStrings("repair/b"+nf(i,3)+".2dg",arr);
      }
    }
  }
}

