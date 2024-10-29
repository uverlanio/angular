/************************************************************************
 *
 *  Classe responsável por formatar o campo número da sorte para se adequar ao padrão
 *  @Author Felipe Reinaux 02/02/2021
 *
 ************************************************************************/

//Inicio ST-2021-00012
public with sharing class StringHelper {
    public static String FormatNumeroSorte(String oldNumSorte) {        
        return oldNumSorte.leftPad(7, '0');
    }

}
//Fim ST-2021-00012