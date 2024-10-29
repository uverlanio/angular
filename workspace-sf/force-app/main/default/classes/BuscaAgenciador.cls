// PLV-4164 criação da classe
@RestResource(urlMapping='/buscaAgenciador')
global class BuscaAgenciador {

    @HttpPost
    global static Response buscaAgenciador(){
        
        Response result = new Response();
        AgenciadorTO param = (AgenciadorTO) JSON.deserialize(RestContext.request.requestBody.toString(), AgenciadorTO.class);

        // PLV-4326 - INICIO
        
        String qFilter = '';
        String cpf = param.cpf.remove('.').remove('-');
        String cnpj = param.cnpj.remove('.').remove('-').remove('/');

        if(!String.isEmpty(param.nome)) qFilter = qFilter + 'AND Name LIKE \'%' + param.nome +'%\' '; 
        if(!String.isEmpty(param.susep)) qFilter = qFilter + 'AND CodigoSusepCorretor__c = \'' + param.susep +'\' '; 
        if(!String.isEmpty(param.cpf) && cpf.length() == 11 ) qFilter = qFilter + 'AND Cpf__c = \'' + cpf.substring(0,3) + '.' + cpf.substring(3,6) + '.' + cpf.substring(6,9)  + '-' + cpf.substring(9,11) + '\' '; 
        if(!String.isEmpty(param.cnpj) && cnpj.length() == 14 ) qFilter = qFilter + 'AND Cnpj__c = \'' + cnpj.substring(0,2) + '.' + cnpj.substring(2,5) + '.' + cnpj.substring(5,8)  + '/' + cnpj.substring(8,12)  + '-' + cnpj.substring(12,14)  +'\' ';
        if(!String.isEmpty(param.codigoAgenciador) && param.codigoAgenciador.isNumeric()) qFilter = qFilter + 'AND C_digo_do_Agenciador__c = ' + param.codigoAgenciador + ' ';  // 4326-FIX 

        if(String.isEmpty(qFilter) || String.isEmpty(param.papel) ){
            result.data.success = false;
            result.data.descricaoErro = 'Parametros insuficientes ou invalidos.';  // 4326-FIX 
            if( String.isEmpty(param.papel) ) result.data.descricaoErro = 'Parametros insuficientes. Papel deve ser informado.';
            return result;
        }
        // PLV-4869-FIX - INICIO
        if(param.papel == 'Corretor'){
            String query = ('SELECT Id, Name '+
            'FROM DadosCorretor__c ' + 
            'WHERE Name = \'' + param.susep + '\' LIMIT 50000');
            System.debug(' query : ' + query );
            List<DadosCorretor__c> dadosCorretorList = Database.query( query );

            if(dadosCorretorList.isEmpty()){
                result.data.success = false;
                result.data.descricaoErro = 'Nenhum registro encontrado'; 
                return result;
            }

            result.data.agenciadores = new List<AgenciadorTO>();
            for(DadosCorretor__c dad : dadosCorretorList){
                AgenciadorTO ag = new AgenciadorTO();
                ag.nome = '';
                ag.susep = dad.Name;
                ag.codigoAgenciador = '';
                ag.cpf = '';
                ag.cnpj = '';
                ag.papel = '';
                result.data.agenciadores.add(ag);
            }
        }else{
            String query = ('SELECT Id, Name, Cpf__c, Cnpj__c, Papel__c, C_digo_do_Agenciador__c, Ativo__c, CodigoSusepCorretor__c '+
                        'FROM Account ' + 
                        'WHERE Papel__c LIKE \'%' + param.papel + '%\'  AND Ativo__c = true ' + qFilter + ' ' +
                        'LIMIT 50000');
            System.debug(' query : ' + query );
            List<Account> accAgList = Database.query( query );
            // PLV-4326 - FIM

            if(accAgList.isEmpty()){
                result.data.success = false;
                result.data.descricaoErro = 'Nenhum registro encontrado';  // 4326-FIX 
                return result;
            }

            result.data.agenciadores = new List<AgenciadorTO>();
            for(Account acc : accAgList){
                AgenciadorTO ag = new AgenciadorTO();
                ag.nome = acc.Name;
                ag.susep = acc.CodigoSusepCorretor__c;
                ag.codigoAgenciador = String.valueOf(acc.C_digo_do_Agenciador__c);
                ag.cpf = acc.Cpf__c;
                ag.cnpj = acc.Cnpj__c;
                ag.papel = acc.Papel__c;
                result.data.agenciadores.add(ag);
            }
        }
        
        
        // PLV-4869-FIX FIM

        return result;
    }
    
    global class Response {
        public DataTO data {get;set;}
        public MetaTO meta {get;set;}

        public response(){
            this.meta = new MetaTO();
            this.data = new DataTO();
        }
     } 

     global class DataTO {        
        public Boolean success {get;set;}
        public String descricaoErro {get;set;}
        public List<AgenciadorTO> agenciadores {get;set;}

        public dataTO(){
            this.success = true;
        }
     }

     global class MetaTO {
        public String servico {get;set;}
        public Datetime dataExecucao {get;set;}
        public Integer statusHttp {get;set;}
        public String mensagem {get;set;}
        
        public metaTO() {
            this.servico = 'buscaAgenciador';
            this.dataExecucao = System.now();
            this.statusHttp = 200;
            this.mensagem = 'OK';
        }
    }

    global class AgenciadorTO{
        public String nome { get; set; }
        public String susep { get; set; }
        public String codigoAgenciador { get; set; }
        public String cpf { get; set; }
        public String cnpj { get; set; }
        public String papel { get; set; }
    }
}