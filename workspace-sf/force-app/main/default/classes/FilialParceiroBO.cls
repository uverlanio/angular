/**
 * Proposta REST
 * @author Lucas Biffi @ 15/04/2019
 *
 **/
public with sharing class FilialParceiroBO 
{
    private static final FilialParceiroBO instancia = new FilialParceiroBO();    
    private FilialParceiroDAO dao = FilialParceiroDAO.getInstance();
    public static FilialParceiroBO getInstance() { return instancia; }

    /*
  	 * @author Everymind - Sprint 26
  	 * @Descrição: metodo para verificar duplicidade no Código Filial Parceiro
 	*/

    public void impedirFilialDuplicada(List<FilialParceiro__c> lstNovasFiliais)
    {
        Map<String, List<FilialParceiro__c>> mapFilaisParceiro = new Map<String, List<FilialParceiro__c>>();
        List<FilialParceiro__c> filiaisParceiro;
        Set<String> setParceiros = new Set<String>();
        List<FilialParceiro__c> filiaisOld;

        for(FilialParceiro__c filial : lstNovasFiliais)
        {
            if(!setParceiros.contains(String.valueOf(filial.Parceiro__c)))
            {
                setParceiros.add(String.valueOf(filial.Parceiro__c));
            }
        }

        for(String parceiro : setParceiros)
        {
            filiaisParceiro = new List<FilialParceiro__c>();
            for(FilialParceiro__c filial : lstNovasFiliais)
            {
                if(filial.Parceiro__c == parceiro)
                    filiaisParceiro.add(filial);
            }

            mapFilaisParceiro.put(parceiro, filiaisParceiro);
        }


        // Obter as filiais por parceiro
        filiaisOld = dao.buscarFiliaisPorParceiro(setParceiros);
        // Varrer filiais do já existentes
        for(FilialParceiro__c filialOld : filiaisOld)
        {
            for(FilialParceiro__c filialNew : mapFilaisParceiro.get(filialOld.Parceiro__c))
            {
                if(filialNew.CodigoFilialParceiro__c == filialOld.CodigoFilialParceiro__c)
                {
                     filialNew.addError('Código da filial já foi cadastrado.');
                }
            }
        }
    }
}