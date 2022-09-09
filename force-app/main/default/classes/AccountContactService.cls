@RestResource(urlMapping = '/createaccountcontact/*')
global with sharing class AccountContactService {

    public Blob requestBody {get;set;}
    public static String accountID;
    public static List<String> contactID = new List<String>();

    @HttpPost
    global static AccountContactDataModel.CreateAccountContactResponse create(){
        Savepoint dbSavePoint;
        try{
            RestRequest req     = RestContext.request;
            String reqBody      = req.requestBody.toString();

            System.debug('reqBody>>> ' + reqBody);

            AccountContactDataModel.CreateAccountContactRequest serviceRequest = (AccountContactDataModel.CreateAccountContactRequest) JSON.deserialize(reqBody, AccountContactDataModel.CreateAccountContactRequest.class);

            Account accountObj              = new Account();
            accountObj.Name                 = serviceRequest.Name;
            accountObj.Type                 = serviceRequest.Type;
            accountObj.Phone                = serviceRequest.Phone;
            accountObj.Fax                  = serviceRequest.Fax;
            accountObj.AccountNumber        = serviceRequest.AccountNumber;
            accountObj.Industry             = serviceRequest.Industry;
            accountObj.AnnualRevenue        = serviceRequest.AnnualRevenue;
            accountObj.NumberOfEmployees    = serviceRequest.NumberOfEmployees;
            accountObj.Ownership            = serviceRequest.Ownership;
            accountObj.Description          = serviceRequest.Description;
            accountObj.Rating               = serviceRequest.Rating;

            dbSavePoint = Database.setSavePoint();
            Database.insert(accountObj);
            accountID = accountObj.Id;

            List<Contact> contactObj = new List<Contact>();

            for(AccountContactDataModel.Contacts con : serviceRequest.contacts){
                Contact contactNew          = new Contact();
                contactNew.FirstName        = con.FirstName;
                contactNew.LastName         = con.LastName;
                contactNew.Salutation       = con.Salutation;
                contactNew.Phone            = con.Phone;
                contactNew.MobilePhone      = con.MobilePhone;
                contactNew.Email            = con.Email;
                contactNew.Title            = con.Title;
                contactNew.Department       = con.Department;
                contactNew.Description      = con.Description;
                contactNew.AccountId        = accountID;

                contactObj.add(contactNew);
            }

            Database.insert(contactObj);
            
            for(Contact insertedContact : contactObj){
                contactID.add(insertedContact.Id);
            }

            AccountContactDataModel.CreateAccountContactResponse responseObject = new AccountContactDataModel.CreateAccountContactResponse();
            responseObject.message          = 'Success';
            responseObject.success          = True;
            responseObject.ids.accountId    = accountID;
            responseObject.ids.contactId    = contactID;
            
            return responseObject;

        }catch(Exception e){
            Database.rollback(dbSavePoint);
            AccountContactDataModel.CreateAccountContactResponse responseObject = new AccountContactDataModel.CreateAccountContactResponse();
            responseObject.message          = 'Exception' + e.getMessage();
            responseObject.success          = False;
            responseObject.ids.accountId    = null;
            responseObject.ids.contactId    = null;
            
            return responseObject;
        }
    }

}
