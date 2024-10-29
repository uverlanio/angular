import { LightningElement, wire, api, track } from "lwc";
import getLinkPortoPag from '@salesforce/apex/CadastroCartaoController.getLinkPortoPag';
import rgstNewCard from '@salesforce/apex/CadastroCartaoController.rgstNewCard';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import PROPOSTA_FIELD from '@salesforce/schema/Quote.Name';
import NOME_FIELD from '@salesforce/schema/Quote.Account.Name';
import NUMERO_PROPOSTA from '@salesforce/schema/Quote.Name';
import NUMERO_ORCAMENTO from '@salesforce/schema/Quote.Opportunity.Numero__c'; 
import COD_RAMO from '@salesforce/schema/Quote.Opportunity.RamoOrcamento__c'; 
import ROTULO from '@salesforce/schema/Quote.Produto__r.Name'; 
import ID_PROPOSTA from '@salesforce/schema/Quote.Id';
import getDadosProposta from '@salesforce/apex/CadastroCartaoController.getDadosProposta';


import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const FIELDS = ['Quote.Status',
               PROPOSTA_FIELD, 
               NOME_FIELD, 
               NUMERO_PROPOSTA,
               NUMERO_ORCAMENTO,
               COD_RAMO,
               ROTULO,
               ID_PROPOSTA
            ];


export default class cadastroCartaoLWC extends LightningElement {
    @api recordId;
    @track showLink = false;
    @track loading = false;
    @track iframeSrc;
    @track mensagem;
    @api codRamo;
    @api rotulo;
    @api numeroOrcamento;
    @api idCartao
    @api bandeira 
    quote;
    status;
    nome;
    proposta;
    numeroProposta;
    @api idProposta;

    
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
            this.nome = getFieldValue(data, NOME_FIELD);
            this.proposta = getFieldValue(data, PROPOSTA_FIELD);
            this.numeroProposta = getFieldValue(data, NUMERO_PROPOSTA);
            this.numeroOrcamento = getFieldValue(data, NUMERO_ORCAMENTO);
            this.codRamo = getFieldValue(data, COD_RAMO);
            this.rotulo = getFieldValue(data, ROTULO); 
            this.idProposta = getFieldValue(data, ID_PROPOSTA);
            this.checkFormaPagamento();
            this.resendLink();
        }
    }


    checkFormaPagamento() {
        console.log('>>> checkFormaPagamento <<<');
        getDadosProposta({ idProposta: this.idProposta })
            .then(result => {
                const resp = JSON.parse(result);
                console.log('result Show>>', result);
                console.log('resp.formaPagamento>>', resp.formaPagamento);
                console.log('resp.formaPagamento>>', resp.produto);
                if ((resp.formaPagamento == '70' && resp.produto == 'APTLMKT') 
                    || (resp.produto == 'VI-PESSOAS' && (resp.formaPagamento == '98' || resp.formaPagamento == '70'
                        || resp.produto == '62' || resp.produto == '97'))) {    // ANNVI-48 INICIO/FIM
                    this.showLink = true;
                    this.mensagem = 'Cadaste aqui o novo cartão'
                }else if(resp.produto != 'APTLMKT' && resp.produto != 'VI-PESSOAS'){
                    console.log('entrou no else produto');
                    this.showLink = false;
                    this.mensagem = 'Para o produto selecionado, não é possível alterar os dados de cartão de crédito recorrente.'
                }
                else if((resp.formaPagamento != '70' && resp.produto == 'APTLMKT') 
                    || (resp.produto == 'VI-PESSOAS' && (resp.formaPagamento != '98' || resp.formaPagamento != '70'
                        || resp.produto != '62' || resp.produto != '97'))){     // ANNVI-48 INICIO/FIM
                    console.log('entrou no else formadePagamentoo');
                    this.showLink = false;
                    this.mensagem = 'O cadastro de cartão não é permitido para esta forma de pagamento da proposta.'
                }
                
            })
            .catch(error => {
                console.error('Erro ao verificar FormaPagamento:', error);
            });
    }
    
    resendLink(){

        if(this.rotulo == 'Porto Acidentes Pessoais Individual'){
            this.rotulo = 'Acidentes Pessoais Telemarketing'
        }
        getLinkPortoPag({ codRamo: this.codRamo, descricao: this.rotulo, ofertaSelecionada: this.numeroOrcamento, parcelas: '10', idProposta: this.idProposta})
            .then((result) => {
                console.log('result >>', result);
                const link = JSON.parse(result).link;
                //const resp = JSON.parse(result);
                if(this.showLink){
                    this.iframeSrc = link;
                }
                window.addEventListener("message", event => {
                    console.log('event:', event);
                    let dadosCartao = JSON.parse(event.data.message);
                    this.idCartao = dadosCartao.idCartao;
                    this.bandeira = dadosCartao.bandeira;
                    rgstNewCard({ticket: this.idCartao, bandeira: this.bandeira, idProposta: this.idProposta})
                        .then(result => {
                            console.log('Resultado de rgstNewCard:', result);
                            console.log('this.idCartao :>', this.idCartao);
                            console.log('this.bandeira :>', this.bandeira);
                            console.log('this.idProposta :>', this.idProposta);
                        })
                        .catch(error => {
                            console.error('Erro ao chamar rgstNewCard:', error);
                    });
                })
            })
            .catch((error) => {
                console.error('Erro reenvio link', error.message);
            });
    }
}