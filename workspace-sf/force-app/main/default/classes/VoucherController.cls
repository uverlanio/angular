/**
* @author Renato Matheus Simião
* @version 1.0
* @date 2019-12-03
* @description Classe de controle para a criação de Voucher em Proposta
*/
// PLV-2939 INICIO
// PLV-3395	INICIO
// PLV-3726 INICIO
public class VoucherController {	//PLV-4805 INICIO/FIM
    
    public String renderAs { get; private set; }
    public SeguradoProposta__c segurado { get; private set; }
    
    public List<GarantiaWrapper> lwGarantiaPTBR { get; private set; }
    public List<GarantiaWrapper> lwGarantiaENUS { get; private set; }
    public List<GarantiaWrapper> lwGarantiaESES { get; private set; }
    public List<GarantiaWrapper> lwGarantiaFRFR { get; private set; }
    public Quote proposta {get; private set;}    
    public List<GarantiaProduto__c> lGarantiaPrdodutoTecnico{get; private set;}
    public List<GarantiaProposta__c> lGarantiaProposta{get; private set;}
    public String dataEmissao {get; private set;}
    public String nProposta {get; private set;}
    public String nomeSegurado {get; private set;}
    public String vigenciaInicial {get; private set;}
    public String vigenciaFinal {get; private set;}
    public String vigencia {get; private set;}
    public String vigenciaIng {get; private set;}
    public String vigenciaFr {get; private set;}
    public String vigenciaEs {get; private set;}
    public String pessoaParaAvisar {get; private set;}
    public String telefonePessoaParaAvisar {get; private set;}
    public String nomePlano {get; private set;}

    //LECVPV 189 - INICIO
    public Boolean hasSocialName                {get; set;} 
    public String  nomeSocial                   {get; set;}
    //LECVPV 189 - FIM
    
