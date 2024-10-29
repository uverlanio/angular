// POR062-1 - INICIO
@isTest
class UtilTest {
    @TestSetup
    static void setup()
    {
        Account conta = (Account) new AccountFactory.PessoaFisica().createRecord();
        Case casoAtendimento = (Case) new CasoFactory.AtendimentoSinistro().createRecord();
        Case sinistro = (Case) new CasoFactory.Sinistro(casoAtendimento, conta).createRecord();
    }

    @isTest
    static void recuperarIdsPorCampoDeSObjectTest()
    {
        List<Case> casos = [SELECT Id, AccountId, CaseNumber FROM Case];
        Test.startTest();
        Set<Id> numerosCaso = Util.recuperarIdsPorCampoDeSObject(casos, Schema.Case.CaseNumber);
        Set<Id> idContas = Util.recuperarIdsPorCampoDeSObject(casos, Schema.Case.AccountId);
        Test.stopTest();
        System.assertEquals(0, numerosCaso.size(), 'Campo Schema.Case.CaseNumber não é um campo Id, então deveria retornar 0 ids no conjunto.');
        System.assert(idContas.size() > 0, 'Campo Schema.Case.AccountId é um campo Id, então deveria retornar pelo menos 2 ids no conjunto.');
    }

    @isTest
    static void recuperarStringsPorCampoDeSObjectTest()
    {
        List<Case> casos = [SELECT Id, AccountId, CaseNumber FROM Case];
        Test.startTest();
        Set<String> numerosCaso = Util.recuperarStringsPorCampoDeSObject(casos, Schema.Case.CaseNumber);
        Set<String> idContas = Util.recuperarStringsPorCampoDeSObject(casos, Schema.Case.AccountId);
        Test.stopTest();
        System.assert(numerosCaso.size() > 0);
        System.assert(idContas.size() > 0);
    }

    @isTest
    static void mapearValorPorCampoDeSObjectTest()
    {
        List<Case> casos = [SELECT Id, AccountId, CaseNumber FROM Case];
        Test.startTest();
        Map<String, SObject> mapaCasoPorCampo = Util.mapearValorPorCampoDeSObject(casos, Schema.Case.CaseNumber);
        Test.stopTest();
        for(String chave : mapaCasoPorCampo.keySet()) {
            SObject registro = mapaCasoPorCampo.get(chave);
            System.assertEquals(String.valueOf(registro.get(Schema.Case.CaseNumber)), chave);
        }
    }

    @isTest
    static void contemApenasNumerosTest()
    {
        Boolean apenasNumero = Util.contemApenasNumeros('0123456789');
        Boolean naoContemApenasNumero = Util.contemApenasNumeros('0123456 789');
        System.assert(apenasNumero, 'contemApenasNumerosTest (0): ' + apenasNumero);
        System.assert(!naoContemApenasNumero, 'contemApenasNumerosTest (1): ' + naoContemApenasNumero);
    }

    @isTest
    static void gerarIdFalsoTest()
    {
        System.debug('Prefixo: ' + Schema.Account.getSObjectType().getDescribe().getKeyPrefix());
        Id fakeId = Util.gerarIdFalso(Schema.Account.getSObjectType());
        System.assertEquals(
            String.valueOf(fakeId).substring(0, 3), Schema.Account.getSObjectType().getDescribe().getKeyPrefix(),
            'gerarIdFalsoTest(1): Prefixo diferente do esperado.'
        );
    }

    //LECVP-72 - INICIO
    @isTest static void testarMontarDataHoraComGMT(){

        Test.startTest();

        Datetime dt = Util.montarDataHoraComGMT(Datetime.now());
        String dtString = dt.format();

        String regex = '(\\d{2})/(\\d{2})/(\\d{4}) (\\d{2}):(\\d{2})';
        Pattern pattern = Pattern.compile(regex);
        Matcher matcher = pattern.matcher(dtString);

        System.assert(matcher.matches());

        Test.stopTest();
    }
    //LECVP-72 - FIM

    @isTest static void testGerarStringRandomica(){

        Test.startTest();

        Util.gerarStringRandomica(10);

        Test.stopTest();
    }

    
    @isTest static void testGerarStringRandomicaAlpha(){

        Test.startTest();

        Util.gerarStringRandomicaAlpha(10);

        Test.stopTest();
    }
    

    
    @isTest static void buscaPeriodoInadimplenciaProdTest(){

        Test.startTest();

        try
        {
            Util.buscaPeriodoInadimplenciaProd('xxxx');
        }
        catch( Exception e )
        {

        }

        Test.stopTest();
    }


    @isTest static void truncateNumberTest(){

        Test.startTest();

        Util.truncateNumber(10.999);
        Util.truncateNumber(10);
        Util.truncateNumber(10.1);

        Test.stopTest();
    }
    
    
    @isTest static void limparNomeTest(){

        Test.startTest();

        String nomeCompleto = 'Rogerio Severo';
        String primeiroNome = 'Rogerio';

        Util.limparNome(nomeCompleto);  
        Util.getPrimeironome(nomeCompleto);   
        Util.getSobrenome(nomeCompleto);   

        Util.limparNome(primeiroNome);  
        Util.getPrimeironome(primeiroNome);   
        Util.getSobrenome(primeiroNome);   
        Util.getPrimeironome('');

        Test.stopTest();
    }

    
    @isTest static void enviarEmailTest(){

        Test.startTest();

        String pBodyToSend = 'Olá'; 
        List<String> pRecipients = new List<String>();

        pRecipients.add('teste@gmail.com');

        String pSubject = 'teste';

        Util.enviarEmail(pBodyToSend,pRecipients,pSubject);        

        try
        {
            Util.enviarEmail('', new List<String>() ,''); 
        }
        catch(Exception e)
        {

        }

        Test.stopTest();
    }
    
    
    @isTest static void calculaDataFinalPorDiasUteisTest(){

        Test.startTest();

        BusinessHours horarioComercial = [SELECT ID,MondayStartTime,MondayEndTime From BusinessHours limit 1];

        Util.calculaDataFinalPorDiasUteis(horarioComercial, system.today(), 10);

        Test.stopTest();
    }
    
   
    
    @isTest static void retornaValorPicklistTest(){

        Test.startTest();        

        Util.retornaValorPicklist('Account', 'Type');

        Test.stopTest();
    }

    @isTest static void tratarStringsTest(){

        Test.startTest();        

        String cpf = '356.320.668-90';
        String phone = '55 (11) 3904-1377'; //ANNVI-201 - INICIO/FIM
        String cep = '05135-000';

        Util.getNumCPF(cpf);
        Util.getDigitoCPF(cpf);

        Util.getPhoneDDD(phone);
        Util.getPhoneNumber(phone);
        Util.getNumCep(cep);
        Util.getDigitoCep(cep);
        Util.getMascaraTelefone('39041357','11');
        Util.imprimeCNPJINT('81.381.790/0001-02');
        Util.imprimeCNPJ('81.381.790/0001-02');
        Util.imprimeCNPJ('81.381.790/0001-02', '.');
        Util.encryptDocPublicURL('x','x');   
        Util.printLimits('Teste');             
        Util.isCNPJ('81.381.790/0001-02');
        Util.imprimeCPF('356.320.668-69');

        Test.stopTest();
    }

    
    @isTest static void gerarQueryTest(){

        String nomeSobject = 'ACCOUNT'; 
        List<String> campos = new List<String>(); 
        List<String> criterios = new List<String>();
        String criteriosStr = 'XXX';

        Test.startTest();        

        Util.gerarQuery(nomeSobject,campos,criterios);         
        Util.gerarQuery(nomeSobject,campos,criteriosStr);  

        Test.stopTest();
    }    
    

     
    @isTest static void ContentWorkspaceTest(){

        Test.startTest();

        try {
            Util.retornarBibliotecaPadrao();    
        } catch (Exception e) {
            
        }
        
        try{
            Util.retornarPastaPadrao();
        } catch (Exception e) {
            
        }
        

        Test.stopTest();
    }

      
    @isTest static void sObjectActionCIVTest(){

        Test.startTest();

        String pAcion       = 'update'; 
        SObject pListToSend = new Account(); 
        Boolean pAppOrNone  = false;
        Boolean pStripNull  = false;
        String pExternal    = 'xx';
        Boolean nullName    = true;
       
        try {
            Util.sObjectActionCIV( pAcion, pListToSend, pAppOrNone, pStripNull, pExternal, nullName );    
        } catch (Exception e) {
            
        }
        

        Test.stopTest();
    }
    
     
    @isTest static void gerarHeaderAutenticacaoTest(){        

        Test.startTest();     

        String nomeServico = 'XXXX'; 
        Map<String, String> headers = new Map<String, String>();        

        Util.gerarHeaderAutenticacao(nomeServico, headers);        

        Test.stopTest();
    }        
    
    
    @isTest static void compositeResponseToMapTest(){        

        Test.startTest();     
        
        List<SObject> pListToSend = new List<Account>();
        String responseBody = '{"code": 200,"body":""}';
        Boolean pAppOrNone = true;

        try {
            Util.compositeResponseToMap(pListToSend, responseBody, pAppOrNone);    
        } catch (Exception e) {
            system.assertEquals('Sem resposta do serviço!', e.getMessage());
        }
        

        Test.stopTest();
    }
    //ANNVI-201 - INICIO
    @isTest
    public static void testGetLockListSObject() {

        Test.startTest();

        List<Account> plSObject = new List<Account>();
        Account account = TestDataFactory.gerarConta();
        
        plSObject.add(account);
        
        List<Account> result = Util.getLockListSObject(plSObject, 'IdExterno__c');

        Test.stopTest();
    }
    //ANNVI-201 - FIM              
}