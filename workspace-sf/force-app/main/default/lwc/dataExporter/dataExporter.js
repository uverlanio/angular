import { LightningElement, track } from 'lwc';

export default class DataExporter extends LightningElement {
    @track message = '';

    handleClick() {
        this.message = 'Data Exporter - ON';
    }   
}