    public VoucherController() {

        this.lwGarantiaPTBR = new List<GarantiaWrapper>();
        this.lwGarantiaENUS = new List<GarantiaWrapper>();
        this.lwGarantiaESES = new List<GarantiaWrapper>();
        this.lwGarantiaFRFR = new List<GarantiaWrapper>();
        
        
        Map<String,String> mPageParam = ApexPages.currentPage().getParameters();
        
        this.renderAs = mPageParam.containsKey('renderAs') ?  mPageParam.get('renderAs') : '';
        //PLV-3746 - INICIO
        String propostaId;
        if (!mPageParam.containsKey('propostaId') && !mPageParam.containsKey('token') && (ApexPages.currentPage().getParameters().get('numero') == null || ApexPages.currentPage().getParameters().get('numero') == '')) {
            return;
        }
        if(mPageParam.containsKey('propostaId')){
            propostaId = mPageParam.get('propostaId');
        }
        if(mPageParam.containsKey('token')){
            CryptoToken c = new CryptoToken();  
            String chave = mPageParam.get('token');
            system.debug('chave'+chave);
            chave = chave.replace(' ','+');
            String chaveDescript = c.decrypt(chave);
            String dadosDoc = chaveDescript;
            String[] trataChave = dadosDoc.split('\\|');
            propostaId = trataChave[0];
            system.debug('propostaId'+propostaId);
            
        }
        if(ApexPages.currentPage().getParameters().get('numero') != null && ApexPages.currentPage().getParameters().get('numero') != ''){
            segurado = [SELECT Id, GrupoProposta__r.ContratanteProposta__r.Proposta__c,
                        NomeContatoEmergencia__c, TelefoneContatoEmergencia__c,
                        GrupoProposta__r.ContratanteProposta__r.Proposta__r.Name,
                        GrupoProposta__r.ContratanteProposta__r.Proposta__r.Produto__r.Name,
                        GrupoProposta__r.ContratanteProposta__r.Proposta__r.NumeroPropostaUnico__c,
                        GrupoProposta__r.ContratanteProposta__r.Proposta__r.VigenciaInicial__c,
                        GrupoProposta__r.ContratanteProposta__r.Proposta__r.VigenciaFinal__c,
                        GrupoProposta__r.ContratanteProposta__r.Proposta__r.DataProtocolo__c,
                        GrupoProposta__r.ContratanteProposta__r.Proposta__r.Produto__r.ProdutoTecnico__c,
                        Conta__r.Name,
                        Conta__r.NomeSocial__c //LECVPV 189 - INICIO/FIM  
                        FROM SeguradoProposta__c
                        WHERE GrupoProposta__r.ContratanteProposta__r.Proposta__r.Name =: ApexPages.currentPage().getParameters().get('numero')];
        }else{
            segurado = [SELECT Id, GrupoProposta__r.ContratanteProposta__r.Proposta__c,
                        NomeContatoEmergencia__c, TelefoneContatoEmergencia__c,
                        GrupoProposta__r.ContratanteProposta__r.Proposta__r.Name,
                        GrupoProposta__r.ContratanteProposta__r.Proposta__r.Produto__r.Name,
                        GrupoProposta__r.ContratanteProposta__r.Proposta__r.NumeroPropostaUnico__c,
                        GrupoProposta__r.ContratanteProposta__r.Proposta__r.VigenciaInicial__c,
                        GrupoProposta__r.ContratanteProposta__r.Proposta__r.VigenciaFinal__c,
                        GrupoProposta__r.ContratanteProposta__r.Proposta__r.DataProtocolo__c,
                        GrupoProposta__r.ContratanteProposta__r.Proposta__r.Produto__r.ProdutoTecnico__c,
                        Conta__r.Name,
                        Conta__r.NomeSocial__c //LECVPV 189 - INICIO/FIM 
                        FROM SeguradoProposta__c
                        WHERE GrupoProposta__r.ContratanteProposta__r.Proposta__c = :propostaId];
        }
        //PLV-3746 - FIM
        
        //LECVPV 189 - INICIO
        this.hasSocialName = String.isEmpty(segurado.Conta__r.NomeSocial__c) ? false : true;
        this.nomeSocial = segurado.Conta__r.NomeSocial__c;
         //LECVPV 189 - FIM
        
        lGarantiaPrdodutoTecnico = [SELECT  Id, Garantia__c, Garantia__r.Name,Garantia__r.Sigla__c,OrdemPrioridade__c, LimiteMinimoCaracteristicaEspecial__c,
                                    LimiteMaximoCaracteristicaEspecial__c, TipoCaracteristicaEspecial__c
                                    FROM GarantiaProduto__c
                                    WHERE Produto__c =: segurado.GrupoProposta__r.ContratanteProposta__r.Proposta__r.Produto__r.ProdutoTecnico__c ORDER BY OrdemPrioridade__c ASC];

        lGarantiaProposta = [SELECT Id, Capital__c, Garantia__r.Name, Garantia__r.Sigla__c, CurrencyIsoCode //AV-824-INICIO/FIM
                             FROM   GarantiaProposta__c
                             WHERE   Proposta__c = :segurado.GrupoProposta__r.ContratanteProposta__r.Proposta__c];
        
        proposta = [SELECT Id, TipoViagem__c, Produto__r.GerarVoucher__c //PLV - 4440  INICIO/FIM adicionado gerarvoucher na query
                    FROM Quote
                    WHERE Id =: segurado.GrupoProposta__r.ContratanteProposta__r.Proposta__c];
        
        if(!proposta.Produto__r.GerarVoucher__c)return; //PLV - 4440  INICIO/FIM Ajuste gerarVoucher produto
        
        pessoaParaAvisar = 	segurado.NomeContatoEmergencia__c;
        nomePlano = segurado.GrupoProposta__r.ContratanteProposta__r.Proposta__r.Produto__r.Name;
        nProposta = (segurado.GrupoProposta__r.ContratanteProposta__r.Proposta__r.NumeroPropostaUnico__c).replace('-','/');
        nomeSegurado = segurado.Conta__r.Name;
        System.debug('nomeSegurado '+nomeSegurado);
        vigenciaInicial = (segurado.GrupoProposta__r.ContratanteProposta__r.Proposta__r.VigenciaInicial__c).format();
        vigenciaFinal = (segurado.GrupoProposta__r.ContratanteProposta__r.Proposta__r.VigenciaFinal__c).format();
        vigencia = vigenciaInicial+ ' - '+ vigenciaFinal;
        vigenciaIng = vigencia.replace('-', 'and');
        vigenciaFr = vigencia.replace('-', 'au');
        vigenciaEs = vigencia.replace('-', 'al');
        dataEmissao = segurado.GrupoProposta__r.ContratanteProposta__r.Proposta__r.DataProtocolo__c.format();
        // PLV-3703 INICIO
        // VIAG-288 INICIO
        System.debug('segurado.TelefoneContatoEmergencia__c '+segurado.TelefoneContatoEmergencia__c);
        if( !String.isBlank(segurado.TelefoneContatoEmergencia__c) ){
            System.debug('tel1'+segurado.TelefoneContatoEmergencia__c);
            String tel = segurado.TelefoneContatoEmergencia__c.replace('-','');
            String newTel ;
    
            if(tel.left(2) == '55' && (tel.length() == 12 || tel.length() == 13)) {
                if(tel.length() == 13){
                    newTel = tel.left(2);
                    newTel += ' (' + tel.mid(2,2) + ') ';
                    newTel += tel.mid(4, 5);
                    newTel += '-';
                    newTel += tel.right(4);
                } else if(tel.length() == 12) {
                    newTel = tel.left(2);
                    newTel += ' (' + tel.mid(2,2) + ') ';
                    newTel += tel.mid(4, 4);
                    newTel += '-';
                    newTel += tel.right(4);
                }
                newTel = '+'+newTel;
            } else{
                if( tel.length() == 10 ){
                    newTel = '(' + tel.left(2) + ') ';
                    newTel += tel.mid(2, 4);
                    newTel += '-';
                    newTel += tel.right(4);
                } else if( tel.length() == 11 ){
                    newTel = '(' + tel.left(2) + ') ';
                    newTel += tel.mid(2, 5);
                    newTel += '-';
                    newTel += tel.right(4);
                } else {
                    newTel = tel;
                }
            }
            telefonePessoaParaAvisar = newTel;
        }
        // VIAG-288 FIM
        // PLV-3703 FIM     
        // Map de Tradução organizado pelo idioma e a Sigla da Garantia: Map<Idioma__c, Map<DeveloperName,Traducao__mdt>>
        //PLV-5277 - INICIO
        Map<String,Map<String,Traducao__mdt>> mTraducao = new Map<String,Map<String,Traducao__mdt>>();
        for (Traducao__mdt traducao : [SELECT Id, DeveloperName, Idioma__c, Texto__c
                                       FROM Traducao__mdt
                                       WHERE Objeto__c = 'Garantia'
                                       ORDER BY Idioma__c, DeveloperName]) {
                                           
            if (!traducao.DeveloperName.contains('_')) continue;
            
            Map<String, Traducao__mdt> mSigla;
            if (mTraducao.containsKey(traducao.Idioma__c)) {
                mSigla = mTraducao.get(traducao.Idioma__c);
            } else {
                mSigla = new Map<String, Traducao__mdt>();
                mTraducao.put(traducao.Idioma__c, mSigla);
            }
            
            mSigla.put(traducao.DeveloperName.split('_').get(0), traducao);
        }        
        for (GarantiaProduto__c garantiaProduto : [SELECT  Id, Produto__r.Name, Produto__r.RecordType.DeveloperName, Garantia__c, Garantia__r.Name,OrdemPrioridade__c, LimiteMinimoCaracteristicaEspecial__c,
                                    LimiteMaximoCaracteristicaEspecial__c, TipoCaracteristicaEspecial__c,Garantia__r.Sigla__c 
                                                   FROM GarantiaProduto__c                                                   
                                                   WHERE Produto__r.Id =: segurado.GrupoProposta__r.ContratanteProposta__r.Proposta__r.Produto__r.Id
                                                   AND Produto__r.RecordType.DeveloperName = 'ProdutoComercial'
                                                   ORDER BY OrdemPrioridade__c ASC]) {
                                                                   
            this.lwGarantiaPTBR.add(new GarantiaWrapper(garantiaProduto, mTraducao, 'ptBR', lGarantiaProposta));
            this.lwGarantiaENUS.add(new GarantiaWrapper(garantiaProduto, mTraducao, 'enUS', lGarantiaProposta));
            this.lwGarantiaESES.add(new GarantiaWrapper(garantiaProduto, mTraducao, 'esES', lGarantiaProposta));
            this.lwGarantiaFRFR.add(new GarantiaWrapper(garantiaProduto, mTraducao, 'frFR', lGarantiaProposta));
        }
        //PLV-5277 - FIM        
    }
    public class GarantiaWrapper {
        
        public String descricao { get; set; }
        public String capital { get; set; }
        public GarantiaProduto__c garantiaProposta { get; set; }
        
        public GarantiaWrapper(GarantiaProduto__c pGarantiaProduto, Map<String,Map<String,Traducao__mdt>> pmTraducao, String pIdioma, List<GarantiaProposta__c> gp) {
            
            this.garantiaProposta = pGarantiaProduto;
            system.debug('SIGLA: '+pGarantiaProduto.Garantia__r.Sigla__c);
            if (pmTraducao.containsKey(pIdioma) && pmTraducao.get(pIdioma).containsKey(pGarantiaProduto.Garantia__r.Sigla__c)) {
                system.debug('entrou na traducao');
                this.descricao = pmTraducao.get(pIdioma).get(pGarantiaProduto.Garantia__r.Sigla__c).Texto__c;
            } else {
                system.debug('nao entrou na traduçao');
                this.descricao = garantiaProposta.Garantia__r.Name;
            }
            system.debug('GPsize: '+gp.size());
            system.debug('gp: '+gp);
            for(GarantiaProposta__c g: gp){
                system.debug('g.Garantia__c: '+g.Garantia__c);
                system.debug('pGarantiaProduto.Garantia__c: '+pGarantiaProduto.Garantia__c);
                if(g.Garantia__c == pGarantiaProduto.Garantia__c){
                    if(g.Capital__c != null && g.Capital__c >0){
                        
                        
                        capital = trataValores(g.Capital__c.format(), g.CurrencyIsoCode); //PLV-3884 - INICIO/FIM - Ajuste Moedas
                        /* PLV-5277 - INICIO */
                        if(pGarantiaProduto.TipoCaracteristicaEspecial__c != null){
                            if(pIdioma == 'enUS'){
                                 
                                capital = capital +'('
                                    +pGarantiaProduto.LimiteMaximoCaracteristicaEspecial__c+ ' '+
                                    +'Day(s))';
                            }else if(pIdioma =='esES'){
                                capital = capital +'('
                                    +pGarantiaProduto.LimiteMaximoCaracteristicaEspecial__c+ ' '+
                                    +'Día(s))';
                            }else if(pIdioma =='frFR'){
                                capital = capital +'('
                                    +pGarantiaProduto.LimiteMaximoCaracteristicaEspecial__c+ ' '+
                                    +'jour(s))';
                            }else{
                                
                                capital = capital +'('
                                    +pGarantiaProduto.LimiteMaximoCaracteristicaEspecial__c+ ' '+
                                    +pGarantiaProduto.TipoCaracteristicaEspecial__c+ ')';
                            }
                            
                        }
                        /* PLV-5277 - FIM */
                        break;
                    }
                    else{
                        if(pIdioma == 'enUS'){
                            capital = 'Yes';
                            break;
                        }else if(pIdioma =='esES'){
                            capital = 'Si';
                            break;
                        }else if(pIdioma =='frFR'){
                            capital = 'Oui';
                            break;
                        }else{
                            capital = 'Contratada';
                            break;
                        }

                    }
                } else{
                        if(pIdioma == 'enUS'){
                            capital = 'No';
                        }else if(pIdioma =='esES'){
                            capital = 'No';
                        }else if(pIdioma =='frFR'){
                            capital = 'Non';
                        }else{
                            capital = 'Não Contratada';
                        }
                }
            }
        }
    }
    public PageReference doAction(){
        return new PageReference('/');
    }
    //PLV-3884 - INICIO - Ajuste Moedas
    public static String trataValores(string valor, string moeda){
        if(valor.contains(',')){
            string v = valor.substring(valor.indexOf(','),valor.length());
            if(v.length() == 2){
                if(moeda == 'BRL'){
                    valor = 'R$ '+valor +'0'; 
                }else if(moeda == 'USD'){
                    valor = 'US$ '+valor +'0';
                }else If(moeda == 'EUR'){
                    valor = '€ '+valor +'0';
                }
            }
        }else{
            if(moeda == 'BRL'){
                valor = 'R$ '+valor+',00';
            }else if(moeda == 'USD'){
                valor = 'US$ '+valor+',00';
            }else If(moeda == 'EUR'){
                valor = '€ '+valor+',00';
            }            
        }
        
        return valor;
    }
    //PLV-3884 - FIM - Ajuste Moedas
    
}
// PLV-2939 FIM
// PLV-3395 FIM
// PLV-3726 FIM