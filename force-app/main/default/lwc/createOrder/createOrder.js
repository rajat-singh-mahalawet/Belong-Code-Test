import { LightningElement,api }         from 'lwc';
import {createRecord}                   from 'lightning/uiRecordApi';
import { ShowToastEvent  }              from 'lightning/platformShowToastEvent';
import order_Object                     from '@salesforce/schema/Order';
import order_StartDate                  from '@salesforce/schema/Order.EffectiveDate';
import order_AccountId                  from '@salesforce/schema/Order.AccountId';

export default class CreateOrder extends LightningElement {

    @api recordId;

    saveOrder(event){
        this.template.querySelector('lightning-record-edit-form').submit(event.detail.fields);
        
    }

    handleOrderCreationSuccess(event){
        const toastEvent = new ShowToastEvent({
            title: "Order created",
            message: "Record Id: " + event.detail.id,
            variant: "success" 
        });
        this.dispatchEvent(toastEvent);

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