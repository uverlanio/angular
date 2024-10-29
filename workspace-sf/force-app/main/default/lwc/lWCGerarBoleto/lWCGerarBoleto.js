import { LightningElement } from 'lwc';
import jsBarcode from '@salesforce/resourceUrl/JsBarcode';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';


export default class LWCGerarBoleto extends LightningElement {

    connectedCallback() {
        console.log("teste3");
        Promise.all([
            loadScript(this, jsBarcode)
        ]).then(() => {
            console.log("teste2");
            let barcode = this.template.querySelector('[data-id=barcode]');
            console.log(barcode);
            JsBarcode(barcode, "23791.72402 60000.123459 67104.030001 1 55880000002300");
            
        });
    }
}