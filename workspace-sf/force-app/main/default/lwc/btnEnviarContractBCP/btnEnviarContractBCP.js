// LECVP-72 - Inicio
import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

/* Código Apex */
import enviarContractBCP from '@salesforce/apex/BtnEnviarContractBCPController.enviarContractBCP';

/* Importação de funções JS */
import { gerarMensagemDeErro } from 'c/utils';

export default class BtnEnviarContractBCP extends LightningElement {
	@track disabled = false;

	enviarContractBCP() {
		this.disabled = true
		enviarContractBCP()
			.then(resposta => {
				resposta = JSON.parse(resposta);
				const mensagem = this.prepararMensagem(resposta)
				this.notificar(mensagem);
			})
			.catch(error => {
				let message = gerarMensagemDeErro(error);
				this.notificar({ message, sucesso: false });
				console.warn('Exceção:', message);
			}).finally(() => {
				this.disabled = false;
			});
	}

	prepararMensagem({ message = '', sucesso = true }) {
		const mensagemEvento = {
			title: sucesso ? 'Sucesso' : 'Atenção',
			message,
			variant: sucesso ? 'success' : 'warning',
			mode: 'dismissible'
		};
		return mensagemEvento;
	}

	notificar = (mensagem) => {
		const event = new ShowToastEvent(mensagem);
		this.dispatchEvent(event);
	}
}
// LECVP-72 - Fim