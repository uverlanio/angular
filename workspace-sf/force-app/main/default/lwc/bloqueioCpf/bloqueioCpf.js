import { LightningElement, wire, api, track } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getListaProdutos from '@salesforce/apex/GerarCPFBloqueado.getListaProdutos';
import PRODUTOS_BLOQUEADOS from "@salesforce/schema/Account.Produtos_Bloqueados__c";
import ID_FIELD from '@salesforce/schema/Account.Id';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';

const fields = [PRODUTOS_BLOQUEADOS];

const anotherAmountStripInvalidChars = value => {
   const returnValue = value.toString().replace(/,/g,';') 
   return returnValue;
}


export default class GerarConsultorBloqueados extends LightningElement {
    @track error;
    @track data1 = [];
    @track fieldsValues = [];
    @api value = "";
    @api result = "";
    @api recordId;
    @track desabilitado = true;
    @track isLoading = false;

    ProdutosBloqueados;


    options = [];
    values = [];
    defaultValues= [];
    connectedCallback() {
         this.options = this.data1;
         this.defaultValues= this.fieldsValues;
        
    }

    @wire(getRecord, { recordId: '$recordId', fields })
    Account;

    @wire(getListaProdutos)
    wiredClass({ data, error }) {
    if (data) {
        let Testdata = JSON.parse(JSON.stringify(data));
        let lstOption = [];
            for (var i = 0;i < Testdata.length;i++) {
                this.isLoading = true;
                lstOption.push({value: Testdata[i].ProductCode, label: Testdata[i].Name
                });
                }
                this.options = lstOption;
                this.showLoadingSpinner = false;
                this.isLoading = false;
                } else if (error) {
                this.error = error;
                this.isLoading = false;
                }
    }

    handleChange(e) {
        this.ProdutosBloqueados = e.target.value;
     
        this.ProdutosBloqueados.toString();
       // const xform = anotherAmountStripInvalidChars(value);
     this.desabilitado = false;
       
        console.log('Os PRODUTOS BLOQUEADOS SAO>>>>>' + this.ProdutosBloqueados);
        return this.ProdutosBloqueados;
      }

      desabilitado(e) {
        this.ProdutosBloqueados = e.target.value; 
        this.desabilitado = (this.ProdutosBloqueados == NULL) ? TRUE : FALSE ;
        return  this.desabilitado;
      }
      

      get currentOptions () {
        this.currentSelectedList =  getFieldValue(this.Account.data, PRODUTOS_BLOQUEADOS) != null ? getFieldValue(this.Account.data, PRODUTOS_BLOQUEADOS).split(';') : null;
        console.log('lista atual >>>>' +  this.currentSelectedList);
        return this.currentSelectedList;
      }

    updateDadosCorretor() {
            const fields = {};
            
            fields[ID_FIELD.fieldApiName] = this.recordId;
            fields[PRODUTOS_BLOQUEADOS.fieldApiName] = this.ProdutosBloqueados != null ?  anotherAmountStripInvalidChars(this.ProdutosBloqueados) : '';
           // console.log('Novo teste >>>>' + anotherAmountStripInvalidChars(this.ProdutosBloqueados));
   
            const recordInput = { fields };
            
            updateRecord(recordInput)
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Successo',
                            message: 'Registro atualizado',
                            variant: 'success'
                        })
                    );
                    // Display fresh data in the form
                    return refreshApex(this.recordId);
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating record',
                            message: error.body.message,
                            variant: 'error'
                        })
                    );
                });
           
    }


}