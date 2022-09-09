import { LightningElement, api } from 'lwc';
import { ShowToastEvent  }      from 'lightning/platformShowToastEvent';
import contact_Object           from '@salesforce/schema/Contact';
import contact_FirstName        from '@salesforce/schema/Contact.FirstName';
import contact_LastName         from '@salesforce/schema/Contact.LastName';
import contact_Mobile           from '@salesforce/schema/Contact.MobilePhone';
import contact_Email            from '@salesforce/schema/Contact.Email';
import contact_Role             from '@salesforce/schema/Contact.Role__c';
import contact_Account          from '@salesforce/schema/Contact.AccountId';

export default class CreateContact extends LightningElement {

    contactObject       = contact_Object;
    //fields          = [contact_FirstName,contact_LastName,contact_Mobile,contact_Email];
    contactFirstName    = contact_FirstName;
    contactLastName     = contact_LastName;
    contactEmail        = contact_Email;
    contactMobile       = contact_Mobile;
    contactAccount      = contact_Account;
    contactRole         = contact_Role;

    @api recordId;


    handleContactCreation(event){
        const toastEvent = new ShowToastEvent({
            title: "Contact created",
            message: "Record Id: " + event.detail.id,
            variant: "success" 
        });
        this.dispatchEvent(toastEvent);
        
        //reset form
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                if(field.fieldName != 'AccountId'){
                    field.reset();
                }
            });
        }
    }

}