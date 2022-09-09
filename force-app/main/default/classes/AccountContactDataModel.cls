global with sharing class AccountContactDataModel {


    public class CreateAccountContactRequest{
        public String Name;	
        public String Type;	
        public String Phone;	
        public String Fax;
        public String AccountNumber;
        public String Industry;	
        public Decimal AnnualRevenue;
        public Integer NumberOfEmployees;
        public String Ownership;	
        public String Description;	
        public String Rating;
        public List<Contacts> contacts;
        
        public CreateAccountContactRequest(){
            Name                = '';	
            Type                = '';	
            Phone               = '';	
            Fax                 = '';
            AccountNumber       = '';
            Industry            = '';	
            AnnualRevenue       = 0;
            NumberOfEmployees   = 0;
            Ownership           = '';	
            Description         = '';	
            Rating              = '';
            contacts            = new List<contacts>();
        }
    }

    public class Contacts {
		public String LastName;	
		public String FirstName;
		public String Salutation;
		public String Phone;
		public String MobilePhone;
		public String Email;
		public String Title;
		public String Department;
		public String Description;

        public Contacts(){
            LastName        = '';	
            FirstName       = '';
            Salutation      = '';
            Phone           = '';
            MobilePhone     = '';
            Email           = '';
            Title           = '';
            Department      = '';
            Description     = '';
        
        }
	}

    global class CreateAccountContactResponse{
        public RecordId ids;
        public String   message;
        public Boolean  success;

        public CreateAccountContactResponse(){
            ids         = new RecordId();
            message     = '';
            success     = True;
        }

    }

    public class RecordId{
        public String       accountId;
        public List<String> contactId;

        public RecordId(){
            accountId   = '';
            contactId   = new List<String>();
        }
    }


}
