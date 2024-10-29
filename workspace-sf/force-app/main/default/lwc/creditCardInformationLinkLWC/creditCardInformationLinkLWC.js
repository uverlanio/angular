// RVI-223 inicio  
import { LightningElement, wire, api, track } from "lwc";
import getProfileName from '@salesforce/apex/CreditCardInformationController.linkValidations';
import resendLinkCard from '@salesforce/apex/CreditCardInformationController.resendLinkCard';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import PRODUTO_EMPRESA_CODIGOEMPRESA_FIELD from '@salesforce/schema/Quote.Produto__r.Empresa__r.CodigoEmpresa__c';
import PROPOSTA_FIELD from '@salesforce/schema/Quote.Name';
import NOME_FIELD from '@salesforce/schema/Quote.Account.Name';
import EMAIL_FIELD from '@salesforce/schema/Quote.Account.PersonEmail';
import CORRETOR_FIELD from '@salesforce/schema/Quote.CodigoCorretor__r.Name';
import QTDE_PARCELAS from '@salesforce/schema/Quote.QuantidadeParcelas__c'; 
import PREMIO_TOTAL from '@salesforce/schema/Quote.PremioTotal__c';
import NUMERO_PROPOSTA from '@salesforce/schema/Quote.Name'; //RVI-294

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const FIELDS = ['Quote.Status',
               PRODUTO_EMPRESA_CODIGOEMPRESA_FIELD, 
               PROPOSTA_FIELD, 
               NOME_FIELD, 
               EMAIL_FIELD,
               CORRETOR_FIELD,
               QTDE_PARCELAS,
               PREMIO_TOTAL,
               NUMERO_PROPOSTA
            ];


export default class CreditCardInformationLinkLWC extends LightningElement {
    @api recordId;
    @track showLink = false;
    @track loading = false;
    quote;
    status;
    codigoEmpresa;    
    currentProfileName;
    nome;
    proposta;
    email;
    corretor; 
    qtdeParcelas;
    premioTotal;
    numeroProposta;
    
    @wire(getProfileName)
    wiredProfileName({ error, data }) {
        console.log('Error => ', error);
        console.log('Data => ', data);
        if (error) {
            let message = 'Unknown error';
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading profile name',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            this.currentProfileName = data;
        }
    }
    
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
       
        if (error) {
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error loading quote',
                    message,
                    variant: 'error',
                }),
            );
        } else if (data) {
            this.quote = data;
            this.status = this.quote.fields.Status.value;
            this.codigoEmpresa = getFieldValue(data, PRODUTO_EMPRESA_CODIGOEMPRESA_FIELD );

            this.nome = getFieldValue(data, NOME_FIELD);
            this.proposta = getFieldValue(data, PROPOSTA_FIELD);
            this.email = getFieldValue(data, EMAIL_FIELD);
            this.corretor = getFieldValue(data, CORRETOR_FIELD);

            this.qtdeParcelas = getFieldValue(data, QTDE_PARCELAS);
            this.premioTotal = getFieldValue(data, PREMIO_TOTAL);
            this.numeroProposta = getFieldValue(data, NUMERO_PROPOSTA);

            


            if(this.currentProfileName == 'Emissão' || this.currentProfileName == 'Atendimento' || this.currentProfileName == 'Administrador Porto' || this.currentProfileName == 'Administrador do sistema' || this.currentProfileName == 'Atendimento' || this.currentProfileName == 'Administrador Porto' || this.currentProfileName == 'System Administrator'){
                if(this.status == 'Em criação' || this.status == 'Aguardando análise' || this.status == 'Em análise' || this.status == 'Em aprovação' || this.status == 'Disponível para contratação' && this.codigoEmpresa == '1'){               
                    this.showLink = true;
                }else{
                    this.showLink = false; 
                    
                }
            }else{
               
                this.showLink = false; 
                //this.noProfileAccessMgs();
            }
        }
    }

    noProfileAccessMgs(){
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Perfil sem permissão para acessar o link.',
                variant: 'warning',
            }),
        );
    }

    // ****************** RVI 223 - INICIO ********************** //
    resendLink(){

     
        const dadosProposta = {qtdeParcelas: this?.qtdeParcelas ?? 1, premioTotal: this?.premioTotal ?? 0.00, numeroProposta: this?.numeroProposta ?? ''};
        const dadosEmail = {nome: this.nome, proposta: this.proposta, email: this.email, corretor: this.corretor, link:''}

        if (dadosEmail.email == null || dadosEmail.email === 'undefined' || dadosEmail.email === '') {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'A Proposta não possui um e-mail!',
                    variant: 'warning',
                }),
            );
            return;
        }

        resendLinkCard({dadosEmailRequest: JSON.stringify(dadosEmail), dadosPropostaRequest:JSON.stringify(dadosProposta)}).then((result) => {
           

            const resp = JSON.parse(result);
            const msg = resp.message;
            if(resp.success){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: msg,
                        variant: 'success',
                    }),
                );
                 return;
             }
             this.dispatchEvent(
                new ShowToastEvent({
                    title: msg,
                    variant: 'error',
                }),
            );
        }).catch((error) => {
           console.error('Erro reenvio link', error.message);
        });

    }
      // ********************** RVI 223 - FIM ************************ //
    
    
}
// RVI-223 fim