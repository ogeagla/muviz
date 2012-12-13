strs = []

new File("time.dat").withReader { reader ->

    str = reader.readLine()
  while (str != null) {
    //if (++count > MAXSIZE) throw new RuntimeException('File too large!')
    
    str = new Date().parse("MM/dd/yyyy HH:mm", str).time
    println str
    strs.add(str)
    
    
    str = reader.readLine()
  }
  println strs.size
  
 
}

 new File("time_milli.dat").withWriter { out ->
    strs.each() { it ->
        out.writeLine("${it}")
    }
}

strs = []

new File("created.dat").withReader { reader ->

    str = reader.readLine()
  while (str != null) {
    //if (++count > MAXSIZE) throw new RuntimeException('File too large!')
    
    str = new Date().parse("MM/dd/yyyy HH:mm", str).time
    println str
    strs.add(str)
    
    
    str = reader.readLine()
  }
  println strs.size
  
 
}

 new File("created_milli.dat").withWriter { out ->
    strs.each() { it ->
        out.writeLine("${it}")
    }
}

