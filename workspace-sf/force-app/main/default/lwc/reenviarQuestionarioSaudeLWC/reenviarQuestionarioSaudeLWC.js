import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import enviarDPS from '@salesforce/apex/SensediaServices.enviarDPS';
import getQuoteDetails from '@salesforce/apex/QuoteController.getQuoteDetails';

import { CurrentPageReference } from 'lightning/navigation';

export default class ReenviarQuestionarioDeSaudeLWC extends LightningElement {

    wireRecordId; 
    @track showModal = false;
    linkUrl = 'https://na2.docusign.net/Member/PowerFormSigning.aspx?PowerFormId=a39244fe-2c4e-42b9-bcfb-ba363c5db7d0&env=na2&acct=d6433a73-0fbb-49cd-85f1-7b8a6413a551&v=2';

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.wireRecordId = currentPageReference.state.recordId;
        }
    }

    @api set recordId(value) {
        this.currectRecordId = value;
    }

    get recordId() {
        return this.currectRecordId;
    }

    @api invoke(){
        this.handleClick();
    }

    handleClick() {

        getQuoteDetails({ quoteId: this.currectRecordId})
            .then(result => {
                const { status, linkExpirado, dataEmissao, idProponente } = result; //FNPVVEP-99-FIX01 - INICIO/FIM
                if (status !== 'Em análise' || linkExpirado || this.isLinkExpirado(dataEmissao)) {
                    this.showModal = true;
                } else {
                    enviarDPS({ idProponente: idProponente, linguagem: 'por' })//FNPVVEP-99-FIX01 - INICIO/FIM
                        .then(result => {
                            this.showToast('Sucesso', 'Link enviado com sucesso!', 'success');
                        })
                        .catch(error => {
                            this.showToast('Erro', 'Erro ao tentar reenviar o link, favor tentar novamente mais tarde.', 'error');
                            console.error('Erro ao enviar o link: ', error);
                        });
                }
            })
            .catch(error => {
                console.error('Erro ao verificar detalhes da proposta: ', error);
            });
    }

    handleModalClose() {
        this.showModal = false;
    }

    isLinkExpirado(dataEmissao) {
        const expirationLimit = 96 * 60 * 60 * 1000;
        const dataEmissaoMs = new Date(dataEmissao).getTime();
        return (Date.now() - dataEmissaoMs) > expirationLimit;
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}