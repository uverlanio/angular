function checkBirthdate(n){}function birthdateChangeHandle(n){}
function tratamentoOfertas(o){let r=JSON.parse(o).ofertas,a=r.map(o=>o.retornosCalculo[0].precificacao.premio.total).sort((function(o,r){return o-r})),e={ofertas:[]};for(;a.length>0;){let o=r.filter(o=>o.retornosCalculo[0].precificacao.premio.total==a[0]).shift(),t=r.findIndex(r=>r.orcamento.numeroOrcamento==o.orcamento.numeroOrcamento);e.ofertas.push(r.splice(t,1).shift()),a.splice(0,1)}let t={ofertas:[]};return e.ofertas.forEach(o=>{let r={orcamento:{rotulo:o.orcamento.rotulo,numeroOrcamento:o.orcamento.numeroOrcamento,garantiasAtuais:o.orcamento.contratantes[0].grupos[0].segurados?o.orcamento.contratantes[0].grupos[0].segurados[0].coberturas:o.orcamento.contratantes[0].grupos[0].coberturas,versoesCalculos:o.orcamento.versoesCalculos,customizavel:o.orcamento.customizavel||!1,gerarDocumento:o.orcamento.gerarDocumento||!1,segmento:o.orcamento.segmento},retornosCalculo:[],parcelamentos:o.parcelamentos,regras:o.regras,retornoAceitacao:o.retornoAceitacao};o.retornosCalculo.forEach(a=>{let e={descontoMonetario:a.precificacao.descontoAgravo[0].monetario,premio:a.precificacao.premio.total,capital:a.precificacao.coberturas.capital,opcao:a.opcao,coberturas:[]},t=[];a.precificacao.coberturas.length>0?(a.precificacao.coberturas.forEach(r=>{let a=o.regras.coberturas.filter(o=>r.sigla==o.sigla).shift();a&&(t[a.prioridade]=r)}),t.forEach(o=>{let r={sigla:o.sigla,premio:o.premio.total,capital:o.capital,descontoAgravo:o.descontoAgravo};e.coberturas.push(r)})):a.precificacao.grupos&&a.precificacao.grupos[0].coberturas.forEach(o=>{let r={sigla:o.sigla,premio:o.premio.total,capital:o.capital,descontoAgravo:o.descontoAgravo};e.coberturas.push(r)}),r.retornosCalculo.push(e)}),t.ofertas.push(r)}),window.localStorage.setItem("jsonOfertasMin",JSON.stringify(t)),JSON.stringify(t)}
function initializeDatePicker(){const e=document.querySelectorAll(".datepicker");let t={format:"dd/mm/yyyy",language:"pt-BR",i18n:{weekdays:["Domingo","Segunda","Terça","Quarta","Quinta","Sexta","Sábado"],weekdaysShort:["Dom","Seg","Ter","Qua","Qui","Sex","Sab"],weekdaysAbbrev:["D","S","T","Q","Q","S","S"],months:["Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"],monthsShort:["Jan","Fev","Mar","Abr","Mai","Jun","Jul","Ago","Set","Out","Nov","Dez"],cancel:"Cancelar",clear:"Limpar",done:"Ok"}};for(const l of e){var a=t,n=new Date((new Date).toISOString().slice(0,10));if("true"==l.getAttribute("data-block-future")&&(a.maxDate=n),l.getAttribute("data-default-date")){let e=l.getAttribute("data-default-date").replace("GMT","");a.defaultDate=new Date(e),a.setDefaultDate=!0}M.Datepicker.init(l,a),VMasker(l).maskPattern("99/99/9999")}}function initializeDate(){const e=document.querySelectorAll(".date");function t(e){return e>9?e:"0"+e}for(const a of e)if(a.getAttribute("data-default-date")){let e=a.getAttribute("data-default-date").replace("GMT","");if(e){let n=new Date(e),l=t(n.getDate()),r=t(n.getMonth()+1),i=n.getFullYear();a.value=`${l}${r}${i}`}VMasker(a).maskPattern("99/99/9999")}}function initializeAutocomplete(){M.Autocomplete.init(document.querySelectorAll(".autocomplete"),{})}function initializeCollapsible(){M.Collapsible.init(document.querySelectorAll(".collapsible"),{})}function initializeSelecteds(){let e=document.querySelectorAll("select");for(const e of document.querySelectorAll("select")){let t=e.querySelectorAll("option[aria-selected=true]");t.length>0&&t[t.length-1].setAttribute("selected","")}M.FormSelect.init(e,{})}function initGarantiaEtapa1Personal(e){let t=document.querySelectorAll(".etapa1 [data-garantia-personalization]"),a={precision:0,separator:",",zeroCents:!1};for(let s of t){let t=s.querySelector(".switch input"),p=s.querySelector("input[type=text]"),m=s.querySelector("input[type=range]"),f=s.getAttribute("data-default-value")?s.getAttribute("data-default-value").split(".")[0]:null,g=s.getAttribute("data-capital-min")?s.getAttribute("data-capital-min").split(".")[0]:null,b=s.getAttribute("data-capital-max")?s.getAttribute("data-capital-max").split(".")[0]:null;function n(){"true"==t.getAttribute("data-switch-required")?(t.disabled=!0,t.checked=!0):(t.checked="true"==t.getAttribute("data-switch-checked"),t.addEventListener("change",r))}function l(){if(p.disabled=g==b,p.addEventListener("change",i),VMasker(p).maskMoney(a),g==b)m.parentElement.innerHTML="",m=null;else{m.addEventListener("change",u);let e=m.parentElement.parentElement.querySelectorAll("span"),t=e[0],n=e[e.length-1];t&&(t.innerHTML="R$ "+VMasker.toMoney(g,a)),n&&(n.innerHTML="R$ "+VMasker.toMoney(b,a))}}function r(e){e.target.checked?c():o()}function i(e){d(VMasker.toNumber(e.target.value)),m.value=VMasker.toNumber(e.target.value)}function u(e){d(e.target.value)}function o(){p&&(p.disabled=!0,p.value=0),m&&(m.disabled=!0,m.value=0)}function c(){p&&(p.disabled=!1,d(f)),m&&(m.disabled=!1,m.value=f)}function d(e){e=parseInt(e);let t=parseInt(g),n=parseInt(b);p.value=t>e?VMasker.toMoney(t,a):e>n?VMasker.toMoney(n,a):VMasker.toMoney(e,a)}(!e||t&&p&&m&&!f&&!g&&!b)&&(n(),parseInt(b)>0?l():(p.parentElement.innerHTML="",p=null,m.parentElement.innerHTML="",m=null),1==t.checked?c():o())}}function initializePercentInput(){const e=document.querySelectorAll("input[data-input-type=decimal]");for(const n of e){let e=parseFloat(n.getAttribute("data-minimum-value")),l=parseFloat(n.getAttribute("data-maximum-value")),r=n.value;function t(e){a(e.target.value)}function a(t){try{t=parseFloat(t)}catch(a){t=e}t<e||!t?t=e:t>l&&(t=l),t<10&&(t="0"+t),1==(t=VMasker.toPattern(t,"99.99")).split(".").length?n.value=t+".00":((t=t.split("."))[1]=1==t[1].length?t[1]+"0":t[1],n.value=t.join("."))}a(r&&""!=r?r:e),VMasker(n).maskPattern("99.99"),(e||l)&&n.addEventListener("change",t)}}
function setProfessionData(){let o=window.localStorage.getItem("jsonServicos");o=null!=o?JSON.parse(o):{};let e=document.querySelector("#etapa1-profession"),t=document.getElementById("jsonProfessionsData"),s=[],a=[];if(t.value&&(a=JSON.parse(t.value)),!o.DICIO_PROFISSAO){let e={DICIO_PROFISSAO:{}};e.DICIO_PROFISSAO.itens=[];for(let o in a)e.DICIO_PROFISSAO.itens.push({rotulo:a[o].NomeFantasia__c,codigo:a[o].CodigoProfissao__c});o=Object.assign(o,e),window.localStorage.setItem("jsonServicos",JSON.stringify(o))}for(const o of a)s[o.NomeFantasia__c]=null;M.Autocomplete.init(e,{data:s,limit:3})}
function showToast(s={message:null,title:null,type:"success"}){null!=s.message&&sforce.one.showToast({...s})}
document.addEventListener("DOMContentLoaded",()=>{initializeAutocomplete(),initializeCollapsible(),initializeDatePicker(),initializeDate(),initializeSelecteds(),initializePercentInput(),checkDates(),getFromStorage()});
function setLoader(){let e=document.querySelector(".modalLoaderErro");e.classList.add("on"),e.querySelector(".loader").classList.remove("hidden"),e.querySelector(".message").classList.add("hidden")}function removeLoader(){let e=document.querySelector(".modalLoaderErro");e.classList.remove("on"),e.querySelector(".loader").classList.add("hidden")}function setInitialDate(){const e=new Date(document.getElementById("etapa1-iniciovigencia").value.split("/").reverse().join("-")+" 00:00"),o=new Date(document.getElementById("etapa1-finalvigencia").value.split("/").reverse().join("-")+" 00:00");e instanceof Date&&!isNaN(e)&&e?(document.getElementById("etapa1-iniciovigencia").classList.remove("invalid"),M.Datepicker.getInstance(document.getElementById("etapa1-iniciovigencia")).destroy(),M.Datepicker.init(document.getElementById("etapa1-iniciovigencia"),{format:"dd/mm/yyyy",language:"pt-BR",i18n:{weekdays:["Domingo","Segunda","Terça","Quarta","Quinta","Sexta","Sábado"],weekdaysShort:["Dom","Seg","Ter","Qua","Qui","Sex","Sab"],weekdaysAbbrev:["D","S","T","Q","Q","S","S"],months:["Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"],monthsShort:["Jan","Fev","Mar","Abr","Mai","Jun","Jul","Ago","Set","Out","Nov","Dez"],cancel:"Cancelar",clear:"Limpar",done:"Ok"},minDate:new Date,maxDate:o,defaultDate:e,setDefaultDate:!1}),M.Datepicker.getInstance(document.getElementById("etapa1-finalvigencia")).destroy(),M.Datepicker.init(document.getElementById("etapa1-finalvigencia"),{format:"dd/mm/yyyy",language:"pt-BR",i18n:{weekdays:["Domingo","Segunda","Terça","Quarta","Quinta","Sexta","Sábado"],weekdaysShort:["Dom","Seg","Ter","Qua","Qui","Sex","Sab"],weekdaysAbbrev:["D","S","T","Q","Q","S","S"],months:["Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"],monthsShort:["Jan","Fev","Mar","Abr","Mai","Jun","Jul","Ago","Set","Out","Nov","Dez"],cancel:"Cancelar",clear:"Limpar",done:"Ok"},minDate:e,defaultDate:o,setDefaultDate:!1})):document.getElementById("etapa1-iniciovigencia").classList.add("invalid")}function setFinalDate(){const e=new Date(document.getElementById("etapa1-iniciovigencia").value.split("/").reverse().join("-")+" 00:00"),o=new Date(document.getElementById("etapa1-finalvigencia").value.split("/").reverse().join("-")+" 00:00");o instanceof Date&&!isNaN(o)&&o?(document.getElementById("etapa1-iniciovigencia").classList.remove("invalid"),M.Datepicker.getInstance(document.getElementById("etapa1-iniciovigencia")).destroy(),M.Datepicker.init(document.getElementById("etapa1-iniciovigencia"),{format:"dd/mm/yyyy",language:"pt-BR",i18n:{weekdays:["Domingo","Segunda","Terça","Quarta","Quinta","Sexta","Sábado"],weekdaysShort:["Dom","Seg","Ter","Qua","Qui","Sex","Sab"],weekdaysAbbrev:["D","S","T","Q","Q","S","S"],months:["Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"],monthsShort:["Jan","Fev","Mar","Abr","Mai","Jun","Jul","Ago","Set","Out","Nov","Dez"],cancel:"Cancelar",clear:"Limpar",done:"Ok"},minDate:new Date,maxDate:o,defaultDate:e,setDefaultDate:!1}),M.Datepicker.getInstance(document.getElementById("etapa1-finalvigencia")).destroy(),M.Datepicker.init(document.getElementById("etapa1-finalvigencia"),{format:"dd/mm/yyyy",language:"pt-BR",i18n:{weekdays:["Domingo","Segunda","Terça","Quarta","Quinta","Sexta","Sábado"],weekdaysShort:["Dom","Seg","Ter","Qua","Qui","Sex","Sab"],weekdaysAbbrev:["D","S","T","Q","Q","S","S"],months:["Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"],monthsShort:["Jan","Fev","Mar","Abr","Mai","Jun","Jul","Ago","Set","Out","Nov","Dez"],cancel:"Cancelar",clear:"Limpar",done:"Ok"},minDate:e,defaultDate:o,setDefaultDate:!1})):document.getElementById("etapa1-finalvigencia").classList.add("invalid")}function checkDates(){const e=document.getElementById("etapa1-iniciovigencia"),o=new Date(document.getElementById("etapa1-iniciovigencia").value.split("/").reverse().join("-")),a=document.getElementById("etapa1-finalvigencia"),t=new Date(document.getElementById("etapa1-finalvigencia").value.split("/").reverse().join("-")),r=JSON.parse(document.getElementById("contractCompleto").value);let i=0;o<new Date&&(e.setAttribute("disabled","true"),i++),t<new Date&&(a.setAttribute("disabled","true"),i++),r&&r.Oportunidade__r&&r.Oportunidade__r.VigenciaFinalAlterada__c&&a.setAttribute("disabled","true"),2==i&&(document.getElementById("calcular").classList.add("disabled"),document.getElementById("calcular").style.border="none"),setInitialDate(),setFinalDate()}function calcular(){const e={nome:document.querySelector("#etapa1-name").value,inicioVigencia:getDateSaida(),finalVigencia:getDateRetorno(),tipoViagem:document.querySelector("#etapa1-tipoviagem").value,praticaEsportesAventura:"NAO"!=document.querySelector("#etapa1-esportes").value,utilizaraMotocicleta:"NAO"!=document.querySelector("#etapa1-motocicleta").value,passageirosNaoIdosos:document.querySelector("#etapa1-qtdjovens").value,passageirosIdosos:document.querySelector("#etapa1-qtdidosos").value,percentual:parseInt(document.getElementById("etapa1-comissao").value),destinos:[{codigo:"DESTINO",pais:document.querySelector("#etapa1-destino").value}]};setStorage("payload",e),setLoader(),callCalculoEndosso(JSON.stringify(e)),setInterval(()=>{removeLoader(),showToast({type:"error",message:"Tempo limite de redirecionamento atingido"})},12e4)}function getDataEtapa1(){console.log("getdata");let e=m(document.getElementById("etapa1-name"),"Erro ao recuperar informação: nome do segurado","Informe o nome do segurado"),o=function(){let e=document.getElementById("etapa1-birthdate");if(!e)return showToast({type:"error",message:"Erro ao recuperar informação: data de nascimento do segurado"}),null;let o=e.value;if(!o||""==o)return e.classList.add("invalid"),showToast({type:"error",message:"Informe a data de nascimento do segurado"});let a=checkBirthdate(o);if("Data inválida."==a)return showToast({type:"error",message:"Data de nascimento inválida"});if("A data de nascimento não pode ser posterior à data de hoje."==a)return showToast({type:"error",message:"A data de nascimento do segurado não pode ser posterior à data de hoje"});return new Date(o.split("/").reverse().join("-"))}(),a=u(document.getElementById("etapa1-sex"),["FEM","MASC"],"Erro ao recuperar informaçao: sexo do segurado","Informe o sexo do segurado"),t=u(document.getElementById("etapa1-smoker"),["Não","Sim"],"Erro ao recuperar informação: Fumante","Informe se segurado é fumante");null!=t&&(t="Sim"==t);let r=document.getElementById("jsonProfessionsData"),i=[];r.value&&(i=JSON.parse(r.value));let n=m(document.getElementById("etapa1-profession"),"Erro ao recuperar informação: profissão do segurado","Informe a profissão do segurado");for(let e in i)i[e].NomeFantasia__c==n&&(n=i[e].CodigoProfissao__c||null);let c=u(document.getElementById("etapa1-income"),["2500","4000","8000","12000","16000","20000","30000","30000.01"],"Erro ao recuperar informaçao: renda do segurado","Informe a renda do segurado"),d=u(document.getElementById("etapa1-workRegime"),["CLT","PROFISSIONAL_LIBERAL","FUNCIONARIO_PUBLICO"],"Erro ao recuperar informaçao: Forma de trabalho","Informe a forma de trabalho do segurado"),l=m(document.getElementById("etapa1-commission-percentage"),"Erro ao recuperar informação: Percentual da comissão","Informe o percentual da comissão do contrato");if(l&&(l=parseFloat(l)),null==e||null==o||null==a||0!=t&&1!=t||null==n||null==d||null==l||null==c)return void showToast({type:"error",message:"Erro ao executar operação"});setStorage("dadosEndossoProposta",{questionario:document.getElementById("questionario").value});const s={nome:e,dataNascimento:o,sexo:a,fumante:t,profissao:n,rendaMensal:c,regimeTrabalho:d,coberturas:function(){let e=[];const o=document.querySelectorAll(".etapa1 .coberturas [data-garantia-personalization]");for(let a of o){let o=a.getAttribute("data-garantia-personalization"),t=a.getAttribute("data-capital-min"),r=(a.getAttribute("data-capital-max"),a.getAttribute("data-coin")),i="true"==a.getAttribute("data-required"),n=a.querySelector('[type="checkbox"]');if(n=!!n&&n.checked,n||i){let i=a.querySelector(`#${o}-capital`);i=i?VMasker.toNumber(i.value):t||0;let c={sigla:o,valor:i,moeda:r,isActive:n,cotacaoMoeda:"1.0",quantidade:null,cobrado:null};e.push(c)}}return e}(),percentual:l};function u(e,o,a,t){let r=e.parentElement.getElementsByTagName("input")[0];if(r&&r.classList.remove("invalid"),!e)return r&&r.classList.add("invalid"),null;let i=e.value;return i&&""!=i&&o.includes(i)?i:(r&&r.classList.add("invalid"),null)}function m(e,o,a){if(e.classList.remove("invalid"),!e)return e.classList.add("invalid"),null;let t=e.value;return t&&""!=t?t:(e.classList.add("invalid"),null)}setStorage("payload",s),setLoader(),callCalculoEndosso(JSON.stringify(s)),setInterval(()=>{removeLoader(),showToast({type:"error",message:"Tempo limite de redirecionamento atingido"})},3e4)}function getDateSaida(){let e=document.getElementById("etapa1-iniciovigencia"),o=e.value,a=new Date(o.split("/").reverse().join("-")).toString();return e?o&&""!=o?new Date(a.split("/").reverse().join("-")).toISOString().slice(0,10):(e.classList.add("invalid"),showToast({type:"error",message:"Informe a data de nascimento do segurado"})):(showToast({type:"error",message:"Erro ao recuperar informação: data de nascimento do segurado"}),null)}function getDateRetorno(){let e=document.getElementById("etapa1-finalvigencia"),o=e.value,a=new Date(o.split("/").reverse().join("-")).toString();return e?o&&""!=o?new Date(a.split("/").reverse().join("-")).toISOString().slice(0,10):(e.classList.add("invalid"),showToast({type:"error",message:"Informe a data de nascimento do segurado"})):(showToast({type:"error",message:"Erro ao recuperar informação: data de nascimento do segurado"}),null)}function getEstadoCivil(e){return"Solteiro (a)"==e?"SOLTEIRO":"Divorciado(a)"==e?"DIVORCIADO":"Viúvo(a)"==e?"VIUVO":"Desquitado(a)"==e?"DESQUITADO":"Casado (a)"==e?"CASADO":"Vive maritalmente"==e?"VIVEMARITALMENTE":""}function setupLocalStorageData(e){let o=JSON.parse(localStorage.getItem("payload")),a=JSON.parse(document.getElementById("contractCompleto").value),t=JSON.parse(document.getElementById("beneficiarioscontrato").value),r=JSON.parse(document.getElementById("enderecosConta").value),i=JSON.parse(document.getElementById("remuneracoesContrato").value),n=JSON.parse(document.getElementById("dadoscorretores").value),c=JSON.parse(document.getElementById("seguradoscontrato").value),d=a.Account,l={apolice:a.Name,seguradoPrincipal:{},tipoBeneficiario:"",beneficiarios:[],corretagem:{}},s={cpf:"",documentos:{},empresa:"",renda:"",estadoCivil:"",nacionalidade:"",paisResidente:"",pep:"",pepRelacionamentoProximo:null,enderecos:{},email:"",periodocontato:"",telefoneResidencial:"",telefoneComercial:"",telefoneCelular:"",sexo:"",nascimento:"",nomeContato:"",telefoneContato:""};s.cpf=d.Cpf__c,d.Rg__c&&""!==d.Rg__c&&(s.documentos.rg={num:d.Rg__c,orgaoExpeditor:d.OrgaoExpedidor__c||"",dataExpedicao:d.DataExpedicao__c||""}),d.Cnh__c&&""!==d.Cnh__c&&(s.documentos.cnh={num:d.Cnh__c,orgaoExpeditor:d.OrgaoExpedidor__c||"",dataExpedicao:d.DataExpedicao__c||""}),d.Rne__c&&""!==d.Rne__c&&(s.documentos.rne={num:d.CLASSE__c,orgaoExpeditor:d.OrgaoExpedidor__c||"",dataExpedicao:d.DataExpedicao__c||""}),d.CLASSE__c&&""!==d.CLASSE__c&&(s.documentos.classe={num:d.CLASSE__c,orgaoExpeditor:d.OrgaoExpedidor__c||"",dataExpedicao:d.DataExpedicao__c||""}),s.telefoneResidencial=d.PersonHomePhone,s.telefoneComercial=d.Phone,s.telefoneCelular=d.PersonMobilePhone,s.sexo=d.Sexo__c,s.nomeContato=c[0].NomeContatoEmergencia__c||"",s.telefoneContato=c[0].TelefoneContatoEmergencia__c||"",d.PersonBirthdate&&(s.nascimento=d.PersonBirthdate.split("-").reverse().join("/"));for(let e in r){let o=r[e];s.enderecos[o.TipoEndereco__c]={cep:o.CEP__c||"",logradouro:o.Logradouro__c||"",SN:!(""==o.Numero__c||!o.Numero__c),numero:o.Numero__c||"",complemento:o.Complemento__c||"",bairro:o.Bairro__c||"",cidade:o.Cidade__c||"",estado:o.Estado__c||""}}s.empresa=d.EmpresaTrabalhaSocio__c,s.email=d.PersonEmail,s.periodocontato=d.MelhorPeriodoContato__c,s.renda=d.Renda__c,s.nacionalidade=d.Nacionalidade__c.toUpperCase(),s.resideBrasil="brasil"===d.PaisResidencia__c.toLowerCase()||!1,s.paisResidente=d.PaisResidencia__c.replace(/\w\S*/g,e=>e.replace(/^\w/,e=>e.toUpperCase())),s.pep="Sim"==d.Pep__c?"Sim":"Não"==d.Pep__c?"Nao":"Relacionamento próximo"==d.Pep__c?"RelacionamentoProximo":"","RelacionamentoProximo"==s.pep&&(s.pepRelacionamentoProximo={nome:d.NomePessoaPep__c||"",cpf:d.CpfPep__c||"",parentesco:d.GrauParentescoPep__c||""}),s.estadoCivil=getEstadoCivil(d.EstadoCivil__c),l.seguradoPrincipal=s,null!=t&&t.length>0?1===t.length&&t[0].TipoBeneficiario__c.includes("792")?l.tipoBeneficiario="Herdeiros legais, conforme artigo 792 do código civil.":(t.forEach((e,o)=>{let a={numeroBeneficiario:o,nome:e.Nome__c,cpf:e.CpfCnpj__c,dataNascimento:e.Data_de_Nascimento__c,sexo:e.Sexo__c,percentual:e.PercentualIndenizacao__c,parentesto:e.GrauParentesco__c,imprimirApolice:e.ImprimirCertificadoSeguro__c};l.beneficiarios.push(a)}),l.tipoBeneficiario="Nome do beneficiário"):l.tipoBeneficiario="Herdeiros legais, conforme artigo 792 do código civil.";let u={AGENCIAMENTO:[],CORRETAGEM:[]};null!=i&&i.length>0&&i.forEach((e,o)=>{let a={nome:e.Conta__r.Name||"",codigoAgenciador:e.Conta__r.C_digo_do_Agenciador__c||"",lider:e.CorretorLider__c||!1,susep:e.Susep__c?e.Susep__c:n[e.Conta__c][0].Name?n[e.Conta__c][0].Name:"",percentual:e.Participacao__c||"0",antecipa:e.AntecipacaoComissao__c||!1,papel:e.Papel__c||"",documento:e.Conta__r.Cnpj__c?e.Conta__r.Cnpj__c:e.Conta__r.Cpf__c?e.Conta__r.Cpf__c:""};u[e.RemuneracaoContrato__r.TipoRemuneracao__r.Name.toUpperCase()].push(a)}),l.corretagem=u,o.contratoOriginal=l,o.idContrato=a.Id,setStorage("payload",o),e.ofertas[0].orcamento.rotulo=e.ofertas[0].orcamento.codigoProdutoVida,e.ofertas[0].orcamento.susep=a.Oportunidade__r.CodigoCorretor__r.Name,setStorage("jsonMdtGrupo",{GRUPO_JOVENS_NOME:"Passageiros até 70 anos",GRUPO_JOVENS_IDADE_MIN:"0",GRUPO_JOVENS_IDADE_MAX:"70",GRUPO_IDOSOS_NOME:"Passageiros de 71 a 90 anos",GRUPO_IDOSOS_IDADE_MIN:"71",GRUPO_IDOSOS_IDADE_MAX:"90"}),setStorage("conjuntosJson",{conjuntos:[{regrasSequencia:[{proximoConjunto:3,conteudo:"VIAGEM",operacao:"=",idinformacao:"PRODUTO",sequencia:1},{proximoConjunto:2,conteudo:"API",operacao:"=",idinformacao:"PRODUTO",sequencia:2},{proximoConjunto:4,conteudo:"APE",operacao:"=",idinformacao:"PRODUTO",sequencia:3}],informacoes:[{ordem:null,opcoes:[{ordem:null,rotulo:"ACIDENTES PESSOAIS INDIVIDUAL",codigo:"API"},{ordem:null,rotulo:"AP ESTAGIÁRIO",codigo:"APE"},{ordem:null,rotulo:"SEGURO VIAGEM",codigo:"VIAGEM"}],servico:null,obrigatorio:!0,tipo:"Opções fixas",descricao:"Escolha o produto desejado",nome:"Selecione um Produto",id:"PRODUTO"}],subtitulo:null,titulo:"Selecione o produto do qual você gostaria de elaborar um orçamento",nome:"Seleção de Produto",id:1},{regrasSequencia:[],informacoes:[{ordem:1,opcoes:[],servico:null,obrigatorio:!0,tipo:"Texto",descricao:null,nome:"Nome do Cliente",id:"DICIO_NOME"},{ordem:2,opcoes:[],servico:null,obrigatorio:!0,tipo:"DataCalendario",descricao:null,nome:"Data de nascimento",id:"DICIO_DATANASCIMENTO"},{ordem:3,opcoes:[],servico:null,obrigatorio:!0,tipo:"CPF",descricao:null,nome:"CPF",id:"CPF"}],subtitulo:null,titulo:"Informe os dados pessoais de seu cliente",nome:"Dados Pessoais API",id:2},{regrasSequencia:[],informacoes:[{ordem:1,opcoes:[],servico:null,obrigatorio:!0,tipo:"Texto",descricao:null,nome:"Nome principal",id:"DICIO_NOME"},{ordem:2,opcoes:[{ordem:1,rotulo:"NACIONAL",codigo:"NACIONAL"},{ordem:2,rotulo:"INTERNACIONAL",codigo:"INTERNACIONAL"}],servico:null,obrigatorio:!0,tipo:"Opções fixas",descricao:null,nome:"Tipo viagem",id:"TIPO_VIAGEM"},{ordem:3,opcoes:[{ordem:1,rotulo:"Brasil",codigo:"Brasil"}],servico:null,obrigatorio:!0,tipo:"Opções fixas",descricao:null,nome:"Origem",id:"ORIGEM"},{ordem:4,opcoes:[{ordem:1,rotulo:"Brasil",codigo:"Brasil"},{ordem:2,rotulo:"Cuba",codigo:"Cuba"}],servico:null,obrigatorio:!0,tipo:"Opções fixas",descricao:null,nome:"Destino",id:"DESTINO"},{ordem:5,opcoes:[],servico:null,obrigatorio:!0,tipo:"DataCalendario",descricao:null,nome:"Data de saída",id:"DICIO_DATA_SAIDA"},{ordem:6,opcoes:[],servico:null,obrigatorio:!0,tipo:"DataCalendario",descricao:null,nome:"Data de retorno",id:"DICIO_DATA_RETORNO"},{ordem:7,opcoes:[{ordem:1,rotulo:"Sim",codigo:"true"},{ordem:2,rotulo:"Não",codigo:"false"}],servico:null,obrigatorio:!0,tipo:"Radiobutton",descricao:null,nome:"Aventura",id:"DICIO_AVENTURA"},{ordem:8,opcoes:[{ordem:1,rotulo:"Sim",codigo:"true"},{ordem:2,rotulo:"Não",codigo:"false"}],servico:null,obrigatorio:!0,tipo:"Radiobutton",descricao:null,nome:"Utilizará Motocicleta durante a viagem?",id:"DICIO_MOTOCICLETA"},{ordem:9,opcoes:[{ordem:1,rotulo:"0",codigo:"0"},{ordem:2,rotulo:"1",codigo:"1"},{ordem:3,rotulo:"2",codigo:"2"},{ordem:4,rotulo:"3",codigo:"3"},{ordem:4,rotulo:"4",codigo:"4"},{ordem:5,rotulo:"5",codigo:"5"},{ordem:6,rotulo:"6",codigo:"6"},{ordem:7,rotulo:"7",codigo:"7"},{ordem:8,rotulo:"8",codigo:"8"},{ordem:9,rotulo:"9",codigo:"9"},{ordem:10,rotulo:"10",codigo:"10"},{ordem:11,rotulo:"11",codigo:"11"},{ordem:12,rotulo:"12",codigo:"12"},{ordem:13,rotulo:"13",codigo:"13"},{ordem:14,rotulo:"14",codigo:"14"},{ordem:15,rotulo:"15",codigo:"15"},{ordem:16,rotulo:"16",codigo:"16"},{ordem:17,rotulo:"17",codigo:"17"},{ordem:18,rotulo:"18",codigo:"18"},{ordem:19,rotulo:"19",codigo:"19"},{ordem:20,rotulo:"20",codigo:"20"}],servico:null,obrigatorio:!0,tipo:"Opções fixas",descricao:null,nome:"Pessoas antes de 70",id:"DICIO_QTD_JOVENS"},{ordem:10,opcoes:[{ordem:1,rotulo:"0",codigo:"0"},{ordem:2,rotulo:"1",codigo:"1"},{ordem:3,rotulo:"2",codigo:"2"},{ordem:4,rotulo:"3",codigo:"3"},{ordem:4,rotulo:"4",codigo:"4"},{ordem:5,rotulo:"5",codigo:"5"},{ordem:6,rotulo:"6",codigo:"6"},{ordem:7,rotulo:"7",codigo:"7"},{ordem:8,rotulo:"8",codigo:"8"},{ordem:9,rotulo:"9",codigo:"9"},{ordem:10,rotulo:"10",codigo:"10"}],servico:null,obrigatorio:!0,tipo:"Opções fixas",descricao:null,nome:"Quantas pessoas depois de 70?",id:"DICIO_QTD_IDOSOS"},{ordem:11,opcoes:[{ordem:1,rotulo:"25",codigo:"25"},{ordem:2,rotulo:"40",codigo:"40"},{ordem:3,rotulo:"50",codigo:"50"}],servico:null,obrigatorio:!0,tipo:"Opções fixas",descricao:null,nome:"Código de operação",id:"DICIO_CORRETAGEM"}],subtitulo:"Teste subtitulo",titulo:"Informe os dados pessoais de seu cliente",nome:"Dados Pessoais Viagem",id:3},{regrasSequencia:[],informacoes:[{ordem:null,opcoes:[{ordem:null,rotulo:"Feminino",codigo:"FEMININO"},{ordem:null,rotulo:"Masculino",codigo:"MASCULINO"}],servico:null,obrigatorio:!0,tipo:"Opções fixas",descricao:null,nome:"Sexo",id:"SEXO"},{ordem:null,opcoes:[],servico:null,obrigatorio:!1,tipo:"Texto",descricao:null,nome:"Nome da Empresa Onde Trabalha",id:"NOMEEMPRESA"},{ordem:null,opcoes:[],servico:null,obrigatorio:!1,tipo:"CNPJ",descricao:null,nome:"CNPJ da Empresa",id:"CNPJEMPRESA"},{ordem:null,opcoes:[],servico:null,obrigatorio:!0,tipo:"CPF",descricao:null,nome:"CPF",id:"CPF"},{ordem:null,opcoes:[],servico:null,obrigatorio:!0,tipo:"DataCalendario",descricao:null,nome:"Data nascimento",id:"DATANASCIMENTO"}],subtitulo:null,titulo:"Informe os dados pessoais de seu cliente",nome:"Dados Pessoais APE",id:4}],DICIO_RETENCAO:null,DICIO_AGENCIAMENTO:null,DICIO_CORRETAGEM:null,Cliente:!1,meioComercializacao:"Portal",canalDistribuicao:"COR",codigoOfertaConsultiva:"VIAGEM",identificadorRepresentante:"P5005J"}),setStorage("jsonServicos",{}),setStorage("caminhoTomado",[0,1]),setStorage("entradaConsultivo",{consultivo:{segmento:"eds",codigoOfertaConsultiva:"VIAGEM",canalDistribuicao:"COR",identificadorRepresentante:"",meioComercializacao:"Portal",entradaNegocio:"SFC",voltar:!1},acao:"CONTRATAR"}),setStorage("jsonResponseCalculo",e);let m=[{id:"PRODUTO",conteudo:"VIAGEM"},{id:"DICIO_NOME",conteudo:o.nome},{id:"TIPO_VIAGEM",conteudo:o.tipoViagem},{id:"ORIGEM",conteudo:document.querySelector("#etapa1-origem").value},{id:"DESTINO",conteudo:document.querySelector("#etapa1-destino").value},{id:"DICIO_DATA_SAIDA",conteudo:getDateSaida()},{id:"DICIO_DATA_RETORNO",conteudo:getDateRetorno()},{id:"DICIO_AVENTURA",conteudo:o.praticaEsportesAventura},{id:"DICIO_MOTOCICLETA",conteudo:o.utilizaraMotocicleta},{id:"DICIO_QTD_JOVENS",conteudo:o.passageirosNaoIdosos},{id:"DICIO_QTD_IDOSOS",conteudo:o.passageirosIdosos},{id:"DICIO_CORRETAGEM",conteudo:o.percentual}];setStorage("dadosUsuario",m),setStorage("jsonEntradaCalculo",{orcamento:null,consultivo:{codigoOfertaConsultiva:"VIAGEM",canalDistribuicao:"COR",identificadorRepresentante:"",meioComercializacao:"SFC",respostas:m}}),tratamentoOfertas(JSON.stringify(e))}function setStorage(e,o){window.localStorage.setItem(e,JSON.stringify(o))}function redirectToPortal(){let e=window.location.href.toLowerCase().includes("/lotusvida")?"/lotusvida":"/apex",o=JSON.parse(window.localStorage.getItem("entradaConsultivo"));o.consultivo.voltar=!0;let a=`https://${window.location.hostname}${e}/formularioSniper?dados=${JSON.stringify(o)}`;window.location.href=a}function getFromStorage(){let e=window.localStorage.getItem("payload"),o=document.querySelector("#contractId");if(o=null!=o?o.value:null!=document.querySelector("#contractS")?JSON.parse(document.querySelector("#contractS").value).Id:null,null!=e){if(o!=JSON.parse(e).idContrato)return;confirm("Existem modificações locais para este contrato, deseja utilizar?")&&recoverLocal()}}function recoverLocal(){let e=JSON.parse(window.localStorage.getItem("payload"));e.inicioVigencia&&(document.querySelector("#etapa1-iniciovigencia").value=e.inicioVigencia.split("-").reverse().join("/")),e.finalVigencia&&(document.querySelector("#etapa1-finalvigencia").value=e.finalVigencia.split("-").reverse().join("/")),setInitialDate(),setFinalDate()}function clearLocal(){window.localStorage.removeItem("payload")}function geraOrcamento(){let e=document.getElementById("responseCalculo");if(""!=e.value&&(e=JSON.parse(e.value),!e.message)){{let o="Passageiros de 71 a 90 anos",a="Passageiros até 70 anos";e.ofertas.forEach(e=>{let t={};e.orcamento.contratantes[0].grupos.forEach(e=>t[e.nome]=e.qtdeVidas),t[a]||e.orcamento.contratantes[0].grupos.push({coberturas:e.orcamento.contratantes[0].grupos[0].coberturas,nome:a,numero:2,qtdeVidas:0,tipoCalculo:null}),t[o]||e.orcamento.contratantes[0].grupos.push({coberturas:e.orcamento.contratantes[0].grupos[0].coberturas,nome:o,numero:2,qtdeVidas:0,tipoCalculo:null})})}setupLocalStorageData(e),redirectToPortal()}}function isNumberKey(e){var o=e.which?e.which:event.keyCode;return!(o>31&&(o<48||o>57))}