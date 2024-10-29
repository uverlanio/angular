import { LightningElement, api, wire, track } from 'lwc';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';
import { NavigationMixin } from 'lightning/navigation';

export default class ListaTransferenciaCorretagem extends NavigationMixin(LightningElement) {

    @api recordId;
    @track relatedRecords = [];
    @track showRecords = false;
    @track listSize = 0;

    @wire(getRelatedListRecords, {
        parentRecordId: '$recordId',
        relatedListId: 'DadosContratoTransferido__r',
        fields: [
            'TransferenciaCorretagem__c.Id',
            'TransferenciaCorretagem__c.SusepAtual__r.Id',
            'TransferenciaCorretagem__c.Name',
            'TransferenciaCorretagem__c.ValidoAte__c',
            'TransferenciaCorretagem__c.TransferirCarteira__c'
        ]
    }) wiredGetRelatedRecords({error, data}){       
		if(error){
			console.warn('ERROR',error);
		}else if(data){
            if(data.count > 0 && data.records) {

                this.relatedRecords = data.records.map(record => ({ 
                    id: record.fields?.Id?.value, 
                    name: record.fields?.Name?.value,
                    susep: record.fields?.SusepAtual__r?.displayValue,
                    susepId: record.fields?.SusepAtual__r?.value?.id,
                    carteira: record.fields?.TransferirCarteira__c?.value,
                    valido: record.fields?.ValidoAte__c?.displayValue,
                    link: "/" + record.fields?.Id?.value,
                    susepLink: "/" + record.fields?.SusepAtual__r?.value?.id
                }));
                this.listSize = this.relatedRecords?.length;
                this.showRecords = true;
            } else {
                this.showRecords = false;
            }
            console.warn(JSON.parse(JSON.stringify(this.relatedRecords)));
		}
	};    
}