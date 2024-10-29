// POR062-1 - INICIO
/*
 * ******************************************
 * Nome da classe: MovimentoSinistroTO
 * Descrição:
    • Responsável por documentar todos os códigos de movimentos jurídicos e administrativos de casos.
    • Servirá como suporte para documentação de descrição dos movimentos.
 * ******************************************
 */
public class MovimentoSinistroTO {
    private MovimentoSinistroTO() {}
	private static final MovimentoSinistroTO INSTANCIA = new MovimentoSinistroTO();

	public static MovimentoSinistroTO getInstance()
    {
		return INSTANCIA;
	}

    public static final MovimentoSinistroTO.Movimento AVISO_MAIS = new MovimentoSinistroTO.Movimento();                     /* 1 */
    public static final MovimentoSinistroTO.Movimento AC_AVISADO_MAIS = new MovimentoSinistroTO.Movimento();                /* 2 */
    public static final MovimentoSinistroTO.Movimento AC_AVISADO_MENOS = new MovimentoSinistroTO.Movimento();               /* 3 */
    public static final MovimentoSinistroTO.Movimento PAGAMENTO_PARCIAL_MAIS = new MovimentoSinistroTO.Movimento();         /* 4 */
    public static final MovimentoSinistroTO.Movimento ACERTO_PAGAMENTO_PARCIAL_MAIS = new MovimentoSinistroTO.Movimento();  /* 5 */
    public static final MovimentoSinistroTO.Movimento ACERTO_PAGAMENTO_PARCIAL_MENOS = new MovimentoSinistroTO.Movimento(); /* 6 */
    public static final MovimentoSinistroTO.Movimento PAGAMENTO_FINAL_MAIS = new MovimentoSinistroTO.Movimento();           /* 7 */
    public static final MovimentoSinistroTO.Movimento ACERTO_PAGAMENTO_FINAL_MAIS = new MovimentoSinistroTO.Movimento();    /* 8 */
    public static final MovimentoSinistroTO.Movimento ACERTO_PAGAMENTO_FINAL_MENOS = new MovimentoSinistroTO.Movimento();   /* 9 */
    public static final MovimentoSinistroTO.Movimento SALVADOS = new MovimentoSinistroTO.Movimento();                       /* 10 */
    public static final MovimentoSinistroTO.Movimento SALVADOS_COM_RESSARCIMENTO = new MovimentoSinistroTO.Movimento();     /* 11 */
    public static final MovimentoSinistroTO.Movimento RESSARCIMENTO_SEM_PERDA = new MovimentoSinistroTO.Movimento();        /* 13 */
    public static final MovimentoSinistroTO.Movimento RESSARCIMENTO_JURIDICO = new MovimentoSinistroTO.Movimento();         /* 14 */
    public static final MovimentoSinistroTO.Movimento DESPESAS_MAIS = new MovimentoSinistroTO.Movimento();                  /* 16 */
    public static final MovimentoSinistroTO.Movimento ACERTO_DESPESAS_MAIS = new MovimentoSinistroTO.Movimento();           /* 17 */
    public static final MovimentoSinistroTO.Movimento ACERTO_DESPESAS_MENOS = new MovimentoSinistroTO.Movimento();          /* 18 */
    public static final MovimentoSinistroTO.Movimento MOV_CALCULO = new MovimentoSinistroTO.Movimento();                    /* 22 */
    public static final MovimentoSinistroTO.Movimento ENCERRAMENTO_SEM_INDENIZACAO = new MovimentoSinistroTO.Movimento();   /* 24 */
    public static final MovimentoSinistroTO.Movimento REATIVACAO = new MovimentoSinistroTO.Movimento();                     /* 25 */
    public static final MovimentoSinistroTO.Movimento FURTO = new MovimentoSinistroTO.Movimento();                          /* 26 */
    public static final MovimentoSinistroTO.Movimento FURTO_COM_RESSARCIMENTO = new MovimentoSinistroTO.Movimento();        /* 27 */
    public static final MovimentoSinistroTO.Movimento ACERTO_AVISO_AUTOMATICO_MAIS = new MovimentoSinistroTO.Movimento();   /* 32 */
    public static final MovimentoSinistroTO.Movimento ACERTO_AVISO_AUTOMATICO_MENOS = new MovimentoSinistroTO.Movimento();  /* 33 */
    public static final MovimentoSinistroTO.Movimento ACERTO_JUROS_MAIS = new MovimentoSinistroTO.Movimento();              /* 52 */
    public static final MovimentoSinistroTO.Movimento ACERTO_JUROS_MENOS = new MovimentoSinistroTO.Movimento();             /* 53 */
    public static final MovimentoSinistroTO.Movimento ACERTO_CORRECAO_JUROS_MAIS = new MovimentoSinistroTO.Movimento();     /* 62 */
    public static final MovimentoSinistroTO.Movimento ACERTO_CORRECAO_JUROS_MENOS = new MovimentoSinistroTO.Movimento();    /* 63 */
    public static final MovimentoSinistroTO.Movimento MOV_ASSINALAR_FLAG_JURIDICA = new MovimentoSinistroTO.Movimento();    /* 99: Pula ações e assinala caso como juridico. */

    /* Mapa para recuperar informações dos movimentos pelo valor do movimento recebido da integração. */
    public static final Map<Decimal, MovimentoSinistroTO.Movimento> MAPA_MOV_POR_VALOR = new Map<Decimal, MovimentoSinistroTO.Movimento>();
    /* Conjuntos de movimentos por definição para validações. */
    public static final Set<MovimentoSinistroTO.Movimento> CONJ_MOV_REAJUSTE = new Set<MovimentoSinistroTO.Movimento>();
    public static final Set<MovimentoSinistroTO.Movimento> CONJ_MOV_VALOR_CAPITAL = new Set<MovimentoSinistroTO.Movimento>();
    public static final Set<MovimentoSinistroTO.Movimento> CONJ_MOV_FECHAMENTO_ADMINISTRATIVO = new Set<MovimentoSinistroTO.Movimento>();
    public static final Set<MovimentoSinistroTO.Movimento> CONJ_MOV_PAGAMENTOS_INDENIZACAO = new Set<MovimentoSinistroTO.Movimento>();
    public static final Set<MovimentoSinistroTO.Movimento> CONJ_MOV_STATUS_CANCELADO = new Set<MovimentoSinistroTO.Movimento>();
    public static final Set<MovimentoSinistroTO.Movimento> CONJ_MOV_DESPESA = new Set<MovimentoSinistroTO.Movimento>();
    public static final Set<MovimentoSinistroTO.Movimento> CONJ_MOV_JUROS = new Set<MovimentoSinistroTO.Movimento>();
    public static final Set<MovimentoSinistroTO.Movimento> CONJ_MOV_CORRECAO_MONETARIA = new Set<MovimentoSinistroTO.Movimento>();
    public static final Set<MovimentoSinistroTO.Movimento> CONJ_MOV_COMPLEMENTO = new Set<MovimentoSinistroTO.Movimento>();
    public static final Set<MovimentoSinistroTO.Movimento> CONJ_MOV_GERA_VALOR_CALCULADO = new Set<MovimentoSinistroTO.Movimento>();
    public static final Set<MovimentoSinistroTO.Movimento> CONJ_MOV_RECEBIDOS_SEM_VALOR = new Set<MovimentoSinistroTO.Movimento>();
    public static final Set<MovimentoSinistroTO.Movimento> CONJ_MOV_FECHAMENTO_JURIDICO = new Set<MovimentoSinistroTO.Movimento>();
    public static final Set<MovimentoSinistroTO.Movimento> CONJ_MOV_JURIDICO = new Set<MovimentoSinistroTO.Movimento>();
    
    public class Movimento {
        public String nome {
            get;
            set {
                if(this.nome != null) { throw new MovimentoSinistroTOException('O nome do movimento não pode ser modificado!'); }
                this.nome = value;
            }
        }
        public String descricao {
            get;
            set {
                if(this.descricao != null) { throw new MovimentoSinistroTOException('A descrição do movimento não pode ser modificada!'); }
                this.descricao = value;
            }
        }
        public String descricaoValor {
            get;
            set {
                if(this.descricaoValor != null) { throw new MovimentoSinistroTOException('A descrição valor do movimento não pode ser modificada!'); }
                this.descricaoValor = value;
            }
        }
        public Integer valor {
            get;
            set {
                if(this.valor != null) { throw new MovimentoSinistroTOException('O valor do movimento não pode ser modificado!'); }
                this.valor = value;
            }
        }
        public String tipo {
            get;
            set {
                if(this.tipo != null) { throw new MovimentoSinistroTOException('O tipo do movimento não pode ser modificado!'); }
                this.tipo = value;
            }
        }
        public String tipoComplemento {
            get;
            set {
                if(this.tipoComplemento != null) { throw new MovimentoSinistroTOException('O tipo do complemento não pode ser modificado!'); }
                this.tipoComplemento = value;
            }
        }
        public String flagEncerramentoJuridico {
            get;
            set {
                if(this.flagEncerramentoJuridico != null) { throw new MovimentoSinistroTOException('A flag de encerramento juridico do movimento não pode ser modificada!'); }
                this.flagEncerramentoJuridico = value;
            }
        }
        public Integer multiplicadorMaisMenos {
            /*
             * Este campo representa se o movimento é negativo ou positivo. Alguns movimentos que não são calculados
             * precisam ser apresentados como negativo ou positivo. Esse campo é utilizado para definir o valor do
             * movimento como negativo ou positivo, quando o movimento for criado.
             */
            get;
            set {
                if(this.multiplicadorMaisMenos != null) { throw new MovimentoSinistroTOException('Multiplicador do movimento não pode ser modificada!'); }
                this.multiplicadorMaisMenos = value;
            }
        }
    }

    static {
        /* Preenchimento dos valores individuais para cada movimento */
        MovimentoSinistroTO.AVISO_MAIS.nome = 'AVISO(+)';
        MovimentoSinistroTO.AVISO_MAIS.valor = 1;
        MovimentoSinistroTO.AVISO_MAIS.descricaoValor = String.valueOf(AVISO_MAIS.valor);
        MovimentoSinistroTO.AVISO_MAIS.descricao = 'AVISO(+)';
        MovimentoSinistroTO.AVISO_MAIS.tipo = 'Aviso';
        MovimentoSinistroTO.AVISO_MAIS.flagEncerramentoJuridico = 'Não';
        MovimentoSinistroTO.AVISO_MAIS.multiplicadorMaisMenos = 1;
        
        /* 2: AC. AVISADO + | Sinistro vai para Status = 'Em regulação' Status_Dependente__c = 'Judicial'; */
        MovimentoSinistroTO.AC_AVISADO_MAIS.nome = 'AC, AVISADO(+)';
        MovimentoSinistroTO.AC_AVISADO_MAIS.valor = 2;
        MovimentoSinistroTO.AC_AVISADO_MAIS.descricaoValor = String.valueOf(AC_AVISADO_MAIS.valor);
        MovimentoSinistroTO.AC_AVISADO_MAIS.descricao = 'AC, AVISADO(+)';
        MovimentoSinistroTO.AC_AVISADO_MAIS.tipo = 'Aviso';
        MovimentoSinistroTO.AC_AVISADO_MAIS.flagEncerramentoJuridico = 'Não';
        MovimentoSinistroTO.AC_AVISADO_MAIS.multiplicadorMaisMenos = 1;
        
        /* 3: AC. AVISADO - | Sinistro vai para Status = 'Em regulação' Status_Dependente__c = 'Judicial'; */
        MovimentoSinistroTO.AC_AVISADO_MENOS.nome = 'AC, AVISADO(-)';
        MovimentoSinistroTO.AC_AVISADO_MENOS.valor = 3;
        MovimentoSinistroTO.AC_AVISADO_MENOS.descricaoValor = String.valueOf(AC_AVISADO_MENOS.valor);
        MovimentoSinistroTO.AC_AVISADO_MENOS.descricao = 'AC, AVISADO(-)';
        MovimentoSinistroTO.AC_AVISADO_MENOS.tipo = 'Aviso';
        MovimentoSinistroTO.AC_AVISADO_MENOS.flagEncerramentoJuridico = 'Não';
        MovimentoSinistroTO.AC_AVISADO_MENOS.multiplicadorMaisMenos = -1;
        
        /* 4: PAGAMENTO PARCIAL + | Verifica se existe beneficiários, se sim, Sinistro vai para Status = 'Em regulação' Status_Dependente__c = 'Aguardando pagamento' */
        MovimentoSinistroTO.PAGAMENTO_PARCIAL_MAIS.nome = 'PAGAMENTO PARCIAL (+)';
        MovimentoSinistroTO.PAGAMENTO_PARCIAL_MAIS.valor = 4;
        MovimentoSinistroTO.PAGAMENTO_PARCIAL_MAIS.descricaoValor = String.valueOf(PAGAMENTO_PARCIAL_MAIS.valor);
        MovimentoSinistroTO.PAGAMENTO_PARCIAL_MAIS.descricao = 'PAGAMENTO PARCIAL (+)';
        MovimentoSinistroTO.PAGAMENTO_PARCIAL_MAIS.tipo = 'Pagamento';
        MovimentoSinistroTO.PAGAMENTO_PARCIAL_MAIS.flagEncerramentoJuridico = 'Não';
        MovimentoSinistroTO.PAGAMENTO_PARCIAL_MAIS.multiplicadorMaisMenos = 1;
        
        /* 5: ACERTO PGTO PARCIAL + | Sinistro vai para Status = 'Em regulação' Status_Dependente__c = 'Aguardando pagamento' */
        MovimentoSinistroTO.ACERTO_PAGAMENTO_PARCIAL_MAIS.nome = 'ACERTO PGTO PARCIAL (+)';
        MovimentoSinistroTO.ACERTO_PAGAMENTO_PARCIAL_MAIS.valor = 5;
        MovimentoSinistroTO.ACERTO_PAGAMENTO_PARCIAL_MAIS.descricaoValor = String.valueOf(ACERTO_PAGAMENTO_PARCIAL_MAIS.valor);
        MovimentoSinistroTO.ACERTO_PAGAMENTO_PARCIAL_MAIS.descricao = 'ACERTO PGTO PARCIAL (+)';
        MovimentoSinistroTO.ACERTO_PAGAMENTO_PARCIAL_MAIS.tipo = 'Aviso';
        MovimentoSinistroTO.ACERTO_PAGAMENTO_PARCIAL_MAIS.flagEncerramentoJuridico = 'Não';
        MovimentoSinistroTO.ACERTO_PAGAMENTO_PARCIAL_MAIS.multiplicadorMaisMenos = 1;
        
        /* 6: ACERTO PGTO PARCIAL - | Apenas geram os movimentos: ACERTO PGTO PARCIAL - */
        MovimentoSinistroTO.ACERTO_PAGAMENTO_PARCIAL_MENOS.nome = 'ACERTO PGTO PARCIAL (-)';
        MovimentoSinistroTO.ACERTO_PAGAMENTO_PARCIAL_MENOS.valor = 6;
        MovimentoSinistroTO.ACERTO_PAGAMENTO_PARCIAL_MENOS.descricaoValor = String.valueOf(ACERTO_PAGAMENTO_PARCIAL_MENOS.valor);
        MovimentoSinistroTO.ACERTO_PAGAMENTO_PARCIAL_MENOS.descricao = 'ACERTO PGTO PARCIAL (-)';
        MovimentoSinistroTO.ACERTO_PAGAMENTO_PARCIAL_MENOS.tipo = 'Aviso';
        MovimentoSinistroTO.ACERTO_PAGAMENTO_PARCIAL_MENOS.flagEncerramentoJuridico = 'Não';
        MovimentoSinistroTO.ACERTO_PAGAMENTO_PARCIAL_MENOS.multiplicadorMaisMenos = -1;
        
        /* 7: PAGAMENTO FINAL + | Apenas gera este movimento e as ações comuns */
        MovimentoSinistroTO.PAGAMENTO_FINAL_MAIS.nome = 'PAGAMENTO FINAL (+)';
        MovimentoSinistroTO.PAGAMENTO_FINAL_MAIS.valor = 7;
        MovimentoSinistroTO.PAGAMENTO_FINAL_MAIS.descricaoValor = String.valueOf(PAGAMENTO_FINAL_MAIS.valor);
        MovimentoSinistroTO.PAGAMENTO_FINAL_MAIS.descricao = 'PAGAMENTO FINAL (+)';
        MovimentoSinistroTO.PAGAMENTO_FINAL_MAIS.tipo = 'Pagamento'; //LECVP-318-INICIO/FIM-FIX01
        MovimentoSinistroTO.PAGAMENTO_FINAL_MAIS.flagEncerramentoJuridico = 'Sim';
        MovimentoSinistroTO.PAGAMENTO_FINAL_MAIS.multiplicadorMaisMenos = 1;
        
        MovimentoSinistroTO.ACERTO_PAGAMENTO_FINAL_MAIS.nome = 'ACERTO PGTO FINAL (+)';
        MovimentoSinistroTO.ACERTO_PAGAMENTO_FINAL_MAIS.valor = 8;
        MovimentoSinistroTO.ACERTO_PAGAMENTO_FINAL_MAIS.descricaoValor = String.valueOf(ACERTO_PAGAMENTO_FINAL_MAIS.valor);
        MovimentoSinistroTO.ACERTO_PAGAMENTO_FINAL_MAIS.descricao = 'ACERTO PGTO FINAL (+)';
        MovimentoSinistroTO.ACERTO_PAGAMENTO_FINAL_MAIS.tipo = 'Aviso';
        MovimentoSinistroTO.ACERTO_PAGAMENTO_FINAL_MAIS.flagEncerramentoJuridico = 'Não';
        MovimentoSinistroTO.ACERTO_PAGAMENTO_FINAL_MAIS.multiplicadorMaisMenos = 1;
        
        MovimentoSinistroTO.ACERTO_PAGAMENTO_FINAL_MENOS.nome = 'ACERTO PGTO FINAL (-)';
        MovimentoSinistroTO.ACERTO_PAGAMENTO_FINAL_MENOS.valor = 9;
        MovimentoSinistroTO.ACERTO_PAGAMENTO_FINAL_MENOS.descricaoValor = String.valueOf(ACERTO_PAGAMENTO_FINAL_MENOS.valor);
        MovimentoSinistroTO.ACERTO_PAGAMENTO_FINAL_MENOS.descricao = 'ACERTO PGTO FINAL (-)';
        MovimentoSinistroTO.ACERTO_PAGAMENTO_FINAL_MENOS.tipo = 'Aviso';
        MovimentoSinistroTO.ACERTO_PAGAMENTO_FINAL_MENOS.flagEncerramentoJuridico = 'Não';
        MovimentoSinistroTO.ACERTO_PAGAMENTO_FINAL_MENOS.multiplicadorMaisMenos = -1;
        
        MovimentoSinistroTO.SALVADOS.nome = 'SALVADOS';
        MovimentoSinistroTO.SALVADOS.valor = 10;
        MovimentoSinistroTO.SALVADOS.descricaoValor = String.valueOf(SALVADOS.valor);
        MovimentoSinistroTO.SALVADOS.descricao = 'SALVADOS';
        MovimentoSinistroTO.SALVADOS.tipo = 'Despesa';
        MovimentoSinistroTO.SALVADOS.flagEncerramentoJuridico = 'Não';
        MovimentoSinistroTO.SALVADOS.multiplicadorMaisMenos = 1;
        
        MovimentoSinistroTO.SALVADOS_COM_RESSARCIMENTO.nome = 'SALVADOS COM RESSARCIMENTO';
        MovimentoSinistroTO.SALVADOS_COM_RESSARCIMENTO.valor = 11;
        MovimentoSinistroTO.SALVADOS_COM_RESSARCIMENTO.descricaoValor = String.valueOf(SALVADOS_COM_RESSARCIMENTO.valor);
        MovimentoSinistroTO.SALVADOS_COM_RESSARCIMENTO.descricao = 'SALVADOS COM RESSARCIMENTO';
        MovimentoSinistroTO.SALVADOS_COM_RESSARCIMENTO.tipo = 'Despesa';
        MovimentoSinistroTO.SALVADOS_COM_RESSARCIMENTO.flagEncerramentoJuridico = 'Não';
        MovimentoSinistroTO.SALVADOS_COM_RESSARCIMENTO.multiplicadorMaisMenos = 1;
        
        MovimentoSinistroTO.RESSARCIMENTO_SEM_PERDA.nome = 'RESSARCIMENTO S/PERDA';
        MovimentoSinistroTO.RESSARCIMENTO_SEM_PERDA.valor = 13;
        MovimentoSinistroTO.RESSARCIMENTO_SEM_PERDA.descricaoValor = String.valueOf(RESSARCIMENTO_SEM_PERDA.valor);
        MovimentoSinistroTO.RESSARCIMENTO_SEM_PERDA.descricao = 'RESSARCIMENTO S/PERDA';
        MovimentoSinistroTO.RESSARCIMENTO_SEM_PERDA.tipo = 'Despesa';
        MovimentoSinistroTO.RESSARCIMENTO_SEM_PERDA.flagEncerramentoJuridico = 'Não';
        MovimentoSinistroTO.RESSARCIMENTO_SEM_PERDA.multiplicadorMaisMenos = 1;
        
        MovimentoSinistroTO.RESSARCIMENTO_JURIDICO.nome = 'RESSARCIMENTO - JURIDICO';
        MovimentoSinistroTO.RESSARCIMENTO_JURIDICO.valor = 14;
        MovimentoSinistroTO.RESSARCIMENTO_JURIDICO.descricaoValor = String.valueOf(RESSARCIMENTO_JURIDICO.valor);
        MovimentoSinistroTO.RESSARCIMENTO_JURIDICO.descricao = '';
        MovimentoSinistroTO.RESSARCIMENTO_JURIDICO.tipo = 'Ressarcimento';
        MovimentoSinistroTO.RESSARCIMENTO_JURIDICO.flagEncerramentoJuridico = 'Não';
        MovimentoSinistroTO.RESSARCIMENTO_JURIDICO.multiplicadorMaisMenos = 1;
        
        MovimentoSinistroTO.DESPESAS_MAIS.nome = 'DESPESAS (+)';
        MovimentoSinistroTO.DESPESAS_MAIS.valor = 16;
        MovimentoSinistroTO.DESPESAS_MAIS.descricaoValor = String.valueOf(DESPESAS_MAIS.valor);
        MovimentoSinistroTO.DESPESAS_MAIS.descricao = 'DESPESAS (+)';
        MovimentoSinistroTO.DESPESAS_MAIS.tipo = 'Despesa';
        MovimentoSinistroTO.DESPESAS_MAIS.flagEncerramentoJuridico = 'Não';
        MovimentoSinistroTO.DESPESAS_MAIS.multiplicadorMaisMenos = 1;
        
        MovimentoSinistroTO.ACERTO_DESPESAS_MAIS.nome = 'ACERTO DESPESAS (+)';
        MovimentoSinistroTO.ACERTO_DESPESAS_MAIS.valor = 17;
        MovimentoSinistroTO.ACERTO_DESPESAS_MAIS.descricaoValor = String.valueOf(ACERTO_DESPESAS_MAIS.valor);
        MovimentoSinistroTO.ACERTO_DESPESAS_MAIS.descricao = 'ACERTO DESPESAS (+)';
        MovimentoSinistroTO.ACERTO_DESPESAS_MAIS.tipo = 'Despesa';
        MovimentoSinistroTO.ACERTO_DESPESAS_MAIS.flagEncerramentoJuridico = 'Não';
        MovimentoSinistroTO.ACERTO_DESPESAS_MAIS.multiplicadorMaisMenos = 1;
        
        MovimentoSinistroTO.ACERTO_DESPESAS_MENOS.nome = 'ACERTO DESPESAS (-)';
        MovimentoSinistroTO.ACERTO_DESPESAS_MENOS.valor = 18;
        MovimentoSinistroTO.ACERTO_DESPESAS_MENOS.descricaoValor = String.valueOf(ACERTO_DESPESAS_MENOS.valor);
        MovimentoSinistroTO.ACERTO_DESPESAS_MENOS.descricao = 'ACERTO DESPESAS (-)';
        MovimentoSinistroTO.ACERTO_DESPESAS_MENOS.tipo = 'Despesa';
        MovimentoSinistroTO.ACERTO_DESPESAS_MENOS.flagEncerramentoJuridico = 'Não';
        MovimentoSinistroTO.ACERTO_DESPESAS_MENOS.multiplicadorMaisMenos = -1;
        
        /* 22: Gerar 25 de reativação e gera movimento de mais(2 AC. AVISADO +) ou menos(3 AC. AVISADO -) de acordo com o valor request.valor */
        MovimentoSinistroTO.MOV_CALCULO.nome = 'MOVIMENTO DE CÁLCULO';
        MovimentoSinistroTO.MOV_CALCULO.valor = 22;
        MovimentoSinistroTO.MOV_CALCULO.descricaoValor = String.valueOf(MOV_CALCULO.valor);
        MovimentoSinistroTO.MOV_CALCULO.descricao = 'MOVIMENTO DE CÁLCULO';
        MovimentoSinistroTO.MOV_CALCULO.flagEncerramentoJuridico = 'Não';
        
        /* 24: ENC. SEM INDENIZACAO - | Sinistro vai para Status = 'Fechado' Status_Dependente__c = 'Cancelado' Motivos_de_recusa__c = 'JUDICIAL' */
        MovimentoSinistroTO.ENCERRAMENTO_SEM_INDENIZACAO.nome = 'ENC, SEM INDENIZAÇÃO (-)';
        MovimentoSinistroTO.ENCERRAMENTO_SEM_INDENIZACAO.valor = 24;
        MovimentoSinistroTO.ENCERRAMENTO_SEM_INDENIZACAO.descricaoValor = String.valueOf(ENCERRAMENTO_SEM_INDENIZACAO.valor);
        MovimentoSinistroTO.ENCERRAMENTO_SEM_INDENIZACAO.descricao = 'ENC, SEM INDENIZACAO (-)';
        MovimentoSinistroTO.ENCERRAMENTO_SEM_INDENIZACAO.tipo = 'Aviso';
        MovimentoSinistroTO.ENCERRAMENTO_SEM_INDENIZACAO.flagEncerramentoJuridico = 'Sim';
        MovimentoSinistroTO.ENCERRAMENTO_SEM_INDENIZACAO.multiplicadorMaisMenos = -1;
        
        /* 25: 25 de reativação */
        MovimentoSinistroTO.REATIVACAO.nome = 'REATIVAÇÃO';
        MovimentoSinistroTO.REATIVACAO.valor = 25;
        MovimentoSinistroTO.REATIVACAO.descricaoValor = String.valueOf(REATIVACAO.valor);
        MovimentoSinistroTO.REATIVACAO.descricao = 'REATIVACAO';
        MovimentoSinistroTO.REATIVACAO.tipo = 'Aviso';
        MovimentoSinistroTO.REATIVACAO.flagEncerramentoJuridico = 'Não';
        MovimentoSinistroTO.REATIVACAO.multiplicadorMaisMenos = 1;
        
        MovimentoSinistroTO.FURTO.nome = 'FURTO';
        MovimentoSinistroTO.FURTO.valor = 26;
        MovimentoSinistroTO.FURTO.descricaoValor = String.valueOf(FURTO.valor);
        MovimentoSinistroTO.FURTO.descricao = 'FURTO';
        MovimentoSinistroTO.FURTO.tipo = 'Despesa';
        MovimentoSinistroTO.FURTO.flagEncerramentoJuridico = 'Não';
        MovimentoSinistroTO.FURTO.multiplicadorMaisMenos = 1;
        
        MovimentoSinistroTO.FURTO_COM_RESSARCIMENTO.nome = 'FURTO COM RESSARCIMENTO';
        MovimentoSinistroTO.FURTO_COM_RESSARCIMENTO.valor = 27;
        MovimentoSinistroTO.FURTO_COM_RESSARCIMENTO.descricaoValor = String.valueOf(FURTO_COM_RESSARCIMENTO.valor);
        MovimentoSinistroTO.FURTO_COM_RESSARCIMENTO.descricao = 'FURTO COM RESSARCIMENTO';
        MovimentoSinistroTO.FURTO_COM_RESSARCIMENTO.tipo = 'Despesa';
        MovimentoSinistroTO.FURTO_COM_RESSARCIMENTO.flagEncerramentoJuridico = 'Não';
        MovimentoSinistroTO.FURTO_COM_RESSARCIMENTO.multiplicadorMaisMenos = 1;
        
        MovimentoSinistroTO.ACERTO_AVISO_AUTOMATICO_MAIS.nome = 'ACERTO AVISO AUTOM (+)';
        MovimentoSinistroTO.ACERTO_AVISO_AUTOMATICO_MAIS.valor = 32;
        MovimentoSinistroTO.ACERTO_AVISO_AUTOMATICO_MAIS.descricaoValor = String.valueOf(ACERTO_AVISO_AUTOMATICO_MAIS.valor);
        MovimentoSinistroTO.ACERTO_AVISO_AUTOMATICO_MAIS.descricao = 'ACERTO AVISO AUTOM (+)';
        MovimentoSinistroTO.ACERTO_AVISO_AUTOMATICO_MAIS.tipo = 'Aviso';
        MovimentoSinistroTO.ACERTO_AVISO_AUTOMATICO_MAIS.flagEncerramentoJuridico = 'Não';
        MovimentoSinistroTO.ACERTO_AVISO_AUTOMATICO_MAIS.multiplicadorMaisMenos = 1;
        
        MovimentoSinistroTO.ACERTO_AVISO_AUTOMATICO_MENOS.nome = 'ACERTO AVISO AUTOM (-)';
        MovimentoSinistroTO.ACERTO_AVISO_AUTOMATICO_MENOS.valor = 33;
        MovimentoSinistroTO.ACERTO_AVISO_AUTOMATICO_MENOS.descricaoValor = String.valueOf(ACERTO_AVISO_AUTOMATICO_MENOS.valor);
        MovimentoSinistroTO.ACERTO_AVISO_AUTOMATICO_MENOS.descricao = 'ACERTO AVISO AUTOM (-)';
        MovimentoSinistroTO.ACERTO_AVISO_AUTOMATICO_MENOS.tipo = 'Aviso';
        MovimentoSinistroTO.ACERTO_AVISO_AUTOMATICO_MENOS.flagEncerramentoJuridico = 'Não';
        MovimentoSinistroTO.ACERTO_AVISO_AUTOMATICO_MENOS.multiplicadorMaisMenos = -1;
        
        /* 52: Criam Complementos de indenização se o request.valor foi informado. */
        MovimentoSinistroTO.ACERTO_JUROS_MAIS.nome = 'ACERTOS JUROS JUR(+)';
        MovimentoSinistroTO.ACERTO_JUROS_MAIS.valor = 52;
        MovimentoSinistroTO.ACERTO_JUROS_MAIS.descricaoValor = String.valueOf(ACERTO_JUROS_MAIS.valor);
        MovimentoSinistroTO.ACERTO_JUROS_MAIS.descricao = 'ACERTOS JUROS JUR(+)';
        MovimentoSinistroTO.ACERTO_JUROS_MAIS.tipo = 'Aviso';
        MovimentoSinistroTO.ACERTO_JUROS_MAIS.tipoComplemento = 'Juros';
        MovimentoSinistroTO.ACERTO_JUROS_MAIS.flagEncerramentoJuridico = 'Não';
        MovimentoSinistroTO.ACERTO_JUROS_MAIS.multiplicadorMaisMenos = 1;
        
        /* 53: Criam Complementos de indenização se o request.valor foi informado. */
        MovimentoSinistroTO.ACERTO_JUROS_MENOS.nome = 'ACERTOS JUROS JUR(-)';
        MovimentoSinistroTO.ACERTO_JUROS_MENOS.valor = 53;
        MovimentoSinistroTO.ACERTO_JUROS_MENOS.descricaoValor = String.valueOf(ACERTO_JUROS_MENOS.valor);
        MovimentoSinistroTO.ACERTO_JUROS_MENOS.descricao = 'ACERTOS JUROS JUR(-)';
        MovimentoSinistroTO.ACERTO_JUROS_MENOS.tipo = 'Aviso';
        MovimentoSinistroTO.ACERTO_JUROS_MENOS.tipoComplemento = 'Juros';
        MovimentoSinistroTO.ACERTO_JUROS_MENOS.flagEncerramentoJuridico = 'Não';
        MovimentoSinistroTO.ACERTO_JUROS_MENOS.multiplicadorMaisMenos = -1;
        
        /* 62: Criam Complementos de indenização se o request.valor foi informado. */
        MovimentoSinistroTO.ACERTO_CORRECAO_JUROS_MAIS.nome = 'ACERTO CORREÇÃO JUR(+)';
        MovimentoSinistroTO.ACERTO_CORRECAO_JUROS_MAIS.valor = 62;
        MovimentoSinistroTO.ACERTO_CORRECAO_JUROS_MAIS.descricaoValor = String.valueOf(ACERTO_CORRECAO_JUROS_MAIS.valor);
        MovimentoSinistroTO.ACERTO_CORRECAO_JUROS_MAIS.descricao = 'ACERTO CORRECAO JUR(+)';
        MovimentoSinistroTO.ACERTO_CORRECAO_JUROS_MAIS.tipo = 'Aviso';
        MovimentoSinistroTO.ACERTO_CORRECAO_JUROS_MAIS.tipoComplemento = 'Atualização Monetária';
        MovimentoSinistroTO.ACERTO_CORRECAO_JUROS_MAIS.flagEncerramentoJuridico = 'Não';
        MovimentoSinistroTO.ACERTO_CORRECAO_JUROS_MAIS.multiplicadorMaisMenos = 1;
        
        /* 63: Criam Complementos de indenização se o request.valor foi informado. */
        MovimentoSinistroTO.ACERTO_CORRECAO_JUROS_MENOS.nome = 'ACERTO CORREÇÃO JUR(-)';
        MovimentoSinistroTO.ACERTO_CORRECAO_JUROS_MENOS.valor = 63;
        MovimentoSinistroTO.ACERTO_CORRECAO_JUROS_MENOS.descricaoValor = String.valueOf(ACERTO_CORRECAO_JUROS_MENOS.valor);
        MovimentoSinistroTO.ACERTO_CORRECAO_JUROS_MENOS.descricao = 'ACERTO CORREÇÃO JUR(-)';
        MovimentoSinistroTO.ACERTO_CORRECAO_JUROS_MENOS.tipo = 'Aviso';
        MovimentoSinistroTO.ACERTO_CORRECAO_JUROS_MENOS.tipoComplemento = 'Atualização Monetária';
        MovimentoSinistroTO.ACERTO_CORRECAO_JUROS_MENOS.flagEncerramentoJuridico = 'Não';
        MovimentoSinistroTO.ACERTO_CORRECAO_JUROS_MENOS.multiplicadorMaisMenos = -1;

        /* 99: Pula todas as ações Ações comuns a partir da (letra d) e deixa o Sinistro apenas com o Flag judicial assinalada. */
        MovimentoSinistroTO.MOV_ASSINALAR_FLAG_JURIDICA.nome = 'PULA TODAS ACOES COMUNS E ASSINALA FLAG JURIDICA';
        MovimentoSinistroTO.MOV_ASSINALAR_FLAG_JURIDICA.valor = 99;
        MovimentoSinistroTO.MOV_ASSINALAR_FLAG_JURIDICA.descricaoValor = String.valueOf(MOV_ASSINALAR_FLAG_JURIDICA.valor);
        MovimentoSinistroTO.MOV_ASSINALAR_FLAG_JURIDICA.descricao = 'PULA TODAS AÇÕES COMUNS E ASSINALA FLAG JURIDICA';
        MovimentoSinistroTO.MOV_ASSINALAR_FLAG_JURIDICA.flagEncerramentoJuridico = 'Não';

        /* Preenchimento do mapa de movimento por valor para que se torne mais fácil recuperar o movimento durante qualquer processo */
        MovimentoSinistroTO.MAPA_MOV_POR_VALOR.put(MovimentoSinistroTO.AVISO_MAIS.valor, MovimentoSinistroTO.AVISO_MAIS);
        MovimentoSinistroTO.MAPA_MOV_POR_VALOR.put(MovimentoSinistroTO.AC_AVISADO_MAIS.valor, MovimentoSinistroTO.AC_AVISADO_MAIS);
        MovimentoSinistroTO.MAPA_MOV_POR_VALOR.put(MovimentoSinistroTO.AC_AVISADO_MENOS.valor, MovimentoSinistroTO.AC_AVISADO_MENOS);
        MovimentoSinistroTO.MAPA_MOV_POR_VALOR.put(MovimentoSinistroTO.PAGAMENTO_PARCIAL_MAIS.valor, MovimentoSinistroTO.PAGAMENTO_PARCIAL_MAIS);
        MovimentoSinistroTO.MAPA_MOV_POR_VALOR.put(MovimentoSinistroTO.ACERTO_PAGAMENTO_PARCIAL_MAIS.valor, MovimentoSinistroTO.ACERTO_PAGAMENTO_PARCIAL_MAIS);
        MovimentoSinistroTO.MAPA_MOV_POR_VALOR.put(MovimentoSinistroTO.ACERTO_PAGAMENTO_PARCIAL_MENOS.valor, MovimentoSinistroTO.ACERTO_PAGAMENTO_PARCIAL_MENOS);
        MovimentoSinistroTO.MAPA_MOV_POR_VALOR.put(MovimentoSinistroTO.PAGAMENTO_FINAL_MAIS.valor, MovimentoSinistroTO.PAGAMENTO_FINAL_MAIS);
        MovimentoSinistroTO.MAPA_MOV_POR_VALOR.put(MovimentoSinistroTO.ACERTO_PAGAMENTO_FINAL_MAIS.valor, MovimentoSinistroTO.ACERTO_PAGAMENTO_FINAL_MAIS);
        MovimentoSinistroTO.MAPA_MOV_POR_VALOR.put(MovimentoSinistroTO.ACERTO_PAGAMENTO_FINAL_MENOS.valor, MovimentoSinistroTO.ACERTO_PAGAMENTO_FINAL_MENOS);
        MovimentoSinistroTO.MAPA_MOV_POR_VALOR.put(MovimentoSinistroTO.SALVADOS.valor, MovimentoSinistroTO.SALVADOS);
        MovimentoSinistroTO.MAPA_MOV_POR_VALOR.put(MovimentoSinistroTO.SALVADOS_COM_RESSARCIMENTO.valor, MovimentoSinistroTO.SALVADOS_COM_RESSARCIMENTO);
        MovimentoSinistroTO.MAPA_MOV_POR_VALOR.put(MovimentoSinistroTO.RESSARCIMENTO_SEM_PERDA.valor, MovimentoSinistroTO.RESSARCIMENTO_SEM_PERDA);
        MovimentoSinistroTO.MAPA_MOV_POR_VALOR.put(MovimentoSinistroTO.RESSARCIMENTO_JURIDICO.valor, MovimentoSinistroTO.RESSARCIMENTO_JURIDICO);
        MovimentoSinistroTO.MAPA_MOV_POR_VALOR.put(MovimentoSinistroTO.DESPESAS_MAIS.valor, MovimentoSinistroTO.DESPESAS_MAIS);
        MovimentoSinistroTO.MAPA_MOV_POR_VALOR.put(MovimentoSinistroTO.ACERTO_DESPESAS_MAIS.valor, MovimentoSinistroTO.ACERTO_DESPESAS_MAIS);
        MovimentoSinistroTO.MAPA_MOV_POR_VALOR.put(MovimentoSinistroTO.ACERTO_DESPESAS_MENOS.valor, MovimentoSinistroTO.ACERTO_DESPESAS_MENOS);
        MovimentoSinistroTO.MAPA_MOV_POR_VALOR.put(MovimentoSinistroTO.ENCERRAMENTO_SEM_INDENIZACAO.valor, MovimentoSinistroTO.ENCERRAMENTO_SEM_INDENIZACAO);
        MovimentoSinistroTO.MAPA_MOV_POR_VALOR.put(MovimentoSinistroTO.REATIVACAO.valor, MovimentoSinistroTO.REATIVACAO);
        MovimentoSinistroTO.MAPA_MOV_POR_VALOR.put(MovimentoSinistroTO.FURTO.valor, MovimentoSinistroTO.FURTO);
        MovimentoSinistroTO.MAPA_MOV_POR_VALOR.put(MovimentoSinistroTO.FURTO_COM_RESSARCIMENTO.valor, MovimentoSinistroTO.FURTO_COM_RESSARCIMENTO);
        MovimentoSinistroTO.MAPA_MOV_POR_VALOR.put(MovimentoSinistroTO.ACERTO_AVISO_AUTOMATICO_MAIS.valor, MovimentoSinistroTO.ACERTO_AVISO_AUTOMATICO_MAIS);
        MovimentoSinistroTO.MAPA_MOV_POR_VALOR.put(MovimentoSinistroTO.ACERTO_AVISO_AUTOMATICO_MENOS.valor, MovimentoSinistroTO.ACERTO_AVISO_AUTOMATICO_MENOS);
        MovimentoSinistroTO.MAPA_MOV_POR_VALOR.put(MovimentoSinistroTO.ACERTO_JUROS_MAIS.valor, MovimentoSinistroTO.ACERTO_JUROS_MAIS);
        MovimentoSinistroTO.MAPA_MOV_POR_VALOR.put(MovimentoSinistroTO.ACERTO_JUROS_MENOS.valor, MovimentoSinistroTO.ACERTO_JUROS_MENOS);
        MovimentoSinistroTO.MAPA_MOV_POR_VALOR.put(MovimentoSinistroTO.ACERTO_CORRECAO_JUROS_MAIS.valor, MovimentoSinistroTO.ACERTO_CORRECAO_JUROS_MAIS);
        MovimentoSinistroTO.MAPA_MOV_POR_VALOR.put(MovimentoSinistroTO.ACERTO_CORRECAO_JUROS_MENOS.valor, MovimentoSinistroTO.ACERTO_CORRECAO_JUROS_MENOS);
        /* Movimentos que representam reajuste para cima ou para baixo. */
        MovimentoSinistroTO.CONJ_MOV_REAJUSTE.add(AVISO_MAIS);
        MovimentoSinistroTO.CONJ_MOV_REAJUSTE.add(AC_AVISADO_MAIS);
        MovimentoSinistroTO.CONJ_MOV_REAJUSTE.add(AC_AVISADO_MENOS);
        MovimentoSinistroTO.CONJ_MOV_REAJUSTE.add(ACERTO_AVISO_AUTOMATICO_MAIS);
        MovimentoSinistroTO.CONJ_MOV_REAJUSTE.add(ACERTO_AVISO_AUTOMATICO_MENOS);
        MovimentoSinistroTO.CONJ_MOV_REAJUSTE.add(MOV_CALCULO);
        /* Movimentos que alteram valor indenizado nos registros. */
        MovimentoSinistroTO.CONJ_MOV_VALOR_CAPITAL.addAll(CONJ_MOV_REAJUSTE);
        MovimentoSinistroTO.CONJ_MOV_VALOR_CAPITAL.add(REATIVACAO);
        /* Movimentos que representam pagamentos de indenização. */
        MovimentoSinistroTO.CONJ_MOV_PAGAMENTOS_INDENIZACAO.add(PAGAMENTO_PARCIAL_MAIS);
        MovimentoSinistroTO.CONJ_MOV_PAGAMENTOS_INDENIZACAO.add(PAGAMENTO_FINAL_MAIS);
        MovimentoSinistroTO.CONJ_MOV_PAGAMENTOS_INDENIZACAO.add(ACERTO_PAGAMENTO_FINAL_MAIS);
        /* Movimentos com status cancelados. */
        MovimentoSinistroTO.CONJ_MOV_STATUS_CANCELADO.add(ACERTO_PAGAMENTO_PARCIAL_MENOS);
        MovimentoSinistroTO.CONJ_MOV_STATUS_CANCELADO.add(ACERTO_PAGAMENTO_FINAL_MENOS);
        /* Despesas. */
        MovimentoSinistroTO.CONJ_MOV_DESPESA.add(DESPESAS_MAIS);
        /* Movimentos de juros. */
        MovimentoSinistroTO.CONJ_MOV_JUROS.add(ACERTO_JUROS_MAIS);
        MovimentoSinistroTO.CONJ_MOV_JUROS.add(ACERTO_JUROS_MENOS);
        /* Movimentos de correções manetarias. */
        MovimentoSinistroTO.CONJ_MOV_CORRECAO_MONETARIA.add(ACERTO_CORRECAO_JUROS_MAIS);
        MovimentoSinistroTO.CONJ_MOV_CORRECAO_MONETARIA.add(ACERTO_CORRECAO_JUROS_MENOS);
        /* Movimentos de complemento. Esses movimentos possuem tipo de complemento preenchidos para criar um ComplementoIndenizacao__c. */
        MovimentoSinistroTO.CONJ_MOV_COMPLEMENTO.addAll(CONJ_MOV_JUROS);
        MovimentoSinistroTO.CONJ_MOV_COMPLEMENTO.addAll(CONJ_MOV_CORRECAO_MONETARIA);
        /* Movimentos que são considerados durante o cálculo de fechamento administrativo. */
        MovimentoSinistroTO.CONJ_MOV_FECHAMENTO_ADMINISTRATIVO.add(AVISO_MAIS);
        MovimentoSinistroTO.CONJ_MOV_FECHAMENTO_ADMINISTRATIVO.add(ENCERRAMENTO_SEM_INDENIZACAO);
        MovimentoSinistroTO.CONJ_MOV_FECHAMENTO_ADMINISTRATIVO.add(REATIVACAO);
        MovimentoSinistroTO.CONJ_MOV_FECHAMENTO_ADMINISTRATIVO.addAll(CONJ_MOV_REAJUSTE);
        MovimentoSinistroTO.CONJ_MOV_FECHAMENTO_ADMINISTRATIVO.addAll(CONJ_MOV_JUROS);
        MovimentoSinistroTO.CONJ_MOV_FECHAMENTO_ADMINISTRATIVO.addAll(CONJ_MOV_CORRECAO_MONETARIA);
        /* Movimentos que são cálculados junto com o valor recebido pelo E-LAW. */
        CONJ_MOV_GERA_VALOR_CALCULADO.addAll(CONJ_MOV_REAJUSTE);
        CONJ_MOV_GERA_VALOR_CALCULADO.add(ENCERRAMENTO_SEM_INDENIZACAO);
        CONJ_MOV_GERA_VALOR_CALCULADO.add(REATIVACAO);
        /* Movimentos que são recebidos que não precisam de valor. */
        CONJ_MOV_RECEBIDOS_SEM_VALOR.add(ENCERRAMENTO_SEM_INDENIZACAO);
        CONJ_MOV_RECEBIDOS_SEM_VALOR.add(REATIVACAO);
        CONJ_MOV_RECEBIDOS_SEM_VALOR.add(MOV_ASSINALAR_FLAG_JURIDICA);
        /* Movimentos que são considerados durante o cálculo de fechamento jurídico. */
        MovimentoSinistroTO.CONJ_MOV_FECHAMENTO_JURIDICO.add(AVISO_MAIS);
        MovimentoSinistroTO.CONJ_MOV_FECHAMENTO_JURIDICO.addAll(CONJ_MOV_REAJUSTE);
        MovimentoSinistroTO.CONJ_MOV_FECHAMENTO_JURIDICO.addAll(CONJ_MOV_COMPLEMENTO);
        MovimentoSinistroTO.CONJ_MOV_FECHAMENTO_JURIDICO.add(ENCERRAMENTO_SEM_INDENIZACAO);
        MovimentoSinistroTO.CONJ_MOV_FECHAMENTO_JURIDICO.add(REATIVACAO);
        /* Movimentos que são considerados durante o cálculo de fechamento jurídico. */
        MovimentoSinistroTO.CONJ_MOV_JURIDICO.addAll(CONJ_MOV_REAJUSTE);
        MovimentoSinistroTO.CONJ_MOV_JURIDICO.addAll(CONJ_MOV_COMPLEMENTO);
        MovimentoSinistroTO.CONJ_MOV_JURIDICO.addAll(CONJ_MOV_RECEBIDOS_SEM_VALOR);
    }

    /* Métodos úteis. */
    public Set<Integer> recuperarConjuntoMovimentoValor(Set<MovimentoSinistroTO.Movimento> conjuntoMovimento) {
        Set<Integer> conjMovValor = new Set<Integer>();
        for(MovimentoSinistroTO.Movimento movimentoTO : conjuntoMovimento) {
            conjMovValor.add(movimentoTO.valor);
        }
        return conjMovValor;
    }

    public class MovimentoSinistroTOException extends Exception {}
}
// POR062-1 - INICIO