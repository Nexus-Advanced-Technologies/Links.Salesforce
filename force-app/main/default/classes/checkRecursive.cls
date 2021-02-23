public class checkRecursive {
    private static boolean run = true;
    private static Integer recursionCounter = 0;
    
    public static boolean runOnce(){
        recursionCounter ++;
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }
    public static void resetRunOnce(){
        run = true;
    }  
    public static Integer getRecursionCounter(){
        return recursionCounter;
    }
    
}