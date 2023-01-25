/**
 * @description       :
 * @author            : Massimo Frangiamore
 * @group             :
 * @last modified on  : 01-25-2023
 * @last modified by  : Massimo Frangiamore
**/
public without sharing class JiraApiPlugin {
    public static JiraNexus__c setting = JiraNexus__c.getOrgDefaults();

    @InvocableMethod(label='Service Desk Chiusura Tempo Account')
    public static void callServiceDeskChiusuraServiceDesk(List<Id> input){
        List<ProjectStatus__c> projectsStatus = [SELECT Id, Name, Opportunity__r.ReferenceNumber__c FROM ProjectStatus__c WHERE Id in :input];
        for(ProjectStatus__c projectStatus: projectsStatus){
            RequestCointainer request = new RequestCointainer(projectStatus);
            callout(json.serialize(request));
        }
    }
    @Future(callout=true)
    public static void callout(String jsonString){
        RequestCointainer request = (RequestCointainer)JSON.deserialize(jsonString, RequestCointainer.class);
        HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setHeader('content-type', 'application/json');
            Blob headerValue = Blob.valueOf(setting.Username__c + ':' + setting.JiraToken__c);
            req.setHeader('Authorization', 'Basic '+EncodingUtil.base64Encode(headerValue));
            req.setEndpoint(setting.Url__c);
            req.setBody(request.getWebReuest());
            Http http = new Http();
            HTTPResponse res;
            Exception er;
            try{
                res = http.send(req);
                 //Executing web service call
                System.debug('STATUS:' + res.getStatus());
                System.debug('STATUS_CODE:' + res.getStatusCode());
            }
            catch(System.CalloutException e){
                //Exception handling goes here..
                er =e;
                system.debug(e);
            }finally{
                Map<String,Object> body = new Map<String,Object>{
                    'request' => request.webRequest
                    ,'response.StatusCode' => res.getStatus()
                    ,'response' => decodesesponsebody(res.getbody())
                    ,'Error' => er
                };
                insert new FeedItem(
                    ParentId = request.projectId,
                    Body = json.serializePretty(body,false)
                );
            }
    }
    public static Object decodesesponsebody(String JsoneString){
        try{
            return json.deserializeUntyped(JsoneString);
        }catch(Exception e){
            return JsoneString;
        }
    }
    public class RequestCointainer{
        private Id projectId;
        private WrapperRequest webRequest;
        public string getWebReuest(){
            return JSON.serializePretty(webRequest);
        }
        public RequestCointainer(ProjectStatus__c projectStatus){
            this.webRequest = new WrapperRequest(projectStatus);
            this.projectId = projectStatus.Id;
        }
    }
    public class WrapperRequest{
        public String serviceDeskId = '3';
        public String requestTypeId = '343';
        public RequestFieldValues requestFieldValues;
        public WrapperRequest(ProjectStatus__c projectStatus){
            this.requestFieldValues = new RequestFieldValues(projectStatus);
        }
    }
    public class RequestFieldValues{
        public String summary;
        public string customfield_12801;
        public RequestFieldValues(ProjectStatus__c projectStatus){
            this.summary = projectStatus.name;
            this.customfield_12801 = projectStatus.Opportunity__r.ReferenceNumber__c;
        }
    }
}
