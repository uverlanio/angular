/**
 * Created by Alessandro Ponte on 18/12/2018.
 */

public without sharing class ExcecaoCustomizada {

  public String nome;
  public String mensagem;
  public Integer codigo;

  public ExcecaoCustomizada() {}

  public ExcecaoCustomizada(String nome, String mensagem, Integer codigo) {
    this.nome = nome;
    this.mensagem = mensagem;
    this.codigo = codigo;
  }


}