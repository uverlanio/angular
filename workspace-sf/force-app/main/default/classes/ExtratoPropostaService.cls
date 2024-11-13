/*******************************************************************************************************************************
* Classe service para consulta de extrado de propostas para o Megaday
* @author Squad Globant
* @date 19/07/2021
* Classe criada por conta da história PLV-5068
******************************************************************************************************************************/

public class ExtratoPropostaService {
    
    public ExtratoPropostaService(){}

    public static List<Quote> getPropostas(ExtratoPropostaRest.Request request){
        List<Quote> lstPropostas = [
            SELECT 
                ID, 
                Name,
                Origem__c,                  // origem
                NumeroProposta__c,          // proposta
                Status,                     // status
                produto__r.name,            // produto
                PremioTotal__c,             // premio
                DataProtocolo__c,           // datatransmissao  //PLV- 5068 - FIX01 - INICIO/FIM
                LastModifiedDate,           // datamodificacao
                Produto__r.ProductCode,     //II-159 INICIO-FIM

                (SELECT id FROM GarantiasProposta__r WHERE Garantia__r.Sigla__c in: request.coberturas )
            FROM Quote
            WHERE
                DAY_ONLY(convertTimezone(CreatedDate)) >=: request.inicio //PLV-5176 INICIO/FIM
                AND DAY_ONLY(convertTimezone(CreatedDate)) <=: request.fim //PLV-5176 INICIO/FIM
                AND RamoSeguro__r.Codigo__c in: request.ramos
            	AND Tipo__c != 'Renovacao'
                AND Produto__r.ProductCode IN: request.produto //II-159 INICIO-FIM
                AND Status != 'Em criação' //ANNVI-257 - INICIO/FIM
        ];

        System.debug('lstPropostas pre filtro ' + lstPropostas.size());

        for (Integer i = lstPropostas.size() - 1; i >= 0; i--) {
            Boolean propostaHasNotInformedGarantia = lstPropostas[i].GarantiasProposta__r == null || lstPropostas[i].GarantiasProposta__r.size() == 0;

            if(propostaHasNotInformedGarantia) lstPropostas.remove(i);
        }

        System.debug('lstPropostas pos filtro ' + lstPropostas.size());

        return lstPropostas;
    }

    public static Map<ID, SeguradoProposta__c> getSegurados(List<Quote> lstQuotes){
        Set<ID> lstIdsProposta = (new Map<Id,Quote>(lstQuotes)).keySet();

        List<SeguradoProposta__c> lstSegurado = [
            SELECT 
                ID,
                GrupoProposta__r.ContratanteProposta__r.Proposta__c,
                Conta__r.Name,                  // nome
                Conta__r.Cpf__c,                // cpfnumero, cpfdigito
                Conta__r.Sexo__c,               // sexo
                Conta__r.PersonBirthdate,       // datanascimento
                Conta__r.PersonEmail,           // email            //PLV- 5068 - FIX02 - INICIO/FIM
                Conta__r.Rne__c,                // npasrne
                Conta__r.PersonHomePhone,       // ddd, // telefone
                CepResidencial__c,              // cepzonapostal, cepsufixo
                CidadeResidencial__c,           // cidade
                UFResidencial__c,               // uf
                ComplementoResidencial__c,      // complementoendereco
                BairroResidencial__c,           // bairro
                LogradouroResidencial__c,       // logradouro
                numeroResidencial__c,           // numerocasa       //II-159 INICIO-FIM 
                Conta__r.Renda__c,              //II-159 INICIO-FIM
                Conta__r.Profissao__r.Name,     //II-159 INICIO-FIM
                CicloVacinal__c                 //II-159 INICIO-FIM     
            FROM SeguradoProposta__c
            WHERE GrupoProposta__r.ContratanteProposta__r.Proposta__c IN: lstIdsProposta
        ];

        Map<ID, SeguradoProposta__c> response = new Map<ID, SeguradoProposta__c>();

        for (SeguradoProposta__c segurado : lstSegurado) response.put(segurado.GrupoProposta__r.ContratanteProposta__r.Proposta__c, segurado);
       
        return response;
    }

    public static Map<Id, List<FavorecidoRemuneracaoProposta__c>> getCorretores(List<Quote> lstQuotes){
        Set<ID> lstIdsProposta = (new Map<Id,Quote>(lstQuotes)).keySet();
        List<FavorecidoRemuneracaoProposta__c> lstCorretores = [
            SELECT 
                ID,
                RemuneracaoProposta__r.Proposta__c,
                RemuneracaoProposta__r.TipoRemuneracao__r.Name,
                Susep__c,                                   // susep
                CorretorLider__c                            // flagsuseplider
            FROM FavorecidoRemuneracaoProposta__c
            WHERE RemuneracaoProposta__r.Proposta__c IN: lstIdsProposta
            AND RemuneracaoProposta__r.TipoRemuneracao__r.Name = 'CORRETAGEM'
        ];

        Map<Id, List<FavorecidoRemuneracaoProposta__c>> response = new Map<Id, List<FavorecidoRemuneracaoProposta__c>>();

        for(FavorecidoRemuneracaoProposta__c corretor : lstCorretores){
            if(!response.containsKey(corretor.RemuneracaoProposta__r.Proposta__c)){
                response.put(corretor.RemuneracaoProposta__r.Proposta__c, new List<FavorecidoRemuneracaoProposta__c>());
            }
            response.get(corretor.RemuneracaoProposta__r.Proposta__c).add(corretor); 
        }           
                
        return response;
    }
}