/*
    Class: Classe utilizada para receber informações de uma pessoa física ou jurídica pelo código da pessoa(pesCod) ou pelo nº do documento(CPF/CNPJ)    
    Author: Uverlanio Mauricio
    Date: 09/09/2024
    Histrória origem: ANNVI-208
*/
//ANNVI-208 - INICIO
public with sharing class ConsultarDadosPessoaBCP {

    public static final ConsultarDadosPessoaBCP instance = new ConsultarDadosPessoaBCP();

    public String numDocumento {get; set;}
    public Boolean obterVinculoCorretora {get; set;}
    public String pesCod {get; set;}

    public static ConsultarDadosPessoaBCP getInstance() {
        return instance;
    }

    public void setParams(String numDocumento, Boolean obterVinculoCorretora, String pesCod){
        
        this.numDocumento = numDocumento;
        this.obterVinculoCorretora = obterVinculoCorretora;
        this.pesCod = pesCod;
    }

    public class ConsltDadPesBCPResponse{

        public String codigoPapel                      {get; set;}
        public String dataNascimento                   {get; set;}
        public List<Email> emails                      {get; set;}
        public List<Endereco> enderecos                {get; set;}
        public Integer estadoCivil                     {get; set;}
        public String nome                             {get; set;}
        public String nomeMae                          {get; set;}
        public String nomePai                          {get; set;}
        public String nomePapel                        {get; set;}
        public String nomeSocial                       {get; set;}
        public String nomeTratamento                   {get; set;}
        public String numDocumento                     {get; set;}
        public Integer pescod                          {get; set;}
        public String sexo                             {get; set;}
        public List<Telefone> telefones                {get; set;}
        public String tipoDocumento                    {get; set;}
        public String tipoPessoa                       {get; set;}
        public String titularidadeDocumento            {get; set;}
        public List<VinculoCorretora> vinculoCorretora {get; set;}
    }

    public class Email {

        public String dataAtualizacaoEmail             {get; set;}
        public String email                            {get; set;}
        public Integer numseq                          {get; set;}
        public String tipoEmail                        {get; set;}
    }

    public class Endereco {

        public String bairro                           {get; set;}
        public String cep                              {get; set;}
        public String cidade                           {get; set;}
        public Integer codigoFinalidade                {get; set;}
        public String complemento                      {get; set;}
        public String cplcepnum                        {get; set;}
        public String descricaoFinalidade              {get; set;}
        public String latitude                         {get; set;}
        public String logradouro                       {get; set;}
        public String longitude                        {get; set;}
        public String numero                           {get; set;}
        public String pais                             {get; set;}
        public String tipoLogradouro                   {get; set;}
        public String uf                               {get; set;}
    }

    public class Telefone {

        public Integer codigo                          {get; set;}
        public Integer ddd                             {get; set;}
        public Integer ddi                             {get; set;}
        public Integer numero                          {get; set;}
        public Integer seqnum                          {get; set;}
        public String tipo                             {get; set;}
    }

    public class VinculoCorretora {

        public String codigoSusep                      {get; set;}
        public String fimRelacionamento                {get; set;}
        public String inicioRelacionamento             {get; set;}
        public Integer seqnum                              {get; set;}
    }
}
//ANNVI-208 - FIM