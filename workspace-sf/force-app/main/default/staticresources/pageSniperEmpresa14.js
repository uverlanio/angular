var infoPayload;function disabledButtons(o){console.log("disabledButtons"),document.getElementById("btn-confirmar").style.display="block",document.getElementById("divParcela").style.display="block",resetErrorMsg()}function retornoEnviaEmail(){console.log("retornoEnviaEmail");var o=document.querySelector("#retornoEmail").value;console.log("Retorno email? "+o)}function trocaPayload(o){console.log("trocaPayload"),"Enviar por e-mail"==o?(document.getElementById("btn-confirmar").style.display="block",document.getElementById("testePop").style.display="none",solicitaOrquestrador("Enviar por e-mail"),alert("Enviaremos o link para seu email assim que a proposta for confirmada."),resetDisplay()):"Preencher agora"==o&&(solicitaOrquestrador("Preencher agora"),buttons()),infoPayload=o}function decodeHTML(o){console.log("decodeHTML");let e=document.createElement("textarea");return e.innerHTML=o,e.value}function buttons(){console.log("buttons"),solicitaOrquestrador("Preencher agora"),document.getElementById("btn-confirmar").style.display="block","none"==document.getElementById("testePop").style.display||""==document.getElementById("testePop").style.display||null==document.getElementById("testePop").style.display?processarOrcamento():resetDisplay()}function esvaziarElementosCartao(){console.log("esvaziarElementosCartao"),document.querySelectorAll(".blocoPagamentoCartao").forEach(o=>{o.style.display="none",o.childNodes.forEach(o=>{o.innerHTML=""})})}function exibirModalPagamento(o){console.log("exibirModalPagamento");const e=document.getElementById("testePop"),t=document.getElementById("testeModal");e.style.display="block",e.style.textAlign="center",t.innerHTML=`<iframe src=${o} height=1100px width=700px frameborder=0 scrolling=no style="overflow-x:hidden;overflow-y:hidden;"></iframe>`}function resetDisplay(o=null,e=null){if(console.log("resetDisplay"),document.getElementById("testePop").style.display="none",document.getElementById("btn-confirmar").style.display="block",document.getElementById("divCartao").style.display="none",document.getElementById("divParcela").style.display="none",null!=o&&(console.log("isPorto",e),!o)){let o=e?"O cartão informado é um cartão Porto. Por favor, altere a forma de pagamento para cartão Porto Seguro.":"O cartão informado não é um cartão Porto. Por favor altere a forma de pagamento para cartão de crédito.";resetTipoPagamento(),setErrorMsg(o)}}function resetTipoPagamento(){console.log("resetTipoPagamento");const o=document.querySelector("#TIPOPAGAMENTO");Array.from(o.options).forEach(o=>{console.log("opt",o),0==o.value&&(o.selected=!0)}),M.FormSelect.init(o)}function habilitaEscolhaDaParcela(){console.log("habilitaEscolhaDaParcela"),document.getElementById("divCartao").style.display="block",document.getElementById("divParcela").style.display="block"}function atualizarCamposCartao(o){console.log("atualizarCamposCartao");const e=["cardNumber","cardName","cardExpiry"];["Enviar por e-mail","Enviar por SMS"].includes(o)?(e.forEach(o=>{const e=document.getElementById(o);e&&(e.required=!1)}),ocultarElementos(["pag","cvv"])):e.forEach(o=>{const e=document.getElementById(o);e&&(e.required=!0)})}function ocultarElementos(o){o.forEach(ocultarElemento)}function ocultarElemento(o){const e=document.getElementById(o);e&&(e.style.display="none")}function desativarCamposCartao(){console.log("desativarCamposCartao"),toggleCampoObrigatorio("cardNumber",!1),toggleCampoObrigatorio("cardName",!1),toggleCampoObrigatorio("cardExpiry",!1),ocultarElemento("pag"),ocultarElemento("cvv")}function ativarCamposCartao(){console.log("ativarCamposCartao"),toggleCampoObrigatorio("cardNumber",!0),toggleCampoObrigatorio("cardName",!0),toggleCampoObrigatorio("cardExpiry",!0)}function toggleCampoObrigatorio(o,e){console.log("toggleCampoObrigatorio");const t=document.getElementById(o);t&&(t.required=e)}function setErrorMsg(o){console.log("setErrorMsg");let e=document.querySelectorAll(".ErroTipoPagMessage");Array.from(e).forEach(e=>{e.innerHTML=o,e.style.display="block"})}function resetErrorMsg(){console.log("resetErrorMsg");let o=document.querySelectorAll(".ErroTipoPagMessage");Array.from(o).forEach(o=>{o.innerHTML="",o.style.display="none"})}
function retornoCallOrchestrator(){console.log("retornoCallOrchestrator"),stringOrchestrator=document.querySelector("#retornoOrchestrator").value,console.log("empresa14? "+stringOrchestrator)}function processarOrcamento(){console.log("processarOrcamento");const o=JSON.parse(window.localStorage.getItem("jsonResponseCalculo")),e=o.ofertas[0].orcamento.ramoSeguro,a=o.ofertas[0].orcamento.rotulo,r=window.localStorage.getItem("ofertaSelecionada"),t=o.ofertas[0].parcelamentos.length;document.getElementById("btn-confirmar").style.display="none",Visualforce.remoting.Manager.invokeAction(controllerActionAptlmk,e,a,r,t,(function(o){if(console.log("resultado request***: ",o),o){const e=JSON.parse(decodeHTML(o)).link,a=e.split("&token=")[1];window.localStorage.setItem("tokenAPI",a),esvaziarElementosCartao(),exibirModalPagamento(e),registrarMensagem()}else alert("PortoPay não respondeu a tempo, por favor tente daqui alguns minutos"),resetDisplay()}))}function registrarMensagem(){console.log("registrarMensagem"),window.addEventListener("message",o=>{const e=JSON.parse(o.data.message);console.log("dados cartão",e),localStorage.setItem("isCartaoPorto",e.cartaoPorto),setTimeout(()=>{resetDisplay(validaBandeiraCartaoPagamento(),e.cartaoPorto)},1e3)})}function solicitaOrquestrador(o){console.log("solicitaOrquestrador"),atualizarCamposCartao(o);const e=coletarDados(),a=window.localStorage.getItem("ofertaSelecionada");adicionaStorageOrquestrador("api",montarInformacoes(e,retornaObjetoOferta(),a))}function coletarDados(){console.log("coletarDados");const o={nome:document.querySelector('input[name="DICIO_NOME"]').value.toUpperCase(),cpf:document.querySelector('input[name="CPF"]').value,email:document.querySelector('input[name="EMAIL"]').value,celular:document.querySelector('input[name="CELULARCLIENTE"]').value};return Array.from(document.getElementsByName("RESPFINANCEIRO")).some(o=>o.checked&&"Nao"===o.value)&&(o.nome=document.querySelector('input[name="NOMERESP"]').value.toUpperCase(),o.cpf=document.querySelector('input[name="CPFRESP"]').value,o.email=document.querySelector('input[name="EMAILRESPFIN"]').value,o.celular=document.querySelector('input[name="CELULARRESPFIN"]').value),adicionaStorageOrquestrador("email",o.email),adicionaStorageOrquestrador("celular",o.celular),o}function montarInformacoes(o,e,a){console.log("montarInformacoes");const r=obterPlanoPagamento(e.parcelamentos),t=document.querySelector('select[name="TIPOPAGAMENTO"]').value,n=obterQuantidadeParcelas(e.parcelamentos,t);return{idExterno:a,nome:o.nome,documento:{tipo:"CPF",numero:o.cpf},produto:{codigo:e.orcamento.codigoProdutoVida,descricao:e.orcamento.rotulo},metadados:{codigo_ramo:e.orcamento.ramoSeguro.toString(),parcela:n},planoPagamento:r}}function obterQuantidadeParcelas(o,e){console.log("obterQuantidadeParcelas");const a=o.find(o=>o.codigo===e);return a?a.qtdParcelas.toString():"0"}function obterPlanoPagamento(o){return Array.from(document.querySelector(".planoParcelamentos").options).slice(1).map((e,a)=>criarOpcaoPagamento(o[a],e.text))}function criarOpcaoPagamento(o,e){return{valorTotal:calcularValorTotal(o),parcelas:o.qtdParcelas,descricao:e}}function calcularValorTotal(o){return console.log("calcularValorTotal"),Number.parseFloat(o.valorPrimeiraParcela)+(o.qtdParcelas-1)*Number.parseFloat(o.valorDemaisParcelas)}function obterDadosCliente(){console.log("obterDadosCliente");let o=getValorInput("DICIO_NOME").toUpperCase(),e=getValorInput("CPF"),a=getValorInput("EMAIL"),r=getValorInput("CELULARCLIENTE");return isResponsavelFinanceiro()&&(o=getValorInput("NOMERESP").toUpperCase(),e=getValorInput("CPFRESP"),a=getValorInput("EMAILRESPFIN"),r=getValorInput("CELULARRESPFIN")),{nome:o,cpf:e,email:a,celular:r}}function getValorInput(o){return console.log("getValorInput"),document.querySelector(`input[name="${o}"]`).value}function obterDadosProduto(){console.log("obterDadosProduto");const o=retornaObjetoOferta();return{codigoRamo:o.orcamento.ramoSeguro.toString(),codigoProduto:o.orcamento.codigoProdutoVida,descricaoProduto:o.orcamento.rotulo,parcelamentos:o.parcelamentos}}function armazenarDadosOrquestrador(o,e){console.log("armazenarDadosOrquestrador"),adicionaStorageOrquestrador("email",o.email),adicionaStorageOrquestrador("celular",o.celular),adicionaStorageOrquestrador("api",e)}function adicionaStorageOrquestrador(o,e){console.log("adicionaStorageOrquestrador");const a=JSON.parse(window.localStorage.getItem("jsonOrquestrador"))||{},r=a.api||{};let t={formaInfoCartao:a.formaInfoCartao||"",email:a.email||"",celular:a.celular||"",api:{...r}};"formaInfoCartao"===o?t.formaInfoCartao=e:"email"===o?t.email=e:"celular"===o?t.celular=e:"api"===o&&(t.api=e),r.metadados&&(t.api.metadados={parcela:r.metadados.parcela||""}),r.planoPagamento&&(t.api.planoPagamento=[...r.planoPagamento]),r.documento&&(t.api.documento={tipo:r.documento.tipo||"",numero:r.documento.numero||""}),r.produto&&(t.api.produto={codigo:r.produto.codigo||"",descricao:r.produto.descricao||""}),t.api.idExterno=r.idExterno||"",t.api.nome=r.nome||"",t.api.codigo_ramo=r.codigo_ramo||"",window.localStorage.setItem("jsonOrquestrador",JSON.stringify(t))}function retornaObjetoOferta(){console.log("retornaObjetoOferta");const o=window.localStorage.getItem("ofertaSelecionada"),e=JSON.parse(window.localStorage.getItem("jsonResponseCalculo"));for(let a=0;a<e.ofertas.length;a++)if(o==e.ofertas[a].orcamento.numeroOrcamento)return e.ofertas[a];return null}function btnEnviarPorEmail(o){console.log("btnEnviarPorEmail"),desativarCamposCartao();const e=document.getElementById("EMAIL").value,a=document.getElementById("EMAILRESPFIN").value,r=document.querySelector('input[name="DICIO_NOME"]').value.toUpperCase(),t=JSON.parse(window.localStorage.getItem("conjuntosJson")).identificadorRepresentante,n=document.querySelector('select[name="planoParcelamentos"]'),l=(n.options[n.selectedIndex].dataset.valortotal,obterPremioTotal()),c=obterResponsavelFinanceiro(),i=criarJsonRequest(o,l);console.log("jsonRequestString****",i),enviarPropostaViaEmail(i,e,a,r,o,t,c)}function obterPremioTotal(){console.log("obterPremioTotal");return JSON.parse(window.localStorage.getItem("jsonResponseCalculo")).ofertas[0].retornosCalculo[0].precificacao.premio.total}function obterResponsavelFinanceiro(){console.log("obterResponsavelFinanceiro");const o=document.getElementById("responsavel-div").querySelectorAll("input");let e="";return o.forEach(o=>{o.checked&&(e=o.value)}),e}function criarJsonRequest(o,e){return console.log("criarJsonRequest"),JSON.stringify({expiraEm:100800,configuracaoPagamento:{produto:{codProduto:"8b4da283-389d-47d5-83f0-fd8fc6d02708",nomeVertical:"Vida e Previdência",nomeProduto:"Vida do Seu Jeito",icone:"vida_previdencia"},cartaoCredito:{},contratos:[{descricao:"",valorTotal:e,idExterno:o}]}})}function enviarPropostaViaEmail(o,e,a,r,t,n,l){console.log("enviarPropostaViaEmail"),Visualforce.remoting.Manager.invokeAction(controllerActionLink,o,(function(o,c){if(c.status){const c=JSON.parse(o).link;console.log("jsonLink****",c);const i={email:"Sim"===l?e:a,link:c,nome:r,proposta:t,corretor:n};console.log("jsonEmail***",i),callSendEmailLink(JSON.stringify(i)),document.getElementById("btn-confirmar").style.display="block"}else console.error("exception"===c.type?c.type:c.message)}),{escape:!1})}
function validaBandeiraCartaoPagamento(){console.log("validaBandeiraCartaoPagamento");const e=localStorage.getItem("isCartaoPorto");let a=document.querySelector("#TIPOPAGAMENTO");return console.log("validar >>> isPorto - tipo pag",e,a.value,(98==parseInt(a.value)||97==parseInt(a.value))&&"false"==e||(70==parseInt(a.value)||62==parseInt(a.value))&&"true"==e),(98!=parseInt(a.value)&&97!=parseInt(a.value)||"false"!=e)&&(70!=parseInt(a.value)&&62!=parseInt(a.value)||"true"!=e)||(console.log("entrou no if"),!1)}function isPagamentoDigital(e){return console.log("isPagamentoDigital"),"Enviar por e-mail"===e||"Enviar por SMS"===e}function isResponsavelFinanceiro(){return console.log("isResponsavelFinanceiro"),Array.from(document.getElementsByName("RESPFINANCEIRO")).some(e=>e.checked&&"Nao"===e.value)}
(function(){!function(){"use strict";if(!self.fetch){i.prototype.append=function(e,t){e=r(e),t=o(t);var n=this.map[e];n||(n=[],this.map[e]=n),n.push(t)},i.prototype.delete=function(e){delete this.map[r(e)]},i.prototype.get=function(e){var t=this.map[r(e)];return t?t[0]:null},i.prototype.getAll=function(e){return this.map[r(e)]||[]},i.prototype.has=function(e){return this.map.hasOwnProperty(r(e))},i.prototype.set=function(e,t){this.map[r(e)]=[o(t)]},i.prototype.forEach=function(e){var t=this;Object.getOwnPropertyNames(this.map).forEach((function(n){e(n,t.map[n])}))};var e="FileReader"in self&&"Blob"in self&&function(){try{return new Blob,!0}catch(e){return!1}}(),t="FormData"in self,n=["DELETE","GET","HEAD","OPTIONS","POST","PUT"];f.call(c.prototype),f.call(h.prototype),self.Headers=i,self.Request=c,self.Response=h,self.fetch=function(t,n){var r;return r=c.prototype.isPrototypeOf(t)&&!n?t:new c(t,n),new Promise((function(t,n){var o=new XMLHttpRequest;"cors"===r.credentials&&(o.withCredentials=!0),o.onload=function(){var e=1223===o.status?204:o.status;if(e<100||e>599)n(new TypeError("Network request failed"));else{var r={status:e,statusText:o.statusText,headers:d(o),url:"responseURL"in o?o.responseURL:/^X-Request-URL:/m.test(o.getAllResponseHeaders())?o.getResponseHeader("X-Request-URL"):void 0},i="response"in o?o.response:o.responseText;t(new h(i,r))}},o.onerror=function(){n(new TypeError("Network request failed"))},o.open(r.method,r.url,!0),"responseType"in o&&e&&(o.responseType="blob"),r.headers.forEach((function(e,t){t.forEach((function(t){o.setRequestHeader(e,t)}))})),o.send(void 0===r._bodyInit?null:r._bodyInit)}))},self.fetch.polyfill=!0}function r(e){if("string"!=typeof e&&(e=e.toString()),/[^a-z0-9\-#$%&'*+.\^_`|~]/i.test(e))throw new TypeError("Invalid character in header field name");return e.toLowerCase()}function o(e){return"string"!=typeof e&&(e=e.toString()),e}function i(e){this.map={};var t=this;e instanceof i?e.forEach((function(e,n){n.forEach((function(n){t.append(e,n)}))})):e&&Object.getOwnPropertyNames(e).forEach((function(n){t.append(n,e[n])}))}function s(e){if(e.bodyUsed)return Promise.reject(new TypeError("Already read"));e.bodyUsed=!0}function a(e){return new Promise((function(t,n){e.onload=function(){t(e.result)},e.onerror=function(){n(e.error)}}))}function u(e){var t=new FileReader;return t.readAsArrayBuffer(e),a(t)}function f(){return this.bodyUsed=!1,this._initBody=function(n){if(this._bodyInit=n,"string"==typeof n)this._bodyText=n;else if(e&&Blob.prototype.isPrototypeOf(n))this._bodyBlob=n;else if(t&&FormData.prototype.isPrototypeOf(n))this._bodyFormData=n;else{if(n)throw new Error("unsupported BodyInit type");this._bodyText=""}},e?(this.blob=function(){var e=s(this);if(e)return e;if(this._bodyBlob)return Promise.resolve(this._bodyBlob);if(this._bodyFormData)throw new Error("could not read FormData body as blob");return Promise.resolve(new Blob([this._bodyText]))},this.arrayBuffer=function(){return this.blob().then(u)},this.text=function(){var e,t,n=s(this);if(n)return n;if(this._bodyBlob)return e=this._bodyBlob,(t=new FileReader).readAsText(e),a(t);if(this._bodyFormData)throw new Error("could not read FormData body as text");return Promise.resolve(this._bodyText)}):this.text=function(){var e=s(this);return e||Promise.resolve(this._bodyText)},t&&(this.formData=function(){return this.text().then(l)}),this.json=function(){return this.text().then(JSON.parse)},this}function c(e,t){var r,o;if(t=t||{},this.url=e,this.credentials=t.credentials||"omit",this.headers=new i(t.headers),this.method=(r=t.method||"GET",o=r.toUpperCase(),n.indexOf(o)>-1?o:r),this.mode=t.mode||null,this.referrer=null,("GET"===this.method||"HEAD"===this.method)&&t.body)throw new TypeError("Body not allowed for GET or HEAD requests");this._initBody(t.body)}function l(e){var t=new FormData;return e.trim().split("&").forEach((function(e){if(e){var n=e.split("="),r=n.shift().replace(/\+/g," "),o=n.join("=").replace(/\+/g," ");t.append(decodeURIComponent(r),decodeURIComponent(o))}})),t}function d(e){var t=new i;return e.getAllResponseHeaders().trim().split("\n").forEach((function(e){var n=e.trim().split(":"),r=n.shift().trim(),o=n.join(":").trim();t.append(r,o)})),t}function h(e,t){t||(t={}),this._initBody(e),this.type="default",this.url=null,this.status=t.status,this.ok=this.status>=200&&this.status<300,this.statusText=t.statusText,this.headers=t.headers instanceof i?t.headers:new i(t.headers),this.url=t.url||""}}(),function(e,t){"use strict";if(!e.setImmediate){var n,r,o,i,s,a=1,u={},f=!1,c=e.document,l=Object.getPrototypeOf&&Object.getPrototypeOf(e);l=l&&l.setTimeout?l:e,"[object process]"==={}.toString.call(e.process)?n=function(){var e=d(arguments);return process.nextTick(h(p,e)),e}:!function(){if(e.postMessage&&!e.importScripts){var t=!0,n=e.onmessage;return e.onmessage=function(){t=!1},e.postMessage("","*"),e.onmessage=n,t}}()?e.MessageChannel?((o=new MessageChannel).port1.onmessage=function(e){p(e.data)},n=function(){var e=d(arguments);return o.port2.postMessage(e),e}):c&&"onreadystatechange"in c.createElement("script")?(r=c.documentElement,n=function(){var e=d(arguments),t=c.createElement("script");return t.onreadystatechange=function(){p(e),t.onreadystatechange=null,r.removeChild(t),t=null},r.appendChild(t),e}):n=function(){var e=d(arguments);return setTimeout(h(p,e),0),e}:(i="setImmediate$"+Math.random()+"$",s=function(t){t.source===e&&"string"==typeof t.data&&0===t.data.indexOf(i)&&p(+t.data.slice(i.length))},e.addEventListener?e.addEventListener("message",s,!1):e.attachEvent("onmessage",s),n=function(){var t=d(arguments);return e.postMessage(i+t,"*"),t}),l.setImmediate=n,l.clearImmediate=y}function d(e){return u[a]=h.apply(void 0,e),a++}function h(e){var t=[].slice.call(arguments,1);return function(){"function"==typeof e?e.apply(void 0,t):new Function(""+e)()}}function p(e){if(f)setTimeout(h(p,e),0);else{var t=u[e];if(t){f=!0;try{t()}finally{y(e),f=!1}}}}function y(e){delete u[e]}}(new Function("return this")()),function(e){"use strict";var t="[[PromiseStatus]]",n="[[PromiseValue]]",r=e.setImmediate||require("timers").setImmediate,o=Array.isArray||function(e){return"[object Array]"==Object.prototype.toString.call(e)};function i(e){this["[[OriginalError]]"]=e}function s(e){return e instanceof i}function a(e){return"function"==typeof e}function u(e){return e instanceof w}function f(e){return e}function c(e){throw e}function l(e){delete e["[[OnFulfilled]]"],delete e["[[OnRejected]]"]}function d(e){var t,n=e.length;for(t=0;t<n;t++)e[t]()}function h(e,t,n){var r=p(n);u(r)?r.then(e,t):s(r)?t(r["[[OriginalError]]"]):e(n)}function p(e){var t;if(u(e))return e;if(function(e){return Object(e)===e}(e)){try{t=e.then}catch(e){return new i(e)}if(a(t))return new w((function(n,o){r((function(){try{t.call(e,n,o)}catch(e){o(e)}}))}))}return null}function y(e,r){function o(n){"pending"==e[t]&&m(e,n)}try{r((function(r){"pending"==e[t]&&function e(r,o){var i,a=p(o);u(a)?(r[t]="internal pending",a.then((function(t){e(r,t)}),(function(e){m(r,e)}))):s(a)?m(r,a["[[OriginalError]]"]):(r[t]="fulfilled",r[n]=o,(i=r["[[OnFulfilled]]"])&&i.length&&(l(r),d(i)))}(e,r)}),o)}catch(e){o(e)}}function m(e,r){var o=e["[[OnRejected]]"];e[t]="rejected",e[n]=r,o&&o.length&&(l(e),d(o))}function w(e){if(!u(this))throw new TypeError('constructor Promise requires "new".');this[t]="pending",this[n]=void 0,y(this,e)}w.prototype.then=function(e,o){var i,s=this;return e=a(e)?e:f,o=a(o)?o:c,i=new w((function(a,u){function f(e){var t;try{t=e(s[n])}catch(e){return void u(e)}t===i?u(new TypeError("then() cannot return same Promise that it resolves.")):h(a,u,t)}function c(){r(f,e)}function l(){r(f,o)}switch(s[t]){case"fulfilled":c();break;case"rejected":l();break;default:!function(e,t,n){e["[[OnFulfilled]]"]||(e["[[OnFulfilled]]"]=[],e["[[OnRejected]]"]=[]),e["[[OnFulfilled]]"].push(t),e["[[OnRejected]]"].push(n)}(s,c,l)}}))},w.prototype.catch=function(e){return this.then(f,e)},w.resolve=function(e){var t=p(e);return u(t)?t:new w((function(n,r){s(t)?r(t["[[OriginalError]]"]):n(e)}))},w.reject=function(e){return new w((function(t,n){n(e)}))},w.race=function(e){return new w((function(t,n){var r,i;if(o(e))for(i=e.length,r=0;r<i;r++)h(t,n,e[r]);else n(new TypeError("not an array."))}))},w.all=function(e){return new w((function(t,n){var r,i,a,f,c=0,l=0;if(o(e)){for(i=(e=e.slice(0)).length,f=0;f<i;f++)u(r=p(a=e[f]))?(l++,r.then(function(n){return function(r){e[n]=r,++c==l&&t(e)}}(f),n)):s(r)?n(r["[[OriginalError]]"]):e[f]=a;l||t(e)}else n(new TypeError("not an array."))}))},"undefined"!=typeof module&&module.exports?module.exports=e.Promise||w:e.Promise||(e.Promise=w)}(this)}).call("object"==typeof window&&window||"object"==typeof self&&self||"object"==typeof global&&global||{});