//PLV-5230 - INICIO

/*
/*  @author: Squad Globant 
/*  @description: Classe para integração OPIN (Open Insurance)
/*  @modifiedAt: 08/10/2021
/*/
public  class QueueableIntegracaoOpin implements Queueable, Database.AllowsCallouts { 

    final List<Product2> produtos;
    final Integer posicao;
    final Integer qtdeIntegracaoesPendentes;

    //Construtor
    public QueueableIntegracaoOpin(List<Product2> produtos, Integer posicao) {
        this.produtos = produtos;
        this.posicao = posicao;
        this.qtdeIntegracaoesPendentes = produtos.size() - posicao - 1;
    }

    public void execute(QueueableContext context) {

        try {

            if (qtdeIntegracaoesPendentes < 0) {
                throw new QueueableIntegracaoOpinException('Solicitação de integração OPIN inválida.');
            }

            //Seleciona o produto a ser integrado
            Product2 produto = produtos[posicao];

            //Executa a integração para o produto selecionado
            IntegracaoOpin.getInstance().executar(produto);

        }
        catch(Exception ex) {

            registraExecucaoComErro(ex);
		}	
        finally {
          
            finalizarExecucao();
        }

    }

    private void finalizarExecucao() {
        //Se necessário, enfileira próxima execução
        if (this.qtdeIntegracaoesPendentes > 0) {
            ProductBO.enfileirarProdutoOpin(produtos, posicao + 1);
        } 
       
    }
    private void registraExecucaoComErro(Exception ex) {
        
        System.debug(ex.getLineNumber() + ': ' + ex.getMessage());
        throw new QueueableIntegracaoOpinException(
                        ex.getLineNumber() + ': ' + ex.getMessage());
        
    }

    public class QueueableIntegracaoOpinException extends Exception{}

}
//PLV-5230 - FIM