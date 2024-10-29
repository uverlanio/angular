import { LightningElement, api } from 'lwc';

export default class ShowLinkModal extends LightningElement {
    @api formLink;

    handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
    }
}