//PLV-4772-INICIO
/*
*  @author Squad Avanxo 
*  @Descrição: Classe com o corpo do payload para geração da proposta
*/
public class PropostaTO {
    
    public class DadosBancarios{
        public String agencia                                       {get; set;}
        public String banco                                         {get; set;}
        public String conta                                         {get; set;}
        public String digitoAgencia                                 {get; set;}
        public String digitoConta                                   {get; set;}
        public String tipoPessoa                                    {get; set;}
        public String cpf                                           {get; set;}
    }

    public class DadosCartaoCredito{
        public boolean cartaoPorto                                  {get; set;}
        public String cvv                                           {get; set;}
        public String nome                                          {get; set;}
        public String numero                                        {get; set;}
        public String validade                                      {get; set;}
        public String ticket                                      {get; set;}
    }

    public class DadosPessoaFisica{
        public String grupoProfissao                                {get; set;}
        public String numeroCpf                                     {get; set;}
        public String profissao                                     {get; set;}
        public String sexo                                          {get; set;}
        public boolean fumante                                      {get; set;}
        public String digitoCpf                                     {get; set;}
        public String dataNascimento                                 {get; set;}
        public String regimeTrabalho                                {get; set;}
        public String estadoCivil                                   {get; set;}
        public String nacionalidade                                 {get; set;}
        public String paisDeOrigem                                  {get; set;} //PLV-5231 INICIO/FIM
        public String tipoDocIdentificacao                          {get; set;}
        public String docIdentificacao                              {get; set;}
        public String orgaoExpedidor                                {get; set;}
        public String dataExpedicao                                 {get; set;}
        public integer idade                                        {get; set;}
        public String paisResidente                                 {get; set;}
        public boolean resideBrasil                                 {get; set;}
    }
    public class Telefone{
        public String tipoTelefone                                  {get; set;}
        public String numeroTelefone                                {get; set;}
        public String dddTelefone                                   {get; set;}
    }
    public class Endereco{
        public String tipoEndereco                                  {get; set;}
        public String logradouro                                    {get; set;}
        public String numeroLogradouro                              {get; set;}
        public String bairro                                        {get; set;}
        public String cidade                                        {get; set;}
        public String uf                                            {get; set;}
        public String cep                                           {get; set;}
        public String complemento                                   {get; set;}
        public String complementoCep                                {get; set;}
    }
    public class Pessoa{
        public String tipo                                   {get; set;}
        public String rendaMensal                                   {get; set;}
        public String dadosPessoaJuridica                           {get; set;}
        public String nome                                          {get; set;}
        public DadosPessoaFisica dadosPessoaFisica                  {get; set;}
        public List<Telefone> telefones                             {get; set;}
        public List<Endereco> enderecos                             {get; set;}
        public String melhorPeriodo                                 {get; set;}
        public String pessoaExpostaPoliticamente                    {get; set;}
        public String email                                         {get; set;}
    }

    public class PessoaContratoOriginal{
        public String tipo                                   {get; set;}
        public Integer rendaMensal                                   {get; set;}
        public String dadosPessoaJuridica                           {get; set;}
        public String nome                                          {get; set;}
        public DadosPessoaFisica dadosPessoaFisica                  {get; set;}
        public List<Telefone> telefones                             {get; set;}
        public List<Endereco> enderecos                             {get; set;}
        public String melhorPeriodo                                 {get; set;}
        public String pessoaExpostaPoliticamente                    {get; set;}
        public String email                                         {get; set;}
    }
    //PLV - 5170 INICIO
    public class Cobertura{
        public String franquia                                      {get; set;}
        public String sigla                                         {get; set;}
        public String moeda                                         {get; set;}
        public String cotacaoMoeda                                  {get; set;}
        public Decimal valor                                        {get; set;} 
        public Integer quantidade                                   {get; set;}
        public String cobrado                                       {get; set;}
        public Decimal iof                                          {get; set;}
        public List<DescontoAgravo> descontoAgravo                  {get; set;}
        public Premio premioPago                                    {get; set;}
        public Premio premio                                        {get; set;}
        public Decimal capitalContratacao                           {get; set;}
        public Taxa taxa                                            {get; set;}
    }
    //PLV - 5170 FIM
    public class Beneficiario{
        public String nome                                          {get; set;}
        public String cpf                                           {get; set;}
        public String nascimento                                    {get; set;}
        public String grauParentesco                                {get; set;}
        public String grauParentescoOutros                          {get; set;} //PLV-5231 INICIO/FIM
        public integer percentualIndenizacao                        {get; set;}
        public String sexoBeneficiario                              {get; set;}
        public String tipoBeneficiario                              {get; set;}
        public boolean imprimirCertificado                          {get; set;}
        public integer participacao                                 {get; set;}
    }
    public class Questionario{
        public String idquestionario                                {get; set;}
        public List<Resposta> respostas                               {get; set;}
    }

    public class Resposta {
        public String questao                                       {get; set;}
        public String resposta                                      {get; set;}
    }

    public class Segurado{
        public Pessoa pessoa                                        {get; set;}
        public integer numero                                       {get; set;}
        public List<Cobertura> coberturas                           {get; set;}
        public String empresaQueTrabalha                            {get; set;}
        public String ramoAtividade                                 {get; set;}
        public String ocupacaoProfissionalPrincipal                 {get; set;}   
        public String faixaRenda                                    {get; set;}
        public String formaTrabalho                                 {get; set;}
        public List<Beneficiario> beneficiarios                     {get; set;}
        public boolean responsavelFinanceiro                        {get; set;}
        public Questionario questionario                            {get; set;}
        public decimal iof                                           {get; set;}
        public List<DescontoAgravo> descontoAgravo                  {get; set;}   
        public Premio premio                                        {get; set;}
    }       
    public class Grupos{
        public String tarifa                                        {get; set;}
        public String tipoCalculo                                   {get; set;}
        public integer numero                                       {get; set;}
        public List<Segurado> segurados                             {get; set;}
        public String nome                                          {get; set;}
        public double qtdeVidas                                     {get; set;} //PLV-4803-FIX - INICIO/FIM
        public decimal iof                                           {get; set;}
        public List<DescontoAgravo> descontoAgravo                  {get; set;}
        public Premio premio                                        {get; set;} //PLV-4803-FIX - INICIO/FIM
    }
    public class PlanoParcelamento{
        public String idPlanoParcelamento                           {get; set;}
        public integer quantidadeParcelas                           {get; set;}
    }
    public class FormaPagamento{
        public integer codigo                                       {get; set;}
        public String descricao                                     {get; set;}
        public String idFormaPagamento                              {get; set;}
        public PlanoParcelamento planoParcelamento                  {get; set;}
    }
    public class DadosPagamento{
        public integer opcao                                        {get; set;}
        public integer codigoFormaPagamento                         {get; set;}
        public integer quantidadeParcelas                           {get; set;}
        public String cartaoCredito                                 {get; set;}
        public FormaPagamento formaPagamento                        {get; set;}
        public String responsavelPagamento                          {get; set;}
        public String tipoResponsavelPagamento                      {get; set;}
        public String vencimentoDemaisParcelas                      {get; set;}
        public String vigenciaInicial                               {get; set;}
        public String vencimentoPrimeiraParcela                     {get; set;}
        public DadosBancarios dadosBancarios                        {get; set;}
        public DadosCartaoCredito dadosCartaoCredito                {get; set;}
        
    }
    public class Contratante{
        public String tipo                                          {get; set;}
        public integer numero                                       {get; set;}
        public List<Grupos> grupos                                  {get; set;}
        public Pessoa pessoa                                        {get; set;}
        public DadosPagamento dadosPagamento                        {get; set;}
        public decimal iof                                           {get; set;}
        public List<DescontoAgravo> descontoAgravo                  {get; set;}
        public Premio premio                                        {get; set;}
    }
    public class Favorecido{
        public String papel                                         {get; set;}
        public decimal participacao                                 {get; set;}
        public boolean corretorLider                                {get; set;}
        public String susep                                         {get; set;}
        public Pessoa pessoa                                        {get; set;}
        public boolean antecipaComissao                             {get; set;}
        public boolean antecipacaoComissao                          {get; set;}
    }
    public class Remuneracao{
        public decimal percentual                                   {get; set;}       
        public String tipoRemuneracao                               {get; set;}       
        public List<Favorecido> favorecidos                         {get; set;}       
    }           
    //PLV - 5170 INICIO
    public class DescontoAgravo{
        public String tipo                                          {get; set;}
        public Decimal percentual                                   {get; set;}
        public Decimal monetario                                    {get; set;}
       
    }
    //PLV - 5170 FIM
    public class Premio{
        public decimal comercial                                     {get; set;}
        public decimal total                                         {get; set;}
        public decimal puro                                          {get; set;}
        public decimal premioPago                                    {get; set;}
 
    }
    // PLV - 5170 INICIO
    public class Taxa{
        public Decimal pura                                         {get; set;}
        public Decimal comercial                                    {get; set;}
        public Decimal total                                        {get; set;}
    }
    // PLV - 5170 FIM
    public class Precificacao{
        public integer encargos                                     {get; set;}
        public Decimal iof                                          {get; set;} //PLV - 5170 INICIO/FIM
        public List<DescontoAgravo> descontoAgravo                  {get; set;}
        public Premio premio                                        {get; set;}
        public integer custoDeApolice                               {get; set;}
        public integer juros                                        {get; set;}
        public List<Cobertura> coberturas                           {get; set;}
        public List<Contratante> contratantes                       {get; set;}
    }
    public class VersoesCalculo{
        public integer opcao                                        {get; set;}
        public String tipo                                          {get; set;}
        public integer descontoAgravo                               {get; set;}
    }
    public class ItensCotacao{
        public String moedaDestino                                  {get; set;}
        public integer dataCotacao                                  {get; set;}
        public String moedaOrigem                                   {get; set;}
        public String cotacao                                       {get; set;}
    }
    public class IndiceMonetario{       
        public List<ItensCotacao> ItensCotacao                      {get; set;}//PLV-4666 - INICIO/FIM - PEDRO BRAZ
    }
    public class ResultadoIntegracoes{       
        public IndiceMonetario IndiceMonetario                      {get; set;}//PLV-4666 - INICIO/FIM - PEDRO BRAZ
    }
    public class ContratoOriginal{
        public Precificacao precificacao                            {get; set;}
        public String vigenciaFinal                                 {get; set;}
        public integer numeroOrcamento                              {get; set;}
        public String ramo                                          {get; set;}
        public String endosso                                       {get; set;}
        public String codigoProdutoVida                             {get; set;}
        public List<Contratante> contratantes                       {get; set;}
        public String apolice                                       {get; set;}
        public String sucursal                                      {get; set;}
        public List<VersoesCalculo> versoesCalculos                 {get; set;}
        public ResultadoIntegracoes resultadoIntegracoes            {get; set;}
        public String empresa                                       {get; set;}
        public List<Remuneracao> remuneracoes                        {get; set;}
        public String vigenciaInicial                               {get; set;}
        public String  validadePagamento                            {get; set;} // VIAG-141 INICIO-FIM
        public String  voucherPdfDownloadUrl                        {get; set;} // MGRC-624 INICIO-FIM

    }   
    public class Proposta{
        public integer indice                                       {get; set;}
        public integer codigoEmpresa                                {get; set;}
        public String numeroOrcamento                               {get; set;}
        public String numeroPortal                                  {get; set;}
        public integer origem                                       {get; set;}
        public integer ramoSeguro                                   {get; set;}
        public String tipoSeguro                                    {get; set;}
        public String entradaNegocio                                {get; set;}
        public String dataProtocolo                                 {get; set;}
        public String meioComercializacao                           {get; set;}
        public String codigoProdutoVida                             {get; set;}
        public List<Contratante> contratantes                       {get; set;}
        public String canalDistribuicao                             {get; set;}
        public List<Remuneracao> remuneracoes                        {get; set;}
        public String segmento                                      {get; set;}
        public String tempoRendaProtegida                           {get; set;}
        public boolean dependentesFinanceiros                       {get; set;}
        public String formaReceberApolice                           {get; set;}
        public boolean termoGuarda                                  {get; set;}
        public boolean termoResponsabilidade                        {get; set;}
        public boolean assinaturaEletronica                         {get; set;}
        public ContratoOriginal contratoOriginal                    {get; set;}
        
    }

    public class Root{
        public List<Proposta> propostas                             {get; set;}
        public Root(){
            this.Propostas = new List<Proposta>();
        }
    }

}
//PLV-4772-FIM