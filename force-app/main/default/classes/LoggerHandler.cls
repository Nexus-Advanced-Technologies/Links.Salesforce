/**
 * @description       : 
 * @author            : ¤ → alessio.marra@nexusat.it
 * @last modified on  : 25/03/2021
 * @last modified by  : ¤ → alessio.marra@nexusat.it
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   25/03/2021   ¤ → alessio.marra@nexusat.it   Initial Version
**/
public class LoggerHandler {

	public static void start(String method, Map<String, Object> args) {
		System.debug('START ' + method);
		for(String arg : args.keySet()){
			Object value = args.get(arg);
			System.debug(arg + ': ' + value);
		}
	}

	public static void end(String method) {
		System.debug('END ' + method);
	}
}
