//PLV-4772-INICIO
/*
*  @author Squad Avanxo 
*  @Descrição: Classe de teste da PropostaTO
*/
@isTest
public class PropostaTOTest {
    @isTest
	private static void gerarPropostaTO() {
        PropostaTO.Root root = new PropostaTO.Root();
        PropostaTO.Proposta proposta = new PropostaTO.Proposta();
        proposta.indice = 1;
        proposta.codigoEmpresa = 1;
        proposta.numeroOrcamento = '';
        proposta.numeroPortal= '';
        proposta.origem = 1;
        proposta.ramoSeguro = 1;
        proposta.tipoSeguro = '';
        proposta.entradaNegocio = '';
        proposta.dataProtocolo = '';
        proposta.meioComercializacao = '';
        proposta.codigoProdutoVida = '';
        proposta.canalDistribuicao = '';
        proposta.segmento = '';
        proposta.tempoRendaProtegida = '';
        proposta.dependentesFinanceiros = false;
        proposta.formaReceberApolice = '';
        proposta.termoGuarda = false;
        proposta.termoResponsabilidade = false;
        proposta.assinaturaEletronica = false;

        PropostaTO.ContratoOriginal contratoOriginal = new PropostaTO.ContratoOriginal();                 
        contratoOriginal.vigenciaFinal = '';                      
        contratoOriginal.numeroOrcamento = 0;                   
        contratoOriginal.ramo = '';                               
        contratoOriginal.endosso = '';                            
        contratoOriginal.codigoProdutoVida = '';            
        contratoOriginal.apolice = '';                            
        contratoOriginal.sucursal = ''; 
        contratoOriginal.empresa = '';           
        contratoOriginal.vigenciaInicial = '';

        PropostaTO.ItensCotacao itensCotacao = new PropostaTO.ItensCotacao();
        itensCotacao.moedaDestino = '';
        itensCotacao.dataCotacao = 1;
        itensCotacao.moedaOrigem = ''; 
        itensCotacao.cotacao  = '';

        PropostaTO.VersoesCalculo versoesCalculo = new PropostaTO.VersoesCalculo();
        versoesCalculo.opcao = 0;          
        versoesCalculo.tipo = '';            
        versoesCalculo.descontoAgravo = 0; 

        PropostaTO.Precificacao precificacao = new PropostaTO.Precificacao();
        precificacao.encargos = 0;       
        precificacao.iof = 0.0;         
        precificacao.custoDeApolice = 0; 
        precificacao.juros = 0;

        PropostaTO.Favorecido favorecido = new PropostaTO.Favorecido();
        favorecido.papel = '';               
        favorecido.participacao = 0.0;       
        favorecido.corretorLider = false;      
        favorecido.susep = '';             
        favorecido.antecipaComissao = false;   
        favorecido.antecipacaoComissao = false;
        
        PropostaTO.Remuneracao remuneracao = new PropostaTO.Remuneracao();
        remuneracao.percentual = 0.0;                 
        remuneracao.tipoRemuneracao = '';       
                  
        PropostaTO.DescontoAgravo descontoAgravo = new PropostaTO.DescontoAgravo();
        descontoAgravo.tipo = '';       
        descontoAgravo.percentual = 0;
        descontoAgravo.monetario = 0; 
        
        PropostaTO.Premio premio = new PropostaTO.Premio();
        premio.comercial = 0.0; 
        premio.total = 0.0;     
        premio.puro = 0.0;      
        premio.premioPago = 0.0;
        
        PropostaTO.Taxa taxa = new PropostaTO.Taxa();
        taxa.pura = 0;     
        taxa.comercial = 0;
        taxa.total = 0;    
        
        PropostaTO.Cobertura cobertura = new PropostaTO.Cobertura();
        cobertura.franquia = '';           
        cobertura.sigla = '';              
        cobertura.moeda = '';              
        cobertura.cotacaoMoeda = '';       
        cobertura.valor = 0;             
        cobertura.quantidade = 0;        
        cobertura.cobrado = '';            
        cobertura.iof = 0.0;               
        cobertura.capitalContratacao = 0.0;
        cobertura.descontoAgravo = new List<PropostaTO.DescontoAgravo>();
        cobertura.premioPago =  new PropostaTO.Premio();                 
        cobertura.premio  =  new PropostaTO.Premio();
        cobertura.taxa = new PropostaTo.Taxa();                     
        
        PropostaTO.Beneficiario beneficiario = new PropostaTO.Beneficiario();
        beneficiario.nome = '';                   
        beneficiario.cpf = '';                    
        beneficiario.nascimento = '';             
        beneficiario.grauParentesco = '';
        beneficiario.grauParentescoOutros = ''; //PLV-5231 INICIO/FIM        
        beneficiario.percentualIndenizacao = 0; 
        beneficiario.sexoBeneficiario = '';       
        beneficiario.tipoBeneficiario = '';       
        beneficiario.imprimirCertificado = false;   
        beneficiario.participacao = 0;          
        
        PropostaTO.Questionario questionario = new PropostaTO.Questionario();
        questionario.idquestionario = '';
        questionario.respostas = new list<PropostaTO.Resposta>();
        
        PropostaTO.Segurado segurado = new PropostaTO.Segurado();
        segurado.pessoa = new PropostaTo.Pessoa();
        segurado.numero = 0;   
        segurado.coberturas = new List<PropostaTo.cobertura>();                    
        segurado.empresaQueTrabalha = '';            
        segurado.ramoAtividade = '';                 
        segurado.ocupacaoProfissionalPrincipal = '';  
        segurado.faixaRenda = '';                    
        segurado.formaTrabalho = ''; 
        segurado.beneficiarios = new List<PropostaTo.Beneficiario>();                
        segurado.responsavelFinanceiro= false; 
        segurado.questionario = new PropostaTO.Questionario();       
        segurado.iof = 0.0;
        segurado.premio  =  new PropostaTO.Premio();
        segurado.descontoAgravo = new List<PropostaTO.DescontoAgravo>();                          
             
        PropostaTO.Grupos grupos = new PropostaTO.Grupos();
        grupos.tarifa  = '';    
        grupos.tipoCalculo = '';
        grupos.numero = 0;    
        grupos.nome = '';       
        grupos.qtdeVidas = 0; 
        grupos.iof = 0.0;
        grupos.segurados = new List<PropostaTO.Segurado>();
        grupos.premio  =  new PropostaTO.Premio();
        grupos.descontoAgravo = new List<PropostaTO.DescontoAgravo>();        
        
        PropostaTO.PlanoParcelamento planoParcelamento = new PropostaTO.PlanoParcelamento();
        planoParcelamento.idPlanoParcelamento = '';
        planoParcelamento.quantidadeParcelas = 0;
        
        PropostaTO.FormaPagamento formaPagamento = new PropostaTO.FormaPagamento();
        formaPagamento.codigo = 0;         
        formaPagamento.descricao = '';       
        formaPagamento.idFormaPagamento = '';
        
        PropostaTO.DadosPagamento dadosPagamento = new PropostaTO.DadosPagamento();
        dadosPagamento.opcao = 0;                    
        dadosPagamento.codigoFormaPagamento = 0;     
        dadosPagamento.quantidadeParcelas = 0;       
        dadosPagamento.cartaoCredito = '';            
        dadosPagamento.dadosBancarios = new PropostaTO.DadosBancarios();           
        dadosPagamento.responsavelPagamento = '';     
        dadosPagamento.tipoResponsavelPagamento = ''; 
        dadosPagamento.vencimentoDemaisParcelas = ''; 
        dadosPagamento.vigenciaInicial = '';          
        dadosPagamento.vencimentoPrimeiraParcela = '';
            
        
        PropostaTO.Contratante contratante = new PropostaTO.Contratante();
        contratante.tipo = '';   
        contratante.numero = 0;
        contratante.iof = 0.0;
        contratante.dadosPagamento = new PropostaTO.DadosPagamento();
        contratante.grupos = new List<PropostaTO.Grupos>();
        contratante.premio  =  new PropostaTO.Premio();
        contratante.descontoAgravo = new List<PropostaTO.DescontoAgravo>(); 
        contratante.pessoa = new PropostaTo.Pessoa();   
        
        PropostaTO.DadosPessoaFisica dadosPessoaFisica = new PropostaTO.DadosPessoaFisica();
        dadosPessoaFisica.grupoProfissao = '';     
        dadosPessoaFisica.numeroCpf = '';           
        dadosPessoaFisica.profissao  = '';          
        dadosPessoaFisica.sexo = '';                
        dadosPessoaFisica.fumante = false;            
        dadosPessoaFisica.digitoCpf = '';           
        dadosPessoaFisica.dataNascimento = '';      
        dadosPessoaFisica.regimeTrabalho = '';      
        dadosPessoaFisica.estadoCivil = '';         
        dadosPessoaFisica.nacionalidade = '';       
        dadosPessoaFisica.tipoDocIdentificacao = '';
        dadosPessoaFisica.docIdentificacao = '';    
        dadosPessoaFisica.orgaoExpedidor = '';      
        dadosPessoaFisica.dataExpedicao = '';       
        dadosPessoaFisica.idade = 0;              
        dadosPessoaFisica.paisResidente = '';       
        dadosPessoaFisica.resideBrasil = false;       
        
        PropostaTO.Telefone telefone = new PropostaTO.Telefone();
        telefone.tipoTelefone   = '';
        telefone.numeroTelefone = '';
        telefone.dddTelefone    = '';
        
        PropostaTO.Endereco endereco = new PropostaTO.Endereco();
        endereco.tipoEndereco      = '';
        endereco.logradouro        = '';
        endereco.numeroLogradouro  = '';
        endereco.bairro            = '';
        endereco.cidade            = '';
        endereco.uf                = '';
        endereco.cep               = '';
        endereco.complemento       = '';
        endereco.complementoCep    = '';
        
        PropostaTO.Pessoa pessoa = new PropostaTO.Pessoa();
        pessoa.tipo                          = '';
        pessoa.rendaMensal                   = '';
        pessoa.dadosPessoaJuridica           = '';
        pessoa.nome                          = '';
        pessoa.melhorPeriodo                 = '';
        pessoa.pessoaExpostaPoliticamente    = '';
        pessoa.email                         = '';
        pessoa.dadosPessoaFisica = new PropostaTO.DadosPessoaFisica();
        pessoa.telefones = new List<PropostaTO.Telefone>();           
        pessoa.enderecos = new List<PropostaTO.Endereco>();          
        
    
        PropostaTO.PessoaContratoOriginal pessoaContratoOriginal = new PropostaTO.PessoaContratoOriginal();
        pessoaContratoOriginal.tipo                          = '';
        pessoaContratoOriginal.rendaMensal                  = 0;
        pessoaContratoOriginal.dadosPessoaJuridica           = '';
        pessoaContratoOriginal.nome                          = '';
        pessoaContratoOriginal.melhorPeriodo                 = '';
        pessoaContratoOriginal.pessoaExpostaPoliticamente    = '';
        pessoaContratoOriginal.email                         = '';
        pessoaContratoOriginal.dadosPessoaFisica = new PropostaTO.DadosPessoaFisica();
        pessoaContratoOriginal.telefones = new List<PropostaTO.Telefone>();           
        pessoaContratoOriginal.enderecos = new List<PropostaTO.Endereco>();  

    }
}
//PLV-4772-FIM