@RestResource(urlMapping='/Authenticate/*')
global with sharing class DataExporterController {

    private static final DataExporterController instance = new DataExporterController();
    public static DataExporterController getInstance() {
        return instance;
    }   
    
    //Dinamizar para fazer os dois caminhos
    public String authenticate(String ambiente) {
        String orgSelect = ambiente;
        String url = 'https://test.salesforce.com/services/oauth2/token';

        String clientId = '3MVG9ifmAKCHISba0cCeNdrEWQWEBOlmsZxoB9obahCg6OMnXwcivnIlskiD_i5YcCy_TNmo1tEjI0SdcBpu8';
        String clientSecret = 'ECC833CDBF201404CABC2C16933CE1F66446825F751EEEC36DAD2DF0C4BAAA26';
        String username = 'joao.neres@portoseguro.com.br.' + orgSelect;
        String password = 'OnaibafAdmin321vRHe4sVo5VwjVOxfUOWaYXvEc';

        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        String body = 'grant_type=password' +
                        '&client_id=' + EncodingUtil.urlEncode(clientId, 'UTF-8') +
                        '&client_secret=' + EncodingUtil.urlEncode(clientSecret, 'UTF-8') +
                        '&username=' + EncodingUtil.urlEncode(username, 'UTF-8') +
                        '&password=' + EncodingUtil.urlEncode(password, 'UTF-8');
        req.setBody(body);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            String accessToken = UserInfo.getOrganizationId().substring(0, 15) + ' ' +  UserInfo.getSessionId().substring(15);
            if(accessToken != null){
                System.debug('Access Token: ' + accessToken);
                return accessToken;
            }
            return accessToken;
        } else {
            System.debug('Error: ' + res.getStatus() + ' - ' + res.getBody());
            return null;
        }
    }  

    // 1.GeradorOferta__c - PAI  
    // 2.ConjuntoInformacoes__c - FILHO de GeradorOferta__c
    // 3.InformacaoOferta__c - FILHO de ConjuntoInformacoes__c

    public String sendData(String orgSelect) {
        String url = 'https://portoseguro--' + orgSelect + '.sandbox.my.salesforce.com/services/apexrest/Ofertas';
        String accessToken = DataExporterController.getInstance().authenticate(orgSelect);
    
        // Montagem do Payload - Contorno do erro 'SOQL statements cannot query aggregate relationships more than 1 level away from the root entity object.'
        // Consulta os registros de GeradorOferta__c
        List<GeradorOferta__c> geradorOfertas = [
            SELECT Id, Name
            FROM GeradorOferta__c
        ];

        // Consulta os registros de ConjuntoInformacoes__c
        Map<Id, List<ConjuntoInformacoes__c>> geradorParaConjuntoMap = new Map<Id, List<ConjuntoInformacoes__c>>();
        List<ConjuntoInformacoes__c> conjuntoInformacoes = [
            SELECT Id, Name, GeradorOfertas__c
            FROM ConjuntoInformacoes__c
        ];
        for (ConjuntoInformacoes__c conjunto : conjuntoInformacoes) {
            if (!geradorParaConjuntoMap.containsKey(conjunto.GeradorOfertas__c)) {
                geradorParaConjuntoMap.put(conjunto.GeradorOfertas__c, new List<ConjuntoInformacoes__c>());
            }
            geradorParaConjuntoMap.get(conjunto.GeradorOfertas__c).add(conjunto);
        }

        // Consulta os registros de InformacaoOferta__c
        Map<Id, List<InformacaoOferta__c>> conjuntoParaInformacaoMap = new Map<Id, List<InformacaoOferta__c>>();
        List<InformacaoOferta__c> informacaoOfertas = [
            SELECT Id, Name, ConjuntoInformacoes__c
            FROM InformacaoOferta__c
        ];
        for (InformacaoOferta__c informacao : informacaoOfertas) {
            if (!conjuntoParaInformacaoMap.containsKey(informacao.ConjuntoInformacoes__c)) {
                conjuntoParaInformacaoMap.put(informacao.ConjuntoInformacoes__c, new List<InformacaoOferta__c>());
            }
            conjuntoParaInformacaoMap.get(informacao.ConjuntoInformacoes__c).add(informacao);
        }

        // Cria a estrutura JSON combinada
        List<Map<String, Object>> combinedData = new List<Map<String, Object>>();

        for (GeradorOferta__c geradorOferta : geradorOfertas) {
            Map<String, Object> geradorOfertaMap = new Map<String, Object>();
            //Campos
            geradorOfertaMap.put('Id', geradorOferta.Id);
            geradorOfertaMap.put('Name', geradorOferta.Name);

            List<Map<String, Object>> conjuntosList = new List<Map<String, Object>>();
            if (geradorParaConjuntoMap.containsKey(geradorOferta.Id)) {
                for (ConjuntoInformacoes__c conjunto : geradorParaConjuntoMap.get(geradorOferta.Id)) {
                    Map<String, Object> conjuntoMap = new Map<String, Object>();
                    //Campos
                    conjuntoMap.put('Id', conjunto.Id);
                    conjuntoMap.put('Name', conjunto.Name);

                    List<Map<String, Object>> informacoesList = new List<Map<String, Object>>();
                    if (conjuntoParaInformacaoMap.containsKey(conjunto.Id)) {
                        for (InformacaoOferta__c informacao : conjuntoParaInformacaoMap.get(conjunto.Id)) {
                            Map<String, Object> informacaoMap = new Map<String, Object>();
                            //Campos
                            informacaoMap.put('Id', informacao.Id);
                            informacaoMap.put('Name', informacao.Name);
                            informacoesList.add(informacaoMap);
                        }
                    }
                    conjuntoMap.put('InformacaoOferta__r', informacoesList);
                    conjuntosList.add(conjuntoMap);
                }
            }
            geradorOfertaMap.put('ConjuntoInformacoes__r', conjuntosList);
            combinedData.add(geradorOfertaMap);
        }

        // Serializa os registros em JSON
        String jsonPayload = JSON.serialize(combinedData);    
        System.debug('PAYLOAD => ' + jsonPayload);

        return jsonPayload;

        // String jsonPayload = JSON.serialize(geradorOfertas);

        // HttpRequest req = new HttpRequest();
        // req.setEndpoint(url);
        // req.setMethod('POST');
        // req.setHeader('Authorization', 'Bearer ' + accessToken);
        // req.setHeader('Content-Type', 'application/json');
        // req.setBody(jsonPayload);

        // Http http = new Http();
        // HttpResponse res = http.send(req);

        // if (res.getStatusCode() == 200) {
        //     System.debug('Data sent successfully.');
        // } else {
        //     System.debug('Failed to send data: ' + res.getBody());
        // }
    }

    // @HttpPost
    // global static void receiveData() {
    //     RestRequest req = RestContext.request;
    //     RestResponse res = RestContext.response;

    //     // Lê o payload JSON
    //     String jsonPayload = req.requestBody.toString();

    //     // Desserializa o JSON para listas de objetos
    //     List<GeradorOferta__c> geradorOfertas = (List<GeradorOferta__c>) JSON.deserialize(jsonPayload, List<GeradorOferta__c>.class);

    //     // Cria listas para inserção
    //     List<GeradorOferta__c> newGeradorOfertas = new List<GeradorOferta__c>();
    //     List<ConjuntoInformacoes__c> newConjuntoInformacoes = new List<ConjuntoInformacoes__c>();
    //     List<InformacaoOferta__c> newInformacaoOfertas = new List<InformacaoOferta__c>();

    //     // Mapeamento de Ids antigos para novos
    //     Map<Id, Id> geradorOfertaMap = new Map<Id, Id>();
    //     Map<Id, Id> conjuntoInformacoesMap = new Map<Id, Id>();

    //     // Insere os registros pai
    //     for (GeradorOferta__c geradorOferta : geradorOfertas) {
    //         GeradorOferta__c newGeradorOferta = new GeradorOferta__c(Name = geradorOferta.Name);
    //         newGeradorOfertas.add(newGeradorOferta);
    //     }

    //     insert newGeradorOfertas;

    //     // Mapeia os novos IDs
    //     for (Integer i = 0; i < geradorOfertas.size(); i++) {
    //         geradorOfertaMap.put(geradorOfertas[i].Id, newGeradorOfertas[i].Id);
    //     }

    //     // Insere os registros filhos de primeiro nível (ConjuntoInformacoes__c)
    //     for (GeradorOferta__c geradorOferta : geradorOfertas) {
    //         for (ConjuntoInformacoes__c conjunto : geradorOferta.ConjuntoInformacoes__r) {
    //             ConjuntoInformacoes__c newConjunto = new ConjuntoInformacoes__c(
    //                 Name = conjunto.Name,
    //                 GeradorOfertas__c  = geradorOfertaMap.get(geradorOferta.Id)
    //             );
    //             newConjuntoInformacoes.add(newConjunto);
    //         }
    //     }

    //     insert newConjuntoInformacoes;

    //     // Mapeia os novos IDs
    //     for (Integer i = 0; i < newConjuntoInformacoes.size(); i++) {
    //         conjuntoInformacoesMap.put(newConjuntoInformacoes[i].Id, newConjuntoInformacoes[i].Id);
    //     }

    //     // Insere os registros filhos de segundo nível (InformacaoOferta__c)
    //     for (ConjuntoInformacoes__c conjunto : newConjuntoInformacoes) {
    //         for (InformacaoOferta__c informacao : conjunto.InformacaoOferta__r) {
    //             InformacaoOferta__c newInformacao = new InformacaoOferta__c(
    //                 Name = informacao.Name,
    //                 ConjuntoInformacoes__c = conjuntoInformacoesMap.get(conjunto.Id)
    //             );
    //             newInformacaoOfertas.add(newInformacao);
    //         }
    //     }

    //     insert newInformacaoOfertas;

    //     res.responseBody = Blob.valueOf('Dados inseridos com sucesso!');
    // }

    @HttpPost
    global static void receiveData() {
        RestRequest req = RestContext.request;
        String jsonString = req.requestBody.toString();
        
        List<Map<String, Object>> records = (List<Map<String, Object>>) JSON.deserializeUntyped(jsonString);

        Map<String, GeradorOferta__c> geradorMap = new Map<String, GeradorOferta__c>();
        Map<String, ConjuntoInformacoes__c> conjuntoMap = new Map<String, ConjuntoInformacoes__c>();
        Map<String, InformacaoOferta__c> informacaoMap = new Map<String, InformacaoOferta__c>();

        // Deserializa o JSON e popula os mapas
        for (Map<String, Object> geradorOfertaMap : records) {
            GeradorOferta__c gerador = new GeradorOferta__c();
            gerador.Name = (String) geradorOfertaMap.get('Name');
            gerador.Id = (String) geradorOfertaMap.get('Id');
            geradorMap.put(gerador.Name, gerador);

            List<Map<String, Object>> conjuntoList = (List<Map<String, Object>>) geradorOfertaMap.get('ConjuntoInformacoes__r');
            for (Map<String, Object> conjuntoMapObj : conjuntoList) {
                ConjuntoInformacoes__c conjunto = new ConjuntoInformacoes__c();
                conjunto.Name = (String) conjuntoMapObj.get('Name');
                conjunto.GeradorOfertas__c = gerador.Id;
                conjunto.Id = (String) conjuntoMapObj.get('Id');
                conjuntoMap.put(conjunto.Name, conjunto);

                List<Map<String, Object>> informacaoList = (List<Map<String, Object>>) conjuntoMapObj.get('InformacaoOferta__r');
                for (Map<String, Object> informacaoMapObj : informacaoList) {
                    InformacaoOferta__c informacao = new InformacaoOferta__c();
                    informacao.Name = (String) informacaoMapObj.get('Name');
                    informacao.ConjuntoInformacoes__c = conjunto.Id;
                    informacao.Id = (String) informacaoMapObj.get('Id');
                    informacaoMap.put(informacao.Name, informacao);
                }
            }
        }

        // Inserir ou atualizar GeradorOferta__c
        for (GeradorOferta__c gerador : geradorMap.values()) {
            GeradorOferta__c existingGerador = [SELECT Id FROM GeradorOferta__c WHERE Name = :gerador.Name LIMIT 1];
            if (existingGerador != null) {
                gerador.Id = existingGerador.Id;
                update gerador;
            } else {
                insert gerador;
            }
        }

        // Inserir ou atualizar ConjuntoInformacoes__c
        for (ConjuntoInformacoes__c conjunto : conjuntoMap.values()) {
            ConjuntoInformacoes__c existingConjunto = [SELECT Id FROM ConjuntoInformacoes__c WHERE Name = :conjunto.Name AND GeradorOfertas__c = :conjunto.GeradorOfertas__c LIMIT 1];
            if (existingConjunto != null) {
                conjunto.Id = existingConjunto.Id;
                update conjunto;
            } else {
                insert conjunto;
            }
        }

        // Inserir ou atualizar InformacaoOferta__c
        for (InformacaoOferta__c informacao : informacaoMap.values()) {
            InformacaoOferta__c existingInformacao = [SELECT Id FROM InformacaoOferta__c WHERE Name = :informacao.Name AND ConjuntoInformacoes__c = :informacao.ConjuntoInformacoes__c LIMIT 1];
            if (existingInformacao != null) {
                informacao.Id = existingInformacao.Id;
                update informacao;
            } else {
                insert informacao;
            }
        }
    }

    public static String orgSelect(String ambiente) {
        // Ler os endpoints de cada organização de destino da configuração personalizada
        String endpointSniper = ''; //ConfiguracaoPersonalizada__c.getInstance().EndpointSniper__c;
        String endpointHomolog = ''; //ConfiguracaoPersonalizada__c.getInstance().EndpointHomolog__c;
        String endpointPreprod = ''; //ConfiguracaoPersonalizada__c.getInstance().EndpointPreprod__c;

        // Determinar dinamicamente qual endpoint usar com base em alguma lógica específica
        String endpointDestino;
        if (ambiente == 'Homologação') {
            endpointDestino = endpointHomolog;
        } else if (ambiente == 'Sniper') {
            endpointDestino = endpointSniper;
        } else if (ambiente == 'PreProd') {
            endpointDestino = endpointPreprod;
        } else {
            System.debug('Erro na seleção do ambiente, verifique os parametros enviados');
        }


        return endpointDestino;
    }

    global static String pocOfferDml(String name){
        String insertedOffers;
        List<GeradorOferta__c> geradoresOfertas = new List<GeradorOferta__c>();
        // SELECT CodigoOfertaConsultiva__c, CurrencyIsoCode, Owner.Id from GeradorOferta__c

        geradoresOfertas.add(new GeradorOferta__c(Name = name, CodigoOfertaConsultiva__c = 'ZELADORIA_EQUALIZ', CurrencyIsoCode = 'BRL'));
        insert geradoresOfertas;

        List<ConjuntoInformacoes__c> conjuntosInformacoes = new List<ConjuntoInformacoes__c>();
        conjuntosInformacoes.add(new ConjuntoInformacoes__c(Name = name, CurrencyIsoCode = 'BRL', GeradorOfertas__c = geradoresOfertas[0].Id));
        insert conjuntosInformacoes;

        List<InformacaoOferta__c> informacoesOferta = new List<InformacaoOferta__c>();
        informacoesOferta.add(new InformacaoOferta__c(Name = name, CurrencyIsoCode = 'BRL', ConjuntoInformacoes__c = conjuntosInformacoes[0].Id));
        insert informacoesOferta;

        return insertedOffers;
    }
 
}