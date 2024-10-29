"use strict";
let ofertaSelecionada;
let cepAtualizado;
let endosso = false; //PLV-4650 INICIO/FIM
let viagem = false;
let individual = false; //PLV-4650 INICIO/FIM
let vg = false; //PLV-4650 INICIO/FIM
let parcelamentoAtual;
let parcelamentoAtualEscolhidoPeloUsuario;
let camposIdade;
let segmento = ''; //PLV-4203 - Início/Fim - Segmento
let antecipaComissaoTransmissao = 0; //PLV-4344 - Início/Fim
let agenciamento = 0; //PLV-4367 - inicio/fim
let listBeneficiarios = []; //PLV-4440 - INICIO/FIM
let mostrarDiv = false; ////RVI-217 - INICIO/FIM

document.addEventListener('DOMContentLoaded', async e => {
    let nomePessoaForm;
    let remover = 0;
    let segurados = 0;

    formatacaoFormularioAPTLMK1(); //TKCL-240 INICIO/FIM
    formatacaoFormularioPortoVidaON2(); //AV-85 INICIO/FIM
    let formProposta = document.querySelector('#formProposta');
    if (formProposta) {
        let ResponseCalculo = JSON.parse(window.localStorage.getItem('jsonResponseCalculo'));
        let codOfertaSelecionada = window.localStorage.getItem('ofertaSelecionada');
        ofertaSelecionada = ResponseCalculo.ofertas.filter(e => e.orcamento.numeroOrcamento == codOfertaSelecionada).shift() || ResponseCalculo.ofertas[0];
        let parcelamentos = [];

        console.log('testeee code ');
        //PLV-4203 - Início - filtrar parcelamento com base nos retornos cálculo
        ofertaSelecionada.retornosCalculo.forEach(rC=>{
            ofertaSelecionada.parcelamentos.forEach(par=>{
                //if(rC.opcao == par.opcao && !par.nomeFormaPagamento.toLowerCase().includes('porto')){ //PLV-4375 - Início/Fim - Condição provisória
                if(rC.opcao == par.opcao){
                    parcelamentos.push(par);
                }
                console.log(rc.codigo + 'testeee rc.codigo');
                //RVI-217 - INICIO
                if((rC.codigo == '62' || rC.codigo == '97') && mostrarDiv == false){
                    document.getElementById("divCartao").style.display = "block";
                }else{
                    document.getElementById("divCartao").style.display = "none";
                }
                //RVI-217 - FIM

            })
        });
        //PLV-4203 - Fim - filtrar parcelamento com base nos retornos calculo

        segmento = ofertaSelecionada.orcamento.segmento.toLowerCase(); //PLV-4203 - Início/Fim - Segmento
        endosso = ofertaSelecionada.orcamento.tipoSeguro.toLowerCase() == 'eds' || false;
        
        //PLV-4488 - INICIO
        //verifica se há valor a restituir
        let restituicao = false;
        let valorRestituicao = 0;
        if(endosso){
            // let descontoAgravoOriginal = JSON.parse(window.localStorage.getItem("jsonResponseCalculo")).ofertas[0].orcamento.contratoOriginal.precificacao.descontoAgravo.filter(e => e.tipo == 'FPG').shift();
            // let retornosCalculo = JSON.parse(window.localStorage.getItem("jsonResponseCalculo")).ofertas[0].retornosCalculo;

            // let descontoAgravo;
            let totalPremio = JSON.parse(window.localStorage.getItem("jsonResponseCalculo")).ofertas[0].retornosCalculo[0].precificacao.premio.total;
            
            // retornosCalculo.forEach(calc => {
            //     let descAtual = calc.precificacao.descontoAgravo.filter(e => e.tipo == descontoAgravoOriginal.tipo).shift();
            //     if (descontoAgravoOriginal.percentual == descAtual.percentual) {
            //         descontoAgravo = descAtual;
            //         totalPremio = calc.precificacao.premio.total;
            //     }
            // });
            if (totalPremio < 0) {
                restituicao = true;
                valorRestituicao = Math.abs(totalPremio);
            }
            checkEndossoPgmt() //PLV-5066 - INICIO/FIM
        }
        //PLV-4488 - FIM

        //inicializaAgenciamento(); //PLV-4367 - inicio/fim

        let percentagensCorretoresFavorecidos = [];
        let percentagensAgentesFavorecidos = [];

        (function iniciaTelaViagem() {
            if (segmento == 'viagem') { //PLV-4203 - Início/Fim - Segmento
                document.getElementById('formularioProposta').remove();
                document.getElementById('formularioPropostaViagem').classList.remove('hidden');
                viagem = true;
            } else if(segmento=='individual'){
                document.getElementById('formularioPropostaViagem').remove();
                document.querySelector('.configSeguroViagem').remove();
                individual = true;
            }else if(segmento=='vg'){
                vg = true;
            }
        }());
        irPasso(0, 2);

        function mascararCampos() {
            function inputHandler(masks, max, event) {
                var c = event.target;
                var v = c.value.replace(/\D/g, '');
                var m = c.value.length > max ? 1 : 0;
                VMasker(c).unMask();
                VMasker(c).maskPattern(masks[m]);
                c.value = VMasker.toPattern(v, masks[m]);
            }
            //PLV-5158 INICIO
            let datasresp = document.querySelectorAll('.dataMask');

            datasresp.forEach(data => {
                data.addEventListener('focusout', event =>
                {
                    let regex = /^(?:(?:31(\/|-|\.)(?:0?[13578]|1[02]))\1|(?:(?:29|30)(\/|-|\.)(?:0?[1,3-9]|1[0-2])\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:29(\/|-|\.)(?:0?2)\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:0?[1-9]|1\d|2[0-8])(\/|-|\.)(?:(?:0?[1-9])|(?:1[0-2]))\4(?:(?:1[6-9]|[2-9]\d)?\d{2})$/ ;
                    let valido = (data.value != '' && data.value != 'undefined' && regex.test(data.value));

                    let strg = data.value;
                    let dataDigitada = new Date(strg.split('/').reverse().join('-'));

                    let today = new Date(new Date().toISOString().slice(0,10));
                    if(dataDigitada <= today && valido == true) {

                        data.classList.remove('invalid');
                        data.classList.add('valid');
                        resetHelper(data);
                        console.log('ENTROU');
                    }
                    else
                    {
                        data.classList.remove('valid');
                        data.classList.add('invalid');
                        buildHelper(data, 'Data inválida');
                    }
                })
            });

            

            // PLV-5158 FIM **/

            let telefones = document.querySelectorAll('.telMask');
            telefones.forEach(tel => {
                tel.addEventListener('input', inputHandler.bind(undefined, ['(99) 9999-99999', '(99) 99999-9999'], 14), false)
                //PLV-5176 INICIO
                tel.addEventListener('focusout', event => {
                let nameField = event.target.name.toString();
                let numTelefone = event.target.value.replace(/[\( \s \) \-]/g, '');
                if(!nameField.includes('TELOPCIONAL')){
                    //PLV-5430 - INÍCIO
                    if( nameField == 'CELULARCLIENTE' || nameField == 'CELULARRESPFIN')
                    {
                        if(numTelefone.length == 11 && parseInt(numTelefone.substring(2, 3)) == 9){
                            event.target.classList.remove('invalid');
                            event.target.classList.add('valid');
                        }
                        else {
                            event.target.classList.remove('valid');
                            event.target.classList.add('invalid');
                            buildHelper(event.target, 'Formato correto: (xx) 9xxxx-xxxx');
                        }
                    }
                    else{
                        if(numTelefone.toString().length >= 10){
                            event.target.classList.remove('invalid');
                            event.target.classList.add('valid');
                        }
                        else{
                            event.target.classList.remove('valid');
                            event.target.classList.add('invalid');
                            buildHelper(event.target, 'Telefone inválido');
                        }
                    }
                    //PLV-5430 - FIM
                }else{
                    if((numTelefone.toString().length >= 10)){
                        event.target.classList.remove('invalid');
                        event.target.classList.add('valid');
                    }else if((numTelefone.toString().length == 0)){
                        event.target.classList.remove('invalid');
                    }else{
                        event.target.classList.remove('valid');
                        event.target.classList.add('invalid');
                        buildHelper(event.target, 'Telefone inválido');     
                    }
                }});
                //PLV-5176 FIM
            });
            let ceps = document.querySelectorAll('.cepMask');
            VMasker(ceps).maskPattern("99999-999");
            let cpf = document.querySelectorAll('.cpfMask');
            VMasker(cpf).maskPattern("999.999.999-99");
            let cnpj = document.querySelectorAll('.cnpjMask');
            VMasker(cnpj).maskPattern("99.999.999/9999-99");
            //PLV-4325 - Início - Ajuste pendente
            let mei = document.querySelectorAll('.meiMask');
            VMasker(mei).maskPattern("99.999.999/9999-99");
            //PLV-43245 - Fim - Ajuste pendente
            let rgs = document.querySelectorAll('.rgMask:not(#NUMERODOCUMENTO)');
            rgs.forEach(e => {
                e.addEventListener('input', event => {
                    if (event.target.value.match(/[0-9]|\.|x|\-|\X/g).length != event.target.value.length) {
                        event.target.value = event.target.value.substring(0, event.target.value.length - 1);
                    }
                });
            });
            let rne = document.querySelectorAll('.rneMask');
            VMasker(rne).maskPattern("A999999d-A");
            let datas = document.querySelectorAll('.dataMask');
            VMasker(datas).maskPattern("99/99/9999");
            let numeros = document.querySelectorAll('.numberMask');
            VMasker(numeros).maskNumber();
            let ddis = document.querySelectorAll('.ddiMask');
            VMasker(ddis).maskPattern('+ 99');
            let ddds = document.querySelectorAll('.dddMask');
            VMasker(ddds).maskPattern('99');
            let textos = document.querySelectorAll('.textMask');
            textos.forEach(e => {
                e.addEventListener('input', event => {
                    //PLV-4834-INICIO-HENRIQUE R. (META)
                    //if (event.target.value.match(/[`!@#$%^&*()_|+\-=?;:",.<>\{\}\[\]\\\/]/gi)) {
                    //    event.target.value = event.target.value.replace(/[`!@#$%&*()_|+\-=?;:",.<>\{\}\[\]\\\/]/gi, '');
                    //}
                    //PLV-4834-FIM-HENRIQUE R. (META)
                    //TKCL-240 INICIO FIX01
                    if (event.target.value.match(/[`!@#$^&*()_|+\-=?;:"<>\{\}\[\]\\\/]/gi)) {
                        event.target.value = event.target.value.replace(/[`!@#$&*()_|+\-=?;:"<>\{\}\[\]\\\/]/gi, '');
                    }
                    //TKCL-240 FIM FIX01
                });
            });
            let alfa = document.querySelectorAll('.alfaMask');
            alfa.forEach(e => {
                e.addEventListener('input', event => {
                    //PLV-4393 - Início
                    if (event.target.value.match(/[0-9]|[A-Z]|\-/gi) == null) {
                        event.target.value = event.target.value.substring(0, event.target.value.length - 1);
                    } else if(event.target.value.match(/[0-9]|[A-Z]|\-/gi).length != event.target.value.length) {
                        event.target.value = event.target.value.substring(0, event.target.value.length - 1);
                    }
                    //PLV-4393 - Fim
                });
                //PLV-5176 INICIO 
                e.addEventListener('blur', event => {
                    event.target.value = event.target.value.slice(0, 5);
                    event.target.value = event.target.value.replace(/[^0-9]+/, '');
                });
                //PLV-5176 FIM 
            });
            let dinheiros = document.querySelectorAll('.moneyMask');
            VMasker(dinheiros).maskMoney({
                precision: 2,
                separator: ',',
                delimiter: '.',
                unit: 'R$',
                zeroCents: true
            });
            let porcentagens = document.querySelectorAll('.percentMask');
            porcentagens.forEach(e => {
                e.addEventListener('input', event => {
                    if (event.target.value.match(/[a-z]/g)) {
                        event.target.value = event.target.value.replace(/[a-z]/g, '').replace(/\%/g, '');
                    }
                    if (parseInt(event.target.value) > 100) {
                        event.target.value = 100;
                    }
                    event.target.value = event.target.value.match(/\%/g) ? event.target.value.replace('\%', '').concat('%') : event.target.value.concat('%');
                });
            });
        }
        mascararCampos();

        (function toogleMaskDoc() {
            let tipoDocumento = document.getElementById('TIPODOCUMENTO');
            if (tipoDocumento) {
                tipoDocumento.addEventListener('change', e => {
                    let docMask = document.getElementById('NUMERODOCUMENTO');

                    function mascaraRG(event) {
                        if (event.target.value.trim()) {
                            if (event.target.value.match(/[0-9]|\.|x|\-|\X/g)) {
                                if (event.target.value.match(/[0-9]|\.|x|\-|\X/g).length != event.target.value.length) {
                                    event.target.value = event.target.value.substring(0, event.target.value.length - 1);
                                }
                            }
                        }
                    }

                    //PLV-4440 - INICIO
                    if (tipoDocumento.value == 'rg') {
                        let newDocMask = docMask.cloneNode(true);
                        newDocMask.value = '';
                        newDocMask.addEventListener('input', mascaraRG);
                        docMask.parentNode.replaceChild(newDocMask, docMask);
                    } else if(tipoDocumento.value == 'rne') {
                        let newDocMask = docMask.cloneNode(true);
                        newDocMask.value = '';
                        VMasker(newDocMask).maskPattern("A999999-A");
                        docMask.parentNode.replaceChild(newDocMask, docMask);
                    }
                    else if(tipoDocumento.value == 'cnh'){
                        let newDocMask = docMask.cloneNode(true);
                        newDocMask.value = '';
                        VMasker(newDocMask).maskPattern("99999999999");
                        docMask.parentNode.replaceChild(newDocMask, docMask);
                    }
                    else{
                        let newDocMask = docMask.cloneNode(true);
                        newDocMask.value = '';
                        newDocMask.addEventListener('input', event => {
                            //PLV-5131 - INICIO
                            /*if (event.target.value.match(/[0-9]/g)) {
                                event.target.value = event.target.value.replace(/[0-9]/g, '');
                            }*/
                            //PLV-5131 - FIM 
                        });
                        docMask.parentNode.replaceChild(newDocMask, docMask);
                    }
                    //PLV-4440 - Fim
                });
            }
        }());

        (function toogleCNPJMEI() {
            let tipoEmpresa = document.getElementById('TIPOEMPRESA');
            if(tipoEmpresa) {
                tipoEmpresa.addEventListener('change', e => {
                    let inputMei = document.querySelector('#MEIEMPRESA');
                    let inputCnpj = document.querySelector('#CNPJEMPRESA');
                    if(inputMei && inputCnpj){
                        if (e.target.value == 'mei') {
                            inputMei.parentNode.classList.remove('hidden');
                            inputCnpj.parentNode.classList.add('hidden');
                            !inputMei.hasAttribute('required') ? inputMei.setAttribute('required','true') : false;
                            inputCnpj.hasAttribute('required') ? inputCnpj.removeAttribute('required') : false;
                        } else if (e.target.value == 'cnpj') {
                            inputCnpj.parentNode.classList.remove('hidden');
                            inputMei.parentNode.classList.add('hidden');
                            inputMei.hasAttribute('required') ? inputMei.removeAttribute('required') : false;
                            !inputCnpj.hasAttribute('required') ? inputCnpj.setAttribute('required','true') : false;
                        } else {
                            inputMei.parentNode.classList.add('hidden');
                            inputCnpj.parentNode.classList.add('hidden');
                            inputMei.hasAttribute('required') ? inputMei.removeAttribute('required') : false;
                            inputCnpj.hasAttribute('required') ? inputCnpj.removeAttribute('required') : false;
                        }
                    }
                });
            }
        }());

        

        function progPep() {
            let peps = document.querySelectorAll('.pepInput');

            peps.forEach((e, i) => {
                e.addEventListener('input', event => {
                    let prox = closestByClass(event.target, 'propPep').querySelector('.proxPep');
                    if (event.target.value == 'RelacionamentoProximo') {
                        prox.classList.add('on');
                        prox.querySelectorAll('input, select').forEach(elem => {
                            elem.setAttribute('required', 'true');
                        })
                    } else {
                        prox.classList.remove('on');
                        prox.querySelectorAll('input, select').forEach(elem => {
                            elem.removeAttribute('required');
                            // console.log('elem.tagName');
                            // console.log(elem.tagName);
                            elem.classList.remove('invalid');
                            if (elem.tagName == 'SELECT')
                                elem.children[0].selected = 'selected';
                            else
                                elem.value = '';

                        })
                        inicializaSelects();
                    }

                });
            });
        }
        progPep();

        function inicializaProfissao() {
            console.log('aqui?');
            let entradaServicos = JSON.parse(window.localStorage.getItem('jsonServicos'));
            if (Object.keys(entradaServicos).length > 0) {
                let servicos = {
                    data: {},
                };
                let retornoServico = entradaServicos.DICIO_PROFISSAO; //PLV-4393 - Início/Fim
                //PLV-4324 - Início
                if(retornoServico && retornoServico.itens){ //PLV-4600
                    retornoServico.itens.forEach(item => servicos.data["" + item.rotulo] = null);
                    let inputs = document.querySelectorAll('.profissaoInput');
                    inputs.forEach(input => {
                        // input.value = '1';
                        input.addEventListener('change', (event) => {
                            let validaServico = retornoServico.itens.filter(item => item.rotulo == event.target.value);
                            input.dataset.valor = validaServico.length > 0 ? validaServico[0].codigo : '0';
                        });
                    });
                    M.Autocomplete.init(inputs, servicos);
                }
                //PLV-4324 - Fim
            }
        }
        inicializaProfissao();

        var typingTimer; //PLV-4475
        const doneTypingInterval = 2000; //PLV-4475

        function gerarFavorecido(section, tipoRemuneracao, logado = false) {
            let susepEndosso = null;
            if (ofertaSelecionada && endosso && ofertaSelecionada.orcamento.susep!= null) {
                susepEndosso = ofertaSelecionada.orcamento.susep
            }
            let susep = susepEndosso != null ? susepEndosso : JSON.parse(window.localStorage.getItem('conjuntosJson')).identificadorRepresentante;
            //console.log('susep', susep);
            //console.log('ResponseCalculo', ResponseCalculo);
            let cliente = JSON.parse(window.localStorage.getItem('entradaConsultivo')).consultivo.Cliente;
            let resetaPercentagem = new Event('input', {
                'bubbles': true,
                'cancelable': true
            });

            let corretoresFavorecidos = document.querySelectorAll('.corretorFavorecido').length;
            let contadorValoresCorretores = 0;
            let porcentagensCorretores = document.querySelectorAll('.corretorFavorecido input[type="range"]');
            let valoresCorretores = [];
            if (porcentagensCorretores.length > 0) {
                porcentagensCorretores.forEach(input => {
                    valoresCorretores.push(input.value);
                    contadorValoresCorretores += parseInt(input.value);
                });
            }
            let agentesFavorecidos = document.querySelectorAll('.agenteFavorecido').length;
            let contadorValoresAgentes = 0;
            let porcentagensAgentes = document.querySelectorAll('.agenteFavorecido input[type="range"]');
            let valoresAgentes = [];
            porcentagensAgentes.forEach(input => {
                valoresAgentes.push(input.value);
                contadorValoresAgentes += parseInt(input.value);
            });
            if (document.querySelector('.warningAddFavorecido')) {
                document.querySelector('.warningAddFavorecido').remove();
            }
            /* PLV-4475 - INÍCIO */
            if (document.querySelector('.warningPercentualFavorecido')) {
                document.querySelector('.warningPercentualFavorecido').remove();
            }
            /* PLV-4475 - FIM */
            if (tipoRemuneracao == 'CORRETAGEM') {

                let row = document.createElement('div');
                row.classList.add('row');
                row.classList.add('corretorFavorecido');
                logado ? row.classList.add('obrigatorio') : false;
                let colSusep = document.createElement('div');
                colSusep.classList.add('col');
                colSusep.classList.add('s5');
                colSusep.classList.add('input-field');
                let inputSusep = document.createElement('input');
                //inputSusep.classList.add('validate'); //PLV-4475
                inputSusep.type = 'text';
                inputSusep.id = 'SUSEPFAV' + corretoresFavorecidos;
                inputSusep.name = 'SUSEPFAV' + corretoresFavorecidos;
                inputSusep.value = logado ? susep : '';
                cliente ? inputSusep.setAttribute('disabled', 'true') : logado ? inputSusep.setAttribute('disabled', 'true') : false;
                let labelSusep = document.createElement('label');
                labelSusep.setAttribute('for', "SUSEPFAV" + corretoresFavorecidos);
                labelSusep.innerHTML = 'Susep Corretor';
                 //PLV-4475 - Início
                 inputSusep.addEventListener('keyup', function (e) {
                    clearTimeout(typingTimer);
                    typingTimer = setTimeout(function () { buscaCorretor(e.target); }, doneTypingInterval);
                    
                    //PLV-5158 Início
                    const input = e.target;
                    input.value = input.value.toUpperCase();
                    //PLV-5158 Fim
                });
                inputSusep.addEventListener('keydown', function () {
                    clearTimeout(typingTimer);
                });
                inputSusep.addEventListener('blur', function (e) { 
                    clearTimeout(typingTimer);
                    buscaCorretor(e.target); 
                });
                let labelErro = document.createElement('span');
                labelErro.classList.add("helper-text");
                labelErro.setAttribute("data-error","Susep não localizada");
                //PLV-4475 - Fim
                let colPercent = document.createElement('div');
                colPercent.classList.add('col');
                colPercent.classList.add('s4');
                colPercent.classList.add('input-field');
                colPercent.classList.add('percentagemFavorecido');
                let inputPercent = document.createElement('input');
                inputPercent.type = 'range';
                inputPercent.id = 'PERCENTFAV' + corretoresFavorecidos;
                inputPercent.name = 'PERCENTFAV' + corretoresFavorecidos;
                inputPercent.min = 1;
                inputPercent.max = 100;
                cliente ? inputPercent.setAttribute('disabled', 'true') : false;
                inputPercent.addEventListener('input', reajustarPercentagemFavorecidos);
                inputPercent.addEventListener('input', setIndicatorPercentagemFavorecidos);
                if (corretoresFavorecidos == 0) inputPercent.value = 100;
                else if (contadorValoresCorretores >= 100) {
                    criarExcessaoFavorecidos(section);
                    return false;
                } else inputPercent.value = 100 - contadorValoresCorretores;
                let labelPercent = document.createElement('label');
                labelPercent.setAttribute('for', "PERCENTFAV" + corretoresFavorecidos);
                labelPercent.innerHTML = 'Percentual do favorecido';
                let indicatorPercent = document.createElement('div');
                indicatorPercent.classList.add('indicator');

                let colLider = document.createElement('div');
                colLider.classList.add('col');
                colLider.classList.add('s3');
                colLider.classList.add('input-field');
                let inputLider = document.createElement('div');
                inputLider.classList.add('switch');
                inputLider.classList.add('input-field');

                let input = document.createElement('input');
                input.type = 'checkbox';
                input.id = 'LIDERFAV' + corretoresFavorecidos;
                input.name = 'LIDERFAV' + corretoresFavorecidos;
                input.checked = logado ? true : false;
                cliente ? input.setAttribute('disabled', 'true') : false;
                
                //PLV-4475 - Início
                input.addEventListener('change', event => {
                    if(event.target.checked) {
                        let inputs = document.querySelectorAll('.listacorretores .row.corretorFavorecido input[type="checkbox"]');
                        [].forEach.call(inputs, (i)=>{
                            if(i != event.target && i.checked){
                                i.checked = false;
                            }
                        });
                    } else {
                        event.target.checked = true;
                    }
                 });
                //PLV-4475 - Fim

                let titleLider = document.createElement('span')
                titleLider.innerHTML = 'Corretor lider?';
                let labelForLider = document.createElement('label');
                labelForLider.innerHTML = 'Não <span class="lever"></span> Sim';
                inputLider.appendChild(titleLider);
                labelForLider.insertBefore(input, labelForLider.firstChild);
                inputLider.appendChild(labelForLider);
                colLider.appendChild(inputLider);

                if (!section.querySelector('.botaoRemover') && !logado) {


                    let textnode = document.createTextNode('Remover favorecido');
                    let botaoRemoverFavorecido = document.createElement('a');
                    botaoRemoverFavorecido.classList.add('botaoRemover');
                    botaoRemoverFavorecido.classList.add('btn-flat');
                    botaoRemoverFavorecido.classList.add('btnPortoSimple');
                    botaoRemoverFavorecido.setAttribute('href', '#');
                    botaoRemoverFavorecido.appendChild(textnode);
                    botaoRemoverFavorecido.addEventListener('click', removerFavorecido);
                    let iconPlus = document.createElement('i');
                    iconPlus.classList.add('material-icons');
                    iconPlus.classList.add('left');
                    iconPlus.innerText = 'cancel';
                    botaoRemoverFavorecido.appendChild(iconPlus);
                    section.querySelector('.row:last-child:not(.corretorFavorecido) .col').appendChild(botaoRemoverFavorecido);
                }

                colSusep.appendChild(inputSusep);
                colSusep.appendChild(labelSusep);
                colSusep.appendChild(labelErro); //PLV-4475 - Início/Fim
                colPercent.appendChild(inputPercent);
                colPercent.appendChild(labelPercent);
                colPercent.appendChild(indicatorPercent);
                row.appendChild(colLider);
                row.appendChild(colSusep);
                row.appendChild(colPercent);
                section.insertBefore(row, section.querySelector('.row:last-child:not(.corretorFavorecido)'));

                let corretores = section.querySelectorAll('.corretorFavorecido, .agenteFavorecido');
                corretores[corretores.length - 1].querySelector('input[type="range"]').dispatchEvent(resetaPercentagem);
                mascararCampos();
                inicializaSelects();
            } else {
                let row = document.createElement('div');
                row.classList.add('row');
                row.classList.add('agenteFavorecido');

                let colPercent = document.createElement('div');
                colPercent.classList.add('col');
                colPercent.classList.add('s4');
                colPercent.classList.add('input-field');
                colPercent.classList.add('percentagemFavorecido');
                let inputPercent = document.createElement('input');
                inputPercent.type = 'range';
                inputPercent.id = 'PERCENTAGEFAV' + agentesFavorecidos;
                inputPercent.name = 'PERCENTAGEFAV' + agentesFavorecidos;
                inputPercent.min = 1;
                inputPercent.max = 100;
                inputPercent.addEventListener('input', reajustarPercentagemFavorecidos);
                inputPercent.addEventListener('input', setIndicatorPercentagemFavorecidos);
                if (agentesFavorecidos == 0) inputPercent.value = 100;
                else if (contadorValoresAgentes >= 100) {
                    criarExcessaoFavorecidos(section);
                    return false;
                } else inputPercent.value = 100 - contadorValoresAgentes;
                let labelPercent = document.createElement('label');
                labelPercent.setAttribute('for', "PERCENTAGEFAV" + agentesFavorecidos);
                labelPercent.innerHTML = 'Percentual do favorecido';
                let indicatorPercent = document.createElement('div');
                indicatorPercent.classList.add('indicator');

                let colTipoPessoa = document.createElement('div');
                colTipoPessoa.classList.add('col');
                colTipoPessoa.classList.add('s4');
                colTipoPessoa.classList.add('input-field');
                let options = ` <option disabled="true" selected="true">Selecione</option>
                                <option value="FIS">Pessoa Física</option>
                                <option value="JUR">Pessoa Juridica</option>`;
                let inputTipoPessoa = document.createElement('select');
                inputTipoPessoa.id = 'TIPOAGEFAV' + agentesFavorecidos;
                inputTipoPessoa.name = 'TIPOAGEFAV' + agentesFavorecidos;
                inputTipoPessoa.innerHTML = options;
                let labelTipoPessoa = document.createElement('label');
                labelTipoPessoa.setAttribute('for', "TIPOAGEFAV" + agentesFavorecidos);
                labelTipoPessoa.innerHTML = 'Tipo de favorecido';
                inputTipoPessoa.addEventListener('change', tipoPessoaFavorecido);

                if (!section.querySelector('.botaoRemover')) {
                    let botaoRemoverFavorecido = document.createElement('a');
                    botaoRemoverFavorecido.classList.add('botaoRemover');
                    botaoRemoverFavorecido.setAttribute('href', '#');
                    botaoRemoverFavorecido.innerHTML = 'Remover favorecido';
                    botaoRemoverFavorecido.addEventListener('click', removerFavorecido);
                    section.querySelector('.row:last-child:not(.corretorFavorecido) .col').appendChild(botaoRemoverFavorecido);
                }

                colPercent.appendChild(inputPercent);
                colPercent.appendChild(labelPercent);
                colPercent.appendChild(indicatorPercent);
                colTipoPessoa.appendChild(inputTipoPessoa);
                colTipoPessoa.appendChild(labelTipoPessoa);
                row.appendChild(colTipoPessoa);
                row.appendChild(colPercent);
                section.insertBefore(row, section.querySelector('.row:last-child:not(.agenteFavorecido)'));

                let corretores = section.querySelectorAll('.corretorFavorecido, .agenteFavorecido');
                corretores[corretores.length - 1].querySelector('input[type="range"]').dispatchEvent(resetaPercentagem);
                mascararCampos();
                inicializaSelects();
            }

            /* PLV-4475 - INICIO */
            if(porcentagensCorretores.length >= 2) {
                document.querySelector(".addCorretor").style.display = "none";
            }
            /* PLV-4475 - FIM */

            let campos = section.querySelectorAll('input, select');
            campos.forEach(e => {
                e.setAttribute('required', 'true');
            });
        }

        function removerFavorecido(event) {
            event.preventDefault();
            let sessao = closestByClass(event.target, 'section');
            let favorecidos = sessao.querySelectorAll('.corretorFavorecido, .agenteFavorecido');
            favorecidos[favorecidos.length - 1].remove();
            document.querySelector(".addCorretor").style.display = ""; // PLV-4475
            if (sessao.querySelectorAll('.corretorFavorecido:not(.obrigatorio), .agenteFavorecido:not(.obrigatorio)').length == 0) {
                sessao.querySelector('.botaoRemover').remove();
            }
        }

        //PLV-4475 - Início
        function buscaCorretor(input){
            input.className = "";
            //console.log(input.value);
            consultaCorretores(input.value);
        }
        //PLV-4475 - Fim

        function criarExcessaoFavorecidos(section) {
            let colWarning = document.createElement('div');
            colWarning.classList.add('col');
            colWarning.classList.add('s12');
            colWarning.classList.add('center-align');
            colWarning.classList.add('warningAddFavorecido');
            colWarning.innerHTML = 'Limite de 100% atingido';
            section.insertBefore(colWarning, section.querySelector('.row:last-child:not(.corretorFavorecido)'));
        }

        function tipoPessoaFavorecido(event) {
            let tipopAtual = event.target.value;
            let section = closestByClass(event.target, 'row');
            let corretoresFavorecidos = document.querySelectorAll('.corretorFavorecido').length;
            let agentesFavorecidos = document.querySelectorAll('.agenteFavorecido').length;

            if (section.querySelector('.documentoTipoFavorecido')) {
                let inputContainer = section.querySelector('.documentoTipoFavorecido');
                let input = inputContainer.querySelector('input');
                input.className = '';
                input.classList.add('validate');
                input.classList.add(tipopAtual == 'FIS' ? 'cpfMask' : 'cnpjMask');
                input.id = String((tipopAtual == 'FIS' ? 'CPFAGEFAV' : 'CNPJAGEFAV') + section.classList.contains('corretorFavorecido') ? corretoresFavorecidos : agentesFavorecidos);
                input.name = String((tipopAtual == 'FIS' ? 'CPFAGEFAV' : 'CNPJAGEFAV') + section.classList.contains('corretorFavorecido') ? corretoresFavorecidos : agentesFavorecidos);
                let label = inputContainer.querySelector('label');
                label.setAttribute('for', String((tipopAtual == 'FIS' ? 'CPFAGEFAV' : 'CNPJAGEFAV') + agentesFavorecidos));
                label.innerHTML = String((tipopAtual == 'FIS' ? 'CPF' : 'CNPJ'));
            } else {
                let colDocument = document.createElement('div');
                colDocument.classList.add('col');
                colDocument.classList.add(section.classList.contains('corretorFavorecido') ? 's12' : 's4');
                colDocument.classList.add('input-field');
                colDocument.classList.add('documentoTipoFavorecido');
                let inputDocument = document.createElement('input');
                inputDocument.classList.add(tipopAtual == 'FIS' ? 'cpfMask' : 'cnpjMask');
                inputDocument.classList.add('validate');
                inputDocument.type = 'text';
                inputDocument.setAttribute('id', String((tipopAtual == 'FIS' ? 'CPFAGEFAV' : 'CNPJAGEFAV')) + (section.classList.contains('corretorFavorecido') ? corretoresFavorecidos : agentesFavorecidos));
                inputDocument.setAttribute('name', String((tipopAtual == 'FIS' ? 'CPFAGEFAV' : 'CNPJAGEFAV')) + (section.classList.contains('corretorFavorecido') ? corretoresFavorecidos : agentesFavorecidos));
                let labelDocument = document.createElement('label');
                labelDocument.setAttribute('for', String((tipopAtual == 'FIS' ? 'CPFAGEFAV' : 'CNPJAGEFAV') + agentesFavorecidos));
                labelDocument.innerHTML = String((tipopAtual == 'FIS' ? 'CPF' : 'CNPJ'));

                colDocument.appendChild(inputDocument);
                colDocument.appendChild(labelDocument);
                section.appendChild(colDocument);
            }
            mascararCampos();
        }

        function reajustarPercentagemFavorecidos(event) {
            let campos = closestByClass(event.target, 'section').querySelectorAll('input[type="range"]');
            if (campos.length > 1) {
                let valores = [];
                let somaTodosValores = 0;
                let campoAtual = event.target;
                let indexAtual = -1;
                let excedente = 0;
                campos.forEach((input, i) => {
                    if (input.id == campoAtual.id) {
                        indexAtual = i;
                    }
                    valores.push(input.value);
                    somaTodosValores += parseInt(input.value);
                });
                if (somaTodosValores > 100) {
                    let novosCampos = Array(...campos).splice(indexAtual, 1);
                    excedente = somaTodosValores - 100;
                    novosCampos.forEach((campo, i, arr) => {
                        campo.value -= Math.ceil(excedente / arr.length);
                        excedente -= Math.ceil(excedente / arr.length)
                    });
                }
                /* PLV-4475 - INÍCIO */
                if (document.querySelector('.warningPercentualFavorecido')) {
                    document.querySelector('.warningPercentualFavorecido').remove();
                }
                /* PLV-4475 - FIM */
            }
        }

        (function addDestino() {
            let btnAddDestino = document.querySelector('.addDestino');
            if (btnAddDestino) {
                let destinos = 1;
                btnAddDestino.addEventListener('click', event => {
                    event.preventDefault();
                    let listaDestinosContainer = closestByClass(event.target, 'row');
                    let listaDestinos = listaDestinosContainer.querySelector('.listaDestinos')

                    destinos++;

                    if (destinos >= 20) {
                        listaDestinosContainer.querySelector('.addDestino').classList.add('disabled');
                        // return null;
                    }

                    let containerDestino = document.createElement('div');
                    containerDestino.classList.add('input-field');
                    containerDestino.classList.add('col');
                    containerDestino.classList.add('s12');
                    let inputDestino = document.createElement('input');
                    inputDestino.type = 'text';
                    inputDestino.classList.add('destino');
                    inputDestino.id = "DESTINO" + destinos;
                    let labelDestino = document.createElement('label');
                    labelDestino.setAttribute('for', 'DESTINO' + destinos);
                    labelDestino.innerHTML = 'Destino ' + destinos;

                    if (destinos > 1 && !listaDestinosContainer.querySelector('.removerDestino')) {
                        let removerDestino = document.createElement('a');
                        removerDestino.href = "#";
                        removerDestino.classList.add('removerDestino');
                        removerDestino.innerHTML = 'Remover destino'

                        removerDestino.addEventListener('click', event => {
                            event.preventDefault();
                            listaDestinosContainer.querySelector('.addDestino').classList.remove('disabled');
                            destinos--;
                            listaDestinos.children[listaDestinos.children.length - 1].remove();
                        });

                        listaDestinosContainer.querySelector('.buttons').appendChild(removerDestino);
                    }

                    containerDestino.appendChild(inputDestino);
                    containerDestino.appendChild(labelDestino);
                    listaDestinos.appendChild(containerDestino);
                });
            }
        }());

        function setIndicatorPercentagemFavorecidos(event) {
            let col = event.target.parentNode;
            let indicator = col.querySelector('.indicator');
            indicator.style.left = parseInt(event.target.value) > 50 ?
                'calc(' + event.target.value + '% - 5px)' :
                'calc(' + event.target.value + '% + 5px)';
            indicator.innerHTML = event.target.value + '%';
        }



        function limparBeneficiario() {
            let nomeBeneficiario = document.getElementById('nomeBeneficiario')
            nomeBeneficiario.value = '';
            
            let cpfBeneficiario = document.getElementById('cpfBeneficiario')
            cpfBeneficiario.value = '';
            
            let nascimentoBeneficiario = document.getElementById('nascimentoBeneficiario')
            nascimentoBeneficiario.value = '';

            let percentualBeneficio = document.getElementById('percentualBeneficio')
            percentualBeneficio.value = '';

            let grauParentescoBeneficiario = document.getElementById('grauParentescoBeneficiario')
            grauParentescoBeneficiario.value = 'nulloption';

            //let imprimirApoliceSim              =           document.getElementById('imprimirApoliceSim')
            //    imprimirApoliceSim.checked = false;

            //PLV-5131 INICIO 
            let grauParentescoBeneficiarioOutros = document.getElementById('beneficiarioGrauParentescoOutros')
            grauParentescoBeneficiarioOutros.value = '';
            grauParentescoBeneficiarioOutros.parentElement.classList.add('hidden');
            grauParentescoBeneficiarioOutros.removeAttribute('required');
            //PLV-5131 INICIO

            resetHelper(nomeBeneficiario);
            resetHelper(cpfBeneficiario);
            resetHelper(nascimentoBeneficiario);
            resetHelper(percentualBeneficio);
            resetHelper(grauParentescoBeneficiario);
            resetHelper(grauParentescoBeneficiarioOutros); //PLV-5131 INICIO/FIM
            nomeBeneficiario.parentNode.classList.remove('invalid');
            nomeBeneficiario.classList.remove('invalid');
            cpfBeneficiario.parentNode.classList.remove('invalid');
            nascimentoBeneficiario.classList.remove('invalid');
            percentualBeneficio.classList.remove('invalid');
            grauParentescoBeneficiario.parentNode.classList.remove('invalid');
            nomeBeneficiario.focus();


            inicializaSelects();
        }

        function renderizarBeneficiarios() {
            let tbBeneficiariosTbody = document.getElementById('tbl-beneficiarios-tbody');

            if (listBeneficiarios.length > 0 || tbBeneficiariosTbody.rows.length > 0) {
                while (tbBeneficiariosTbody.rows.length > 0) {
                    document.getElementById('tbl-beneficiarios-tbody').deleteRow(0);
                }

                for (let index = 0; index < listBeneficiarios.length; index++) {
                    let clear = document.createElement("a");
                    clear.setAttribute("id", listBeneficiarios[index].numeroBeneficiario);
                    clear.setAttribute("class", "btn-flat btnPortoSimple");
                    clear.setAttribute("style", "margin-top: 0; padding: 20px;");
                    let clearItem = document.createElement("i");
                    clearItem.setAttribute("style", "cursor: pointer; margin-top: 0;");
                    clearItem.setAttribute("class", "material-icons");
                    clearItem.innerHTML = 'remove_circle';
                    clear.appendChild(clearItem);

                    clearItem.addEventListener('click', (e) => {
                        let id = parseInt(e.target.parentNode.id);
                        let temp = [];
                        for(let el in listBeneficiarios){
                            if (listBeneficiarios[el].numeroBeneficiario!=id){
                                temp.push(listBeneficiarios[el])
                            }else{
                                for (let idc = 0; idc < tbBeneficiariosTbody.rows.length; idc++){
                                    if (tbBeneficiariosTbody.rows[idc].dataset.numero && tbBeneficiariosTbody.rows[idc].dataset.numero==id){
                                        tbBeneficiariosTbody.deleteRow(idc)
                                    }
                                }

                            }
                        }
                        listBeneficiarios = temp;



                        /*listBeneficiarios = listBeneficiarios.filter((item) => item.numeroBeneficiario !== id);
                        e.target.parentNode.parentNode.parentNode.remove();*/
                        numeroBeneficiario--;
                        validarPorcentagemBeneficiarios()
                    });

                    let row = document.getElementById('tbl-beneficiarios-tbody').insertRow(index);
                   
                    row.insertCell(0).innerHTML = listBeneficiarios[index].nomeBeneficiario;
                    row.insertCell(1).innerHTML = listBeneficiarios[index].cpfBeneficiario;
                    row.insertCell(2).innerHTML = listBeneficiarios[index].grauParentescoBeneficiario;
                    row.insertCell(3).innerHTML = listBeneficiarios[index].grauParentescoBeneficiario;
                    row.dataset.numero = listBeneficiarios[index].numeroBeneficiario;
                    row.insertCell(4).appendChild(clear);
                }
                validarPorcentagemBeneficiarios()

                tbBeneficiarios.classList.add('on');
            } else {
                tbBeneficiarios.classList.remove('on');
            }
        }


        function progBeneficiarios() {
            /* ---------------- PLV 4323 INÍCIO ---------------- */
            let tbBeneficiarios = document.querySelector('#tbl-beneficiarios');
            let addBeneficiario = document.querySelectorAll('.addBeneficiario');
            let percentualParcial = parseFloat('0');

            if (document.getElementById('btn-limpar-beneficiarios') != null && document.getElementById('btn-limpar-beneficiarios') != undefined) {
                let btnLimpar = document.getElementById('btn-limpar-beneficiarios').addEventListener('click', () => {
                    /*let nomeBeneficiario                =           document.getElementById('nomeBeneficiario')
                        nomeBeneficiario.value = '';
                    
                    let cpfBeneficiario                 =           document.getElementById('cpfBeneficiario')
                        cpfBeneficiario.value = '';
                    
                    let nascimentoBeneficiario          =           document.getElementById('nascimentoBeneficiario')
                        nascimentoBeneficiario.value = '';
                    
                    let percentualBeneficio             =           document.getElementById('percentualBeneficio')
                        percentualBeneficio.value = '';
                    
                    let grauParentescoBeneficiario      =           document.getElementById('grauParentescoBeneficiario')
                        grauParentescoBeneficiario.value = 'nulloption';
                    
                    //let imprimirApoliceSim              =           document.getElementById('imprimirApoliceSim')
                    //    imprimirApoliceSim.checked = false;
                    
                    resetHelper(nomeBeneficiario);
                    resetHelper(cpfBeneficiario);
                    resetHelper(nascimentoBeneficiario);
                    resetHelper(percentualBeneficio);
                    resetHelper(grauParentescoBeneficiario);
                    nomeBeneficiario.focus();
                    
                    
                    inicializaSelects();*/
                    limparBeneficiario();
                });
            }

            let beneficiarios = document.querySelectorAll('select.toggleBeneficiarios');
            if (beneficiarios != null && beneficiarios != undefined) {
                beneficiarios.forEach(elem => {
                    elem.addEventListener('change', (e) => {
                        let containers = elem.closest('.step').querySelector('.listaBeneficiarios');
                        if (e.target.value == 'Nome do beneficiário') {
                            containers.classList.add('on');
                            let campos = containers.querySelectorAll('input, select');
                            campos.forEach(e => {
                                if (e.id != 'cpfBeneficiario')
                                    e.setAttribute('required', 'true');
                            });
                        } else {
                            containers.classList.remove('on');
                            let campos = containers.querySelectorAll('input, select');
                            campos.forEach(e => {
                                e.removeAttribute('required');
                            });
                        }
                    });
                });
            }
            if (addBeneficiario != null && addBeneficiario != undefined) {
                addBeneficiario.forEach(element => {
                    let numeroBeneficiario = 0;
                    element.addEventListener('click', e => {
                        let percentualBeneficioTemp = parseInt('0');
                        let percentualExibido = '';

                        if (document.getElementById('percentualBeneficio').value != '') {
                            percentualBeneficioTemp = parseInt(document.getElementById('percentualBeneficio').value.replace('%', ''));
                            percentualExibido = parseInt(document.getElementById('percentualBeneficio').value.replace('%', ''))+'%';
                        }
                        let imprimirApoliceSim = document.getElementById('imprimirApoliceSim').checked;
                        //let imprimirApoliceNao = document.getElementById('imprimirApoliceNao').checked;

                        let objBeneficiario = {
                            numeroBeneficiario: numeroBeneficiario,
                            nomeBeneficiario: document.getElementById('nomeBeneficiario').value,
                            cpfBeneficiario: document.getElementById('cpfBeneficiario').value,
                            nascimentoBeneficiario: document.getElementById('nascimentoBeneficiario').value,
                            sexoBeneficiario: document.getElementById('sexoBeneficiario').value,
                            percentualBeneficio: percentualBeneficioTemp,
                            grauParentescoBeneficiario: document.getElementById('grauParentescoBeneficiario').value,
                            grauParentescoOutros: document.getElementById('grauParentescoBeneficiario').value == 'Outros' ? document.getElementById('beneficiarioGrauParentescoOutros').value : '', //PLV-5131 INICIO-FIM
                            imprimirApolice: (imprimirApoliceSim == true ? true : false),
                            percentualExibido: percentualExibido
                        };

                        percentualParcial = parseInt(objBeneficiario.percentualBeneficio);
                        //console.log('percentualParcial - pre',percentualParcial)
                        for (let index = 0; index < listBeneficiarios.length; index++) {
                            //console.log('percentualParcial - pre', parseInt(listBeneficiarios[index].percentualBeneficio))
                            percentualParcial = parseInt(percentualParcial) + parseInt(listBeneficiarios[index].percentualBeneficio);
                        }
                        if (percentualParcial > 100.00) {
                            let percentualCampo = document.getElementById('percentualBeneficio');
                            let percentualCampoError = document.getElementById('percentualBeneficioError');
                            percentualCampo.classList.add('invalid');
                            buildHelper(percentualCampoError, 'O percentual informado excederá 100% do benefício.');
                            percentualCampo.focus();
                            return;
                        } else {
                            if (Date.parse(nascimentoBeneficiario) > new Date()) {
                                //alert('Data de Nascimento do beneficiário é maior que a data atual. Por favor verifique.');
                                nascimentoBeneficiario = null;
                            } else {
                                let formFields = document.querySelector('#formBeneficiario');
                                if (validarInputsBeneficiarios(formFields)) {

                                    console.log("------- objBeneficiario");
                                    console.log(objBeneficiario);
                                    listBeneficiarios.push(objBeneficiario);

                                    numeroBeneficiario++;


                                    /*document.getElementById('nomeBeneficiario').value = '';
                                    document.getElementById('cpfBeneficiario').value = '';
                                    document.getElementById('nascimentoBeneficiario').value = '';
                                    document.getElementById('percentualBeneficio').value = '';
                                    document.getElementById('grauParentescoBeneficiario').value = 'nulloption';
                                    document.getElementById('imprimirApoliceSim').checked = false;
                                    document.getElementById('nomeBeneficiario').focus();
                                    inicializaSelects();*/
                                    limparBeneficiario();
                                }
                            }

                            let tbBeneficiariosTbody = document.getElementById('tbl-beneficiarios-tbody');

                            if (listBeneficiarios.length > 0 || tbBeneficiariosTbody.rows.length > 0) {
                                while (tbBeneficiariosTbody.rows.length > 0) {
                                    document.getElementById('tbl-beneficiarios-tbody').deleteRow(0);
                                }

                                for (let index = 0; index < listBeneficiarios.length; index++) {
                                    let clear = document.createElement("a");
                                    clear.setAttribute("id", listBeneficiarios[index].numeroBeneficiario);
                                    clear.setAttribute("class", "btn-flat btnPortoSimple");
                                    clear.setAttribute("style", "margin-top: 0; padding: 20px;");
                                    let clearItem = document.createElement("i");
                                    clearItem.setAttribute("style", "cursor: pointer; margin-top: 0;");
                                    clearItem.setAttribute("class", "material-icons");
                                    clearItem.innerHTML = 'remove_circle';
                                    clear.appendChild(clearItem);

                                    clearItem.addEventListener('click', (e) => {
                                        let id = parseInt(e.target.parentNode.id);
                                        let temp = [];
                                        for(let el in listBeneficiarios){
                                            if (listBeneficiarios[el].numeroBeneficiario!=id && !!listBeneficiarios[el].cpfBeneficiario){ // PLV-5706 INICIO/FIM
                                                temp.push(listBeneficiarios[el])
                                            }else{
                                                for (let idc = 0; idc < tbBeneficiariosTbody.rows.length; idc++){
                                                    if (tbBeneficiariosTbody.rows[idc].dataset.numero && tbBeneficiariosTbody.rows[idc].dataset.numero==id){
                                                        tbBeneficiariosTbody.deleteRow(idc)
                                                    }
                                                }

                                            }
                                        }
                                        listBeneficiarios = temp;



                                        /*listBeneficiarios = listBeneficiarios.filter((item) => item.numeroBeneficiario !== id);
                                        e.target.parentNode.parentNode.parentNode.remove();*/
                                        numeroBeneficiario--;
                                        validarPorcentagemBeneficiarios()
                                    });

                                    let row = document.getElementById('tbl-beneficiarios-tbody').insertRow(index);
                                    // TKCL 463 - INICIO
                                    let atribuirNomeBeneficiario = listBeneficiarios[index].nomeBeneficiario;
                                    let atribuirCpfBeneficiario = listBeneficiarios[index].cpfBeneficiario;
                                    let atribuirGrauParentescoBeneficiario = listBeneficiarios[index].grauParentescoBeneficiario;
                                    let atribuirPercentualExibido = listBeneficiarios[index].percentualExibido;
                                    let atribuirNumeroBeneficiario = listBeneficiarios[index].numeroBeneficiario;

                                    if(atribuirNomeBeneficiario != undefined && atribuirCpfBeneficiario != undefined &&
                                        atribuirGrauParentescoBeneficiario != undefined && atribuirPercentualExibido != undefined){
                                            
                                    row.insertCell(0).innerHTML = atribuirNomeBeneficiario;
                                    row.insertCell(1).innerHTML = atribuirCpfBeneficiario;
                                    row.insertCell(2).innerHTML = atribuirGrauParentescoBeneficiario;
                                    row.insertCell(3).innerHTML = atribuirPercentualExibido;
                                    row.dataset.numero = atribuirNumeroBeneficiario;
                                    row.insertCell(4).appendChild(clear);
                                    // TKCL 463 - FIM
                                    }//PLV-5131 INICIO-FIM
                                }
                                validarPorcentagemBeneficiarios()




                                tbBeneficiarios.classList.add('on');
                            } else {
                                tbBeneficiarios.classList.remove('on');
                            }
                        }
                        
                        progPep();
                        motivoSemCpf();
                        mascararCampos();
                    });
                });
            }

            /* ---------------- PLV 4323 FIM ---------------- */
        }
        progBeneficiarios();

        async function addSegurado(grupoAtual) {
            return new Promise(resolve => {

                let tituloNovoSegurado = document.createElement('h3');
                tituloNovoSegurado.innerHTML = 'Segurado Dependente ' + (segurados + 1);
                tituloNovoSegurado.style.marginTop = 50;
                tituloNovoSegurado.style.display = 'block';
                tituloNovoSegurado.style.borderTop = segurados > 0 ? '1px solid #ccc' : '';
                tituloNovoSegurado.style.paddingTop = segurados > 0 ? '50px' : 0;
                let novoSegurado = viagem ? document.querySelector('.template-form-segurado.template-viagem').cloneNode(true) : individual ? document.querySelector('.template-form-segurado').cloneNode(true) : document.querySelector('.template-form-segurado').cloneNode(true);
                novoSegurado.classList.remove('hidden');
                novoSegurado.classList.remove('template-form-segurado');
                novoSegurado.id = 'SEGURADO' + segurados;
                novoSegurado.innerHTML = tituloNovoSegurado.outerHTML + novoSegurado.innerHTML.replace(/SEGURADO[0-9]+/g, 'SEGURADO' + (segurados + 1));
                let selects = novoSegurado.querySelectorAll('select');
                selects.forEach(select => {
                    let wrapper = closestByClass(select, 'input-field');
                    let label = wrapper.querySelector('label') ? wrapper.querySelector('label').cloneNode(true) : null;
                    wrapper.innerHTML = '';
                    wrapper.appendChild(select);
                    label ? wrapper.appendChild(label) : null;
                });
             document.querySelector('.listaSegurados').appendChild(novoSegurado);

                segurados++;

                // if(!document.querySelector('.listaSegurados .removeSegurado')){
                //     let btnRemoverSegurado = document.createElement('a');
                //         btnRemoverSegurado.href= '#';
                //         btnRemoverSegurado.innerHTML = 'Remover segurado';
                //         btnRemoverSegurado.classList.add('removeSegurado');
                //     document.querySelector('.listaSegurados').appendChild(btnRemoverSegurado);
                //     btnRemoverSegurado.addEventListener('click', event=>{
                //         event.preventDefault();
                //         let ultimoSegurado = document.querySelectorAll('.listaSegurados >.segurado');
                //             ultimoSegurado = ultimoSegurado[ultimoSegurado.length - 1];
                //         ultimoSegurado.remove();
                //         segurados--;
                //         if(segurados == 1){
                //             document.querySelector('.listaSegurados .removeSegurado').remove();
                //         }
                //     });
                // }
                mascararCampos();
                progPep();
                progBeneficiarios();
                inicializaSelects();
                inicializaProfissao();
                motivoSemCpf();
                buscaCEP();
                //paisResidente();
                //preencherPaises();
                carregamento.classList.remove('on');
                resolve(novoSegurado);
            });
        }

        (function progSegurados() {
            let quantiaSegurados = 0;
            let retiraUm = true;
            ofertaSelecionada.orcamento.contratantes[0].grupos.forEach(grupo => {
                if (grupo.qtdeVidas > 0) {
                    let qtdVidas = retiraUm ? (grupo.qtdeVidas - 1) : grupo.qtdeVidas;
                    for (let i = 0; i < qtdVidas; i++) {
                        addSegurado();
                        quantiaSegurados++;
                    }
                    retiraUm = false;
                }
            });
            if (quantiaSegurados <= 0) {
                document.getElementById('formularioPropostaViagem') ? document.querySelector('#formularioPropostaViagem .listaSegurados').remove() : null;
            }
        }());

        function buscaCEP() {
            let campoCep = document.querySelectorAll('.cepMask');
            campoCep.forEach(elem => {
                elem.addEventListener('blur', event => {
                    event.preventDefault();
                    // PLV - 4322 INICIO -> Inclui uma condição que chama uma função para conferir se o CEP esta ok
                    if (confereCep(event.target.value, event.target.name)) {

                        
                        let fieldName = event.target.name;
                        let cep = event.target.value.split('-')[0];
                        let cepSufixo = event.target.value.split('-')[1];
                        let jsonEntradaCep = {
                            obterEnderecoPorCEP: {
                                cep,
                                cepSufixo,
                            }
                        };
                        cepAtualizado = event.target;
                        
                        consultaCEP(JSON.stringify(jsonEntradaCep), fieldName);
                     //PLV-5176 INICIO   
                        if(event.target.name == 'CEPCLIENTE' || event.target.name == 'CEP'){
                            event.target.classList.remove('invalid');
                            event.target.classList.add('valid');
                            document.getElementById('LOGRADOUROCLIENTE').removeAttribute('disabled');
                            document.getElementById('BAIRROCLIENTE').removeAttribute('disabled');
                            document.getElementById('CIDADECLIENTE').removeAttribute('disabled');
                            document.getElementById('ESTADOCLIENTE').removeAttribute('disabled');
                        }else if(event.target.name == 'CEPCOMERCIAL'){
                            event.target.classList.remove('invalid');
                            event.target.classList.add('valid');
                            document.getElementById('LOGRADOUROCOMERCIAL').removeAttribute('disabled');
                            document.getElementById('BAIRROCOMERCIAL').removeAttribute('disabled');
                            document.getElementById('CIDADECOMERCIAL').removeAttribute('disabled');
                            document.getElementById('ESTADOCOMERCIAL').removeAttribute('disabled');
                        }
                    }else{
                        console.log('entrou no else do cep na formulario Proposta');
                        event.target.classList.remove('valid');
                        event.target.classList.add('invalid');
                        buildHelper(event.target, 'CEP Inválido');
                    }
                    //PLV-5176 FIM 
                    // PLV - 4322 FINAL
                })
            });
        }
        buscaCEP();

        function paisResidente() {
            document.querySelectorAll('.reside-brasil').forEach(e => {
                e.addEventListener('change', event => {
                    let wrapper = closestByClass(event.target, 'section').querySelector('.pais-residente');
                    if(wrapper){
                        if(event.target.value == 'SIM'){
                            wrapper.querySelectorAll('select option').forEach(elem=>elem.removeAttribute('selected'));
                            wrapper.querySelector('select option[value="Brasil"]').setAttribute('selected', 'selected');
                            wrapper.querySelector('select').M_FormSelect._handleSelectChangeBound();
                            wrapper.querySelector('select').parentNode.classList.remove('invalid');
                            wrapper.classList.add('disabled');
                        }else{
                            wrapper.classList.remove('disabled');
                        }
                    }
                });
            });
        }
        //paisResidente();

        function preencherPaises() {
            let selectPaisResidente = document.querySelectorAll('.pais-residente select');
            let ResponseCalculo = JSON.parse(window.localStorage.getItem('jsonResponseCalculo'));
            let dominios = ResponseCalculo.dominio ?
                ResponseCalculo.dominio.records ?
                ResponseCalculo.dominio.records :
                null :
                null;
            if (dominios) {
                let listaPaises = document.createElement('select');
                listaPaises.innerHTML = '<option disabled="true" selected="selected" value="0">Selecione</option>';
                let listSortedCountries = dominios.sort((a, b) => a.DeveloperName.toUpperCase() == b.DeveloperName.toUpperCase() ? 0 : a.DeveloperName.toUpperCase() < b.DeveloperName.toUpperCase() ? -1 : 1);
                listSortedCountries.forEach(dominio => {
                    let optionDominio = document.createElement('option');
                    optionDominio.setAttribute('value', dominio.DeveloperName);
                    optionDominio.innerHTML = dominio.MasterLabel;
                    listaPaises.appendChild(optionDominio);
                });

                selectPaisResidente.forEach(pais => {
                    pais.innerHTML = listaPaises.innerHTML;
                })
            }
        }
        //preencherPaises();

        // PLV-4481 INICIO - Remove assinatura digital quando o tipo de segmento for EDS
        function removerAssinaturaDigital() {
            var blocoAssinatura = document.querySelector('#blocoAssinaturaEletronica');
            if(ofertaSelecionada != null && ofertaSelecionada.orcamento.tipoSeguro.toLowerCase() == 'eds' && blocoAssinatura) //PLV-4600
                blocoAssinatura.classList.add('hidden');
        }
        removerAssinaturaDigital();
        // PLV-4481 FIM

        /*(function preencherBancos() {
            console.log('preencherBancos');
            let selectBancoAdc = document.getElementById('ADCBANCO');
            let jsonReponseCalculo = window.localStorage.getItem('jsonResponseCalculo');
            let ResponseCalculo = JSON.parse(jsonReponseCalculo);
            let bancos = ResponseCalculo.bancos ? ResponseCalculo.bancos : null;
            console.log('preencherBancos bancos'+bancos);
            console.log('preencherBancos ResponseCalculo'+ResponseCalculo);
            console.log('preencherBancos jsonReponseCalculo' + jsonReponseCalculo);

            bancos && selectBancoAdc ?
                bancos.forEach((banco, i) => {
                    let optionBanco = document.createElement('option');
                    optionBanco.setAttribute('value', banco.codigoBanco);
                    optionBanco.innerHTML = banco.nomeBanco;
                    selectBancoAdc.appendChild(optionBanco);
                }) :
                null;
        }());*/

        function motivoSemCpf() {
            let listaBeneficiarios = document.querySelectorAll('.listaBeneficiarios');
            listaBeneficiarios.forEach(lista => {
                let beneficiarios = lista.querySelectorAll('.beneficiario');
                beneficiarios.forEach((beneficiario, i) => {
                    let campoCpf = beneficiario.querySelector('.motivoCpf');
                    if(campoCpf){
                        beneficiario.querySelector('.cpfMask').addEventListener('input', e => {
                            if (e.target.value.trim().length > 0) {
                                campoCpf.classList.add('hidden');
                                campoCpf.removeAttribute('hidden');
                            } else {
                                campoCpf.classList.remove('hidden');
                                campoCpf.setAttribute('required', 'true');
                            }
                        });
                    }
                });
            });
        }
        motivoSemCpf();

        (function enderecoSemNumero() {
            let camposSemNumero = document.querySelectorAll('.sem-numero');
            camposSemNumero.forEach(e => {
                e.addEventListener('change', event => {
                    let wrapper = closestByClass(event.target, 'section').querySelector('.sem-numero-wrapper');
                    wrapper.querySelector('input').classList.add('alfaMask');
                    mascararCampos();
                    if (event.target.value == 'SIM') {
                        wrapper.querySelector('input').value = '';
                        wrapper.querySelector('input').removeAttribute('required');
                    } else {
                        wrapper.querySelector('input').setAttribute('required', 'required');
                    }
                });
            });
        }());

        (function iniciaCartao() {

            let elems = document.querySelectorAll('select');
            let instances = M.FormSelect.init(elems, {});

            var card = new Card({
                form: document.getElementById('formularioProposta') ? 'form#formularioProposta' : 'form#formularioPropostaViagem',
                container: '.card-wrapper',
                formSelectors: {
                    numberInput: 'input#cardNumber',
                    expiryInput: 'input#cardExpiry',
                    cvcInput: 'input#cardCvc',
                    nameInput: 'input#cardName'
                },
                width: 350,
                formatting: true,
                messages: {
                    validDate: 'válido\naté',
                    monthYear: 'mm/aa',
                },
                placeholders: {
                    number: '•••• •••• •••• ••••',
                    name: 'Nome impresso',
                    expiry: '••/••',
                    cvc: '•••'
                },
                masks: {
                    cardNumber: '•'
                },
                debug: true
            });

            VMasker(document.getElementById('cardExpiry')).maskPattern("99/99");
        }());

        (function metodoPagamento() {
            let tipoPagamento = document.querySelector('#TIPOPAGAMENTO');

            if (tipoPagamento) {
                tipoPagamento.addEventListener('change', (event) => {
                    let valor = translationsPayTypeLayout[event.target.querySelector('option:checked').dataset.layout];
                    let tipoPag = document.querySelectorAll('.tipoPag');

                    parcelamentos.forEach(parc => {
                        let planoParcelamentos = parc.planoParcelamentos;
                        if (planoParcelamentos) {
                            if (parc.codigo == event.target.value) {
                                if (planoParcelamentos.length > 1) {
                                    document.querySelector('.planParc').classList.remove('hidden');
                                } else {
                                    document.querySelector('.planParc').classList.add('hidden');
                                }
                            }
                        }
                    });
                    tipoPag.forEach(tipo => {
                        tipo.classList.remove('on');
                        let campos = tipo.querySelectorAll('input, select');
                        campos.forEach(e => {
                            e.removeAttribute('required');
                        });
                    });
                    let tipo = document.querySelector('.' + valor);
                    tipo.classList.add('on');

                    //PLV-4203-VI - Início - Ajuste de método de pagamento
                    //PLV-4438 - Início - Código removido
                    const notRequired = ['cardCvc']; //PLV-4940 INICIO/FIM
                    
                    let campos = document.querySelector('.' + valor).querySelectorAll('input, select');
                    campos.forEach(e => {

                        if(!notRequired.includes(e.getAttribute('id'))) e.setAttribute('required', 'true'); //PLV-4940 INICIO/FIM

                        e.classList.contains('invalid') ? e.classList.remove('invalid') : false;
                        e.classList.contains('valid') ? e.classList.remove('valid') : false;

                        if(individual){
                            e.tagName == 'SELECT' ?  e.value = '0' : e.value = '';
                            resetHelper(e);

                            /* INICIO - PLV-4524 - Guilherme Brito
                            if (e.name == 'vigenciaInicialCartao' || e.name == 'vigenciaInicialADC' || e.name == 'vigenciaInicialBoleto') {
                                let instance = M.Datepicker.getInstance(e);
                                instance.options.minDate = new Date(new Date().toISOString().slice(0, 10));
                                instance.options.defaultDate = new Date(new Date().toISOString().slice(0, 10));
                            }
                            FIM - PLV-4524 - Guilherme Brito */

                            if (e.name == 'ADCTIPOPESSOA') {
                                e.addEventListener('change', (evt) => {
                                    let tipoPessoa = evt.target.querySelector('option:checked').value;
                                    let div = evt.target.closest('.adc').querySelector('.adccpfcnpj');
                                    if (div) {
                                        tipoPessoa == 'fisica' || tipoPessoa == 'juridica' ? div.classList.remove('hidden') : div.classList.add('hidden');
                                        let campo = div.querySelector('input');
                                        if(campo){
                                            campo.value = '';
                                            resetHelper(campo);
                                            campo.classList.remove('valid','invalid');

                                            tipoPessoa == 'fisica' && campo.classList.contains('cnpjMask') ? campo.classList.remove('cnpjMask') : false;
                                            tipoPessoa == 'juridica' && campo.classList.contains('cpfMask') ? campo.classList.remove('cpfMask') : false;
                                            tipoPessoa == 'fisica' ? campo.classList.add('cpfMask') : tipoPessoa == 'juridica' ? campo.classList.add('cnpjMask') : false;
                                            tipoPessoa == 'fisica' ? VMasker(campo).maskPattern("999.999.999-99") : VMasker(campo).maskPattern("99.999.999/9999-99");
                                            let label = div.querySelector('label');
                                            tipoPessoa == 'fisica' ? label.innerHTML = 'CPF' : tipoPessoa == 'juridica' ? label.innerHTML = 'CNPJ' : label.innerHTML = '';
                                            mascararCampos();

                                            campo.addEventListener('change', c=>{
                                                if(tipoPessoa == 'fisica'){
                                                    if(!validaCPF(c.target.value)){
                                                        c.target.classList.add('invalid');
                                                        buildHelper(c.target, 'CPF inválido');
                                                    }else{
                                                        c.target.classList.remove('invalid');
                                                        resetHelper(c.target);
                                                    }
                                                }
                                                else if(tipoPessoa == 'juridica'){
                                                    if(!validaCPF(c.target.value)){
                                                        buildHelper(c.target, 'CNPJ inválido');
                                                        c.target.classList.add('invalid');
                                                    }else{
                                                        c.target.classList.remove('invalid');
                                                        resetHelper(c.target);
                                                    }
                                                }
                                            });
                                        }
                                    }
                                });
                                //PLV-4790 - INÍCIO
                                //Forçar pessoa física em ADC
                                e.querySelector('option[value="fisica"]').selected = true;
                                M.FormSelect.init(e,{});  
                                var evento = new Event('change'); 
                                e.dispatchEvent(evento);          
                                //PLV-4790 - FIM
                               
                            }
                            //PLV-4324 - Início
                            if(e.name == 'ADCBANCO'){
                                e.value = '';
                                e.dataset.valor = 'empty';
                            }
                            //PLV-4324 - Fim
                        }
                    });
                    //PLV-4438 - Fim
                    //PLV-4203-VI - Fim - Ajuste de método de pagamento
                });
            }
        }());

        //PLV-4324 - Início
        (function inicializaBancos(){
            //console.log('inicializaBancos')
            let campo = document.getElementById('ADCBANCO');
            if (window.localStorage.getItem('jsonServicos') != '' && JSON.parse(window.localStorage.getItem('jsonServicos')).ADCBANCO!==undefined) {inicializaServicos(); return;}
                //console.log('aqui')


            if(campo){
                //console.log('campo')
                if(!listaServicos.filter(s => s.id == campo.id).shift()){
                    let bodyConsulta = {
                        bancosConveniados: 'true'
                    };
                    listaServicos.push({id: campo.id, servico: 'Consulta_Banco', body: JSON.stringify(bodyConsulta), metodo: 'POST'});
                }
                
                new Promise((resolve, reject) => {
                    Promise.all([
                        callServicosProposta(JSON.stringify(listaServicos))
                    ])
                })
            }
        }());
        //PLV-4324 - Fim
        //PLV-4522 - INICIO
        (function inicializaPaises(){

            //console.log('inicializaServicos')

            let campo = document.getElementById('PAISRESIDENTE');
            let campo2 = document.getElementById('PAISDEORIGEM');
            if (window.localStorage.getItem('jsonServicos') != '' && JSON.parse(window.localStorage.getItem('jsonServicos')).PAISRESIDENTE!==undefined) {inicializaServicos(); return;}
            
            if(campo){                
                listaServicos.push({id: 'PAISRESIDENTE', servico: 'paises', body: null, metodo: 'GET'});
                
                new Promise((resolve, reject) => {
                    Promise.all([
                        callServicosProposta(JSON.stringify(listaServicos))
                    ])
                })
            }
        }());
        //PLV-4522 - FIM

        //PLV-4203-VI - Início - Ajuste de método de pagamento
        //PLV-4438 - Código removido
        //PLV-4203-VI - Fim - Ajuste de método de pagamento
        ///INICIO
        function inicializaResumo(){
            let resumoAzul = document.querySelector('.resumoAzul');
            //PLV-5137 INICIO
            let personalizacaoOferta = window.localStorage.getItem('personalizacaoOferta'); 
            personalizacaoOferta ? rotulo = 'Vida do Seu Jeito' : rotulo = ofertaSelecionada.orcamento.rotulo;
            //let rotulo = ofertaSelecionada.orcamento.rotulo;
            //PLV-5137 FIM
            let coberturas = ofertaSelecionada.orcamento.contratantes[0].grupos[0].segurados ?
                ofertaSelecionada.orcamento.contratantes[0].grupos[0].segurados.length > 0 ?
                ofertaSelecionada.orcamento.contratantes[0].grupos[0].segurados[0].coberturas :
                ofertaSelecionada.orcamento.contratantes[0].grupos[0].coberturas :
                ofertaSelecionada.orcamento.contratantes[0].grupos[0].coberturas;
            let valorTotal = ofertaSelecionada.retornosCalculo[0].precificacao.premio.total;

            resumoAzul.querySelector('.row.titulo h4').innerHTML = rotulo;
            resumoAzul.querySelector('.row.titulo span').innerHTML = 'Orçamento - ' + codOfertaSelecionada;

            //Definir prioridades de exibição das garantias
            let prioridades = ofertaSelecionada.regras.coberturas.map(e => [e.prioridade, e.sigla]).sort((e, a) => e[0] - a[0]);


            //Ordenar lista por ordem de prioridade
            let listaOrdenada = [];
            prioridades.forEach((prioridade, indiceGarantia) => {
                listaOrdenada[indiceGarantia] = coberturas.filter(e => e.sigla == prioridade[1]).shift();
            });

            listaOrdenada = listaOrdenada.filter(e => e);
            let lista = resumoAzul.querySelector('.row.garantias ul');

            listaOrdenada.forEach(cobertura => {
                let ofertaAtual = ofertaSelecionada.regras.coberturas.filter(e => e.sigla == cobertura.sigla).shift();
                let nome = document.createElement('strong');
                nome.innerHTML = ofertaAtual.nome;
                if (ofertaAtual.descricao) {
                    nome.classList.add('tooltip');
                    nome.dataset.descricao = ofertaAtual.descricao;
                    nome.innerHTML += '<i class="fas fa-question-circle"></i>';
                }
                //PLV - 4522 - INICIO
                if(ofertaAtual.sigla == 'DIT'){
                    document.getElementById('CEPCOMERCIAL').setAttribute('required','required');
                }
                //PLV - 4522 - FIM
                let valor = document.createElement('span');
                    valor.innerHTML =
                        cobertura.valor !== null ?
                        Intl.NumberFormat('pt-BR', {
                            style: 'currency',
                            currency: cobertura.moeda? cobertura.moeda : 'BRL'
                        }).format(cobertura.valor) :
                        'Sim';
                
                let item = document.createElement('li');
                    item.className = 'cobertura';
                    item.appendChild(nome);
                    item.appendChild(valor);

                    if(cobertura.valor !== null) {
                        lista.appendChild(item);   
                    }             
                });
            //filtrar 3 primeiras coberturas
            let coberturasFilt = Array(...(lista.querySelectorAll('.cobertura'))).slice(0, 3);
            
            lista.innerHTML = '';
            coberturasFilt.forEach(e => {
                lista.appendChild(e);
            });

            //se a lista contiver mais de 3 itens, lista-los, criar botão 'mais coberturas' e preencher modal com todas as coberturas
            if (ofertaSelecionada.regras.coberturas.length > 3) {
                let wrapMore = document.createElement('div');
                    wrapMore.classList.add('center-align');
                let iconPlus = document.createElement('i');
                    iconPlus.classList.add('material-icons');
                    iconPlus.classList.add('left');
                    iconPlus.innerText = 'add_circle';
                let textnode = document.createTextNode("Coberturas");
                let more = document.createElement('a');
                    more.href = '#loaderMore';
                    more.appendChild(iconPlus);
                    more.appendChild(textnode);
                    more.classList.add('modal-trigger');
                    more.classList.add('btn-flat');
                    more.classList.add('btnPortoSimple');
                wrapMore.appendChild(more);
                lista.appendChild(wrapMore);

                more.addEventListener('click', function (e) {
                    let listaCoberturas = document.createElement('ul');
                    let title = document.createElement('li');
                    title.className = 'titleCobertura';
                    let descCobertura = document.createElement('span');
                    descCobertura.innerHTML = 'Cobertura';
                    let descValor = document.createElement('span');
                    descValor.innerHTML = 'Capital';

                    listaCoberturas.appendChild(title);
                    listaOrdenada.forEach((cobertura, i) => {
                        let ofertaAtual = ofertaSelecionada.regras.coberturas.filter(e => e.sigla == cobertura.sigla).shift();

                        let nome = document.createElement('strong');
                        let styleNome = document.createElement('style');
                        styleNome.attributes.style = 'width: 70%';
                        nome.appendChild(styleNome);

                        nome.innerHTML = ofertaAtual.nome;
                        if (ofertaAtual.descricao) {
                            nome.classList.add('tooltip');
                            nome.dataset.descricao = ofertaAtual.descricao;
                            nome.innerHTML += '<i class="fas fa-question-circle"></i>';
                        }
                        let valor = document.createElement('span');
                        valor.innerHTML =
                            cobertura.valor !== null ?
                            Intl.NumberFormat('pt-BR', {
                                style: 'currency',
                                currency: cobertura.moeda? cobertura.moeda : 'BRL'
                            }).format(cobertura.valor) :
                            'Sim';

                        let item = document.createElement('li');

                        item.appendChild(nome);
                        item.appendChild(valor);
                    
                        listaCoberturas.appendChild(item);
                    });
                    document.querySelector('#loaderMore .modal-content').innerHTML = '';
                    document.querySelector('#loaderMore .modal-content').appendChild(listaCoberturas);
                });
            }

            let forSite = window.location.href.toLowerCase().includes('/lotusvida') ? '/lotusvida' : '/apex';
            let entradaConsultivo = JSON.parse(window.localStorage.getItem('entradaConsultivo'));
                entradaConsultivo.consultivo.voltar = true; 
            let botaoVoltar = document.getElementById('voltarFormulario');
                botaoVoltar.href = 'https://' + window.location.hostname + forSite + '/formularioSniper?dados=' + JSON.stringify(entradaConsultivo);
                botaoVoltar.addEventListener('click', salvaDadosProposta);

            resumoAzul.querySelector('.row.total .investimento').classList.add('hidden');
            resumoAzul.querySelector('.row.total .investimento').innerHTML = 'Seu investimento : ' + Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(valorTotal);
        }

        function inicializaResumoVidaIndividual(){
            let resumoAzul = document.querySelector('.resumoAzul');
            //PLV-5137 INICIO
            let personalizacaoOferta = window.localStorage.getItem('personalizacaoOferta'); 
            personalizacaoOferta ? rotulo = 'Vida do Seu Jeito' : rotulo = ofertaSelecionada.orcamento.rotulo;
            //let rotulo = ofertaSelecionada.orcamento.rotulo;
            //PLV-5137 FIM
            let coberturas = ofertaSelecionada.orcamento.contratantes[0].grupos[0].segurados?
                                ofertaSelecionada.orcamento.contratantes[0].grupos[0].segurados.length > 0?
                                    ofertaSelecionada.orcamento.contratantes[0].grupos[0].segurados[0].coberturas:
                                    ofertaSelecionada.orcamento.contratantes[0].grupos[0].coberturas:
                                ofertaSelecionada.orcamento.contratantes[0].grupos[0].coberturas;
            let valorTotal = ofertaSelecionada.retornosCalculo[0].precificacao.premio.total;

            let CoberturasAssistencias = ofertaSelecionada.regras.coberturas.length > 0?
                ofertaSelecionada.regras.coberturas:
                ofertaSelecionada.orcamento.contratantes[0].grupos[0].segurados[0].coberturas;

            resumoAzul.querySelector('.row.titulo h4').innerHTML = rotulo;
            resumoAzul.querySelector('.row.titulo span').innerHTML = 'Orçamento - ' + codOfertaSelecionada;

            //Definir prioridades de exibição das garantias
            let prioridades = ofertaSelecionada.regras.coberturas.map(e => [e.prioridade, e.sigla]).sort((e, a) => e[0] - a[0]);


            //Ordenar listas por ordem de prioridade
            let listaOrdenada = [];
            prioridades.forEach((prioridade, indiceGarantia) => {
                listaOrdenada[indiceGarantia] = coberturas.filter(e => e.sigla == prioridade[1]).shift();
            });

            listaOrdenada = listaOrdenada.filter(e => e);
            let lista = resumoAzul.querySelector('.row.garantias ul');

            //PLV-4325-Complemento3 - Início
            let titulos = document.createElement('li');
            titulos.classList.add('cobertura','tituloCobertura');

            let tituloCobertura = document.createElement('strong');
            tituloCobertura.innerHTML = 'Cobertura';
            tituloCobertura.style.cssText = 'width:60%';
            titulos.appendChild(tituloCobertura);

            let tituloCapital = document.createElement('strong');
            tituloCapital.innerHTML = 'Capital';
            tituloCapital.style.cssText = 'width: 40%'; // PLV-4767 INICIO/FIM
            titulos.appendChild(tituloCapital);

            // PLV-4767 INICIO/FIM - REMOÇÃO DE BLOCO DE CÓDIGO

            lista.appendChild(titulos);
            //PLV-4325-Complemento3 - Fim
            
            listaOrdenada.forEach(cobertura => {
                let ofertaAtual = ofertaSelecionada.regras.coberturas.filter(e=> e.sigla == cobertura.sigla).shift();
                let nome = document.createElement('strong');
                    nome.style.cssText = 'width:60%';
                    nome.innerHTML = ofertaAtual.nome;

                    if(ofertaAtual.descricao){
                        nome.classList.add('tooltip');
                        nome.dataset.descricao = ofertaAtual.descricao;
                        nome.innerHTML += '<i class="fas fa-question-circle"></i>';
                    }
                    //PLV - 4522 - INICIO
                    if(ofertaAtual.sigla == 'DIT'){
                        let cepComercial = document.getElementById('CEPCOMERCIAL');
                        let msgCepComercial = document.getElementById('msgCepComercial');
                        msgCepComercial.classList.remove('hide');
                        cepComercial.setAttribute('required','required');
                    }
                    //PLV - 4522 - FIM
                let valor = document.createElement('span');
                    valor.style.cssText = 'width: 40%'; // PLV-4767 INICIO/FIM
                    valor.innerHTML =
                        cobertura.valor !== null ?
                        Intl.NumberFormat('pt-BR', {
                            style: 'currency',
                            currency: cobertura.moeda? cobertura.moeda : 'BRL'
                        }).format(cobertura.valor) :
                        'Sim';

                // PLV-4767 INICIO/FIM - REMOÇÃO DE BLOCO DE CÓDIGO
                
                let item = document.createElement('li');
                item.className = 'cobertura';
                item.appendChild(nome);
                item.appendChild(valor);
                // PLV-4767 INICIO/FIM REMOÇÃO DE BLOCO DE CÓDIGO

                if (cobertura.valor !== null) {
                    lista.appendChild(item);
                }
            });
            //filtrar 4 primeiras coberturas
            let coberturasFilt = Array(...(lista.querySelectorAll('.cobertura'))).slice(0, 4);

            lista.innerHTML = '';
            coberturasFilt.forEach(e => {
                lista.appendChild(e);
            });

            //se a lista contiver mais de 4 itens, lista-los, criar botão 'mais coberturas' e preencher modal com todas as coberturas
            if (ofertaSelecionada.regras.coberturas.length > 4) {
                let wrapMore = document.createElement('div');
                wrapMore.classList.add('center-align');
                let iconPlus = document.createElement('i');
                iconPlus.classList.add('material-icons');
                iconPlus.classList.add('left');
                iconPlus.innerText = 'add_circle';
                let textnode = document.createTextNode("Coberturas");
                let more = document.createElement('a');
                more.href = '#loaderMore';
                more.appendChild(iconPlus);
                more.appendChild(textnode);
                more.classList.add('modal-trigger');
                more.classList.add('btn-flat');
                more.classList.add('btnPortoSimple');
                wrapMore.appendChild(more);
                lista.appendChild(wrapMore);

                //PLV-4325 - Início - Ajustes na aparição dos títulos
                //PLV-4325 Fix 2 - Início - Validando por garantias que existem na oferta
                let setSiglas = new Set();
                let s;
                listaOrdenada.forEach(cobertura => {
                    s = ofertaSelecionada.regras.coberturas.filter(e => e.sigla == cobertura.sigla).shift();
                    typeof s !== 'undefined' ? setSiglas.add(s.sigla) : false;
                });

                let temCobertura = ofertaSelecionada.regras.coberturas.some(item => setSiglas.has(item.sigla) && item.tipoGarantia == 'Cobertura');
                let temAssistenciaBeneficio = ofertaSelecionada.regras.coberturas.some(item => setSiglas.has(item.sigla) && (item.tipoGarantia == 'Assistência' || item.tipoGarantia == 'Benefício'));
                //PLV-4325 Fix 2 - Fim

                more.addEventListener('click', function (e) {
                    document.querySelector('#loaderMore .modal-content').innerHTML = '';
                    if(temCobertura){
                        let listaCoberturas = document.createElement('ul');
                        let title = document.createElement('li');
                        title.className = 'titleCobertura';
                        let descTitle = document.createElement('strong');
                        descTitle.innerHTML = 'Coberturas';
                        title.appendChild(descTitle);
                        listaCoberturas.appendChild(title);

                        title = document.createElement('li');
                        title.className = 'titleCobertura';
                        let descCobertura = document.createElement('span');
                            descCobertura.style.cssText = 'width:50%;text-align:left';
                            descCobertura.innerHTML = 'Cobertura';

                        let descValor = document.createElement('span');
                            descValor.style.cssText = 'width:20%;text-align:left';
                            descValor.innerHTML = 'Capital';

                        let descPremio = document.createElement('span');
                            descPremio.style.cssText = 'width:18%;text-align:left';
                            descPremio.innerHTML = 'Premio';

                        let descCarencia = document.createElement('span');
                            descCarencia.style.cssText = 'width:20%;text-align:left';
                            descCarencia.innerHTML = 'Carência';

                        let descFranquia = document.createElement('span');
                            descFranquia.style.cssText = 'width:10%;text-align:left';
                            descFranquia.innerHTML = 'Franquia';
                        
                        title.appendChild(descCobertura);
                        title.appendChild(descValor);
                        title.appendChild(descPremio);
                        title.appendChild(descCarencia);
                        title.appendChild(descFranquia);

                        listaCoberturas.appendChild(title);
                        listaOrdenada.forEach(cobertura => {
                            let ofertaAtual = ofertaSelecionada.regras.coberturas.filter(e => e.sigla == cobertura.sigla).shift();

                            if(ofertaAtual && ofertaAtual.tipoGarantia == 'Cobertura'){
                                let nome = document.createElement('span');
                                nome.style.cssText = 'width:35%;text-align:left';
                                nome.innerHTML = ofertaAtual.nome;
                                if (ofertaAtual.descricao) {
                                    nome.classList.add('tooltip');
                                    nome.dataset.descricao = ofertaAtual.descricao;
                                    nome.innerHTML += '<i class="fas fa-question-circle"></i>';
                                }
                                let valor = document.createElement('span');
                                    valor.style.cssText = 'width:15%';
                                valor.innerHTML =
                                    cobertura.valor !== null ?
                                    Intl.NumberFormat('pt-BR', {
                                        style: 'currency',
                                        currency: cobertura.moeda ? cobertura.moeda : 'BRL'
                                    }).format(cobertura.valor) :
                                    'Sim';

                                let premioAtual = ofertaSelecionada.retornosCalculo[0].precificacao.coberturas.filter(e=> e.sigla == cobertura.sigla).shift();
                                let beneficios = CoberturasAssistencias.filter(e => e.sigla == cobertura.sigla).shift();

                                let premio = document.createElement('span');
                                    premio.style.cssText = 'width:10%';

                                if (premioAtual) {
                                    premio.innerHTML =
                                        premioAtual.premio.total !== null ?
                                        Intl.NumberFormat('pt-BR', {
                                            style: 'currency',
                                            currency: cobertura.moeda ? cobertura.moeda : 'BRL'
                                        }).format(premioAtual.premio.total) :
                                        'Sim';
                                } else {
                                    premio.innerHTML = 'N/A';
                                }

                                let carencia = document.createElement('span');
                                    carencia.style.cssText = 'width:10%';
                                    
                                if(beneficios.carencias) {
                                    carencia.innerHTML = 'Sim';
                                } else {
                                    carencia.innerHTML = 'Não';
                                }

                                let franquia = document.createElement('span');
                                    franquia.style.cssText = 'width:10%';

                                if(beneficios.franquias) {
                                    franquia.innerHTML = 'Sim';
                                } else {
                                    franquia.innerHTML = 'Não';
                                }

                                let item = document.createElement('li');
                                item.appendChild(nome);
                                item.appendChild(valor);

                                item.appendChild(premio);
                                item.appendChild(carencia);
                                item.appendChild(franquia);

                                if (cobertura.valor !== null) {
                                    listaCoberturas.appendChild(item);
                                }
                            }
                        });
                        document.querySelector('#loaderMore .modal-content').appendChild(listaCoberturas);
                    }
                    if(temAssistenciaBeneficio){
                        let listaAssisBene = document.createElement('ul');
                        let title = document.createElement('li');
                        title.className = 'titleCobertura';

                        //PLV-4325-Complemento3 - Início
                        let descTitle = document.createElement('strong');
                        descTitle.innerHTML = 'Assistências e Benefícios';

                        title.appendChild(descTitle);
                        listaAssisBene.appendChild(title);
                        //PLV-4325-Complemento3 - Fim

                        listaOrdenada.forEach(assistenciaBeneficio  => {
                            let ofertaAtual = ofertaSelecionada.regras.coberturas.filter(e => e.sigla == assistenciaBeneficio.sigla).shift();

                            if(ofertaAtual && (ofertaAtual.tipoGarantia == 'Assistência' || ofertaAtual.tipoGarantia == 'Benefício')){
                                let nome = document.createElement('span');
                                    nome.style.cssText = 'width:70%;text-align:left'; 

                                nome.innerHTML = ofertaAtual.nome;
                                if (ofertaAtual.descricao) {
                                    nome.classList.add('tooltip');
                                    nome.dataset.descricao = ofertaAtual.descricao;
                                    nome.innerHTML += '<i class="fas fa-question-circle"></i>';
                                }
                                // PLV-4767 INICIO/FIM REMOÇÃO DE BLOCO DE CÓDIGO
                                let item = document.createElement('li');
                                
                                item.appendChild(nome);
                                // PLV-4767 INICIO/FIM REMOÇÃO DE BLOCO DE CÓDIGO
                                
                                listaAssisBene.appendChild(item);
                            }
                        });
                        document.querySelector('#loaderMore .modal-content').appendChild(listaAssisBene);
                    }
                });
                //PLV-4325 - Fim - Ajustes na aparição dos títulos
            }

            let forSite = window.location.href.toLowerCase().includes('/lotusvida') ? '/lotusvida' : '/apex';
            let entradaConsultivo = JSON.parse(window.localStorage.getItem('entradaConsultivo'));
            entradaConsultivo.consultivo.voltar = true;
            let botaoVoltar = document.getElementById('voltarFormulario');
            botaoVoltar.href = 'https://' + window.location.hostname + forSite + '/formularioSniper?dados=' + JSON.stringify(entradaConsultivo);
            botaoVoltar.addEventListener('click', salvaDadosProposta);

            resumoAzul.querySelector('.row.total .investimento').classList.add('hidden');
            resumoAzul.querySelector('.row.total .investimento').innerHTML = 'Seu investimento : ' + Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(valorTotal);
        }

        if(viagem) {
            inicializaResumo();
        } else if(individual){
            inicializaResumoVidaIndividual();
        }
        ///FIM

        (function preencheProfissoes() {
            let inputProfissoes = document.getElementById('PROFISSAOLABEL');
            if (inputProfissoes && JSON.parse(window.localStorage.getItem('jsonServicos'))['DICIO_PROFISSAO']) {
                //PLV-4393 - Inicio
                let codigoprofissao = JSON.parse(window.localStorage.getItem('dadosUsuario')).filter(e => e.id=='DICIO_PROFISSAO').shift().conteudo
                inputProfissoes.value = JSON.parse(window.localStorage.getItem('jsonServicos'))['DICIO_PROFISSAO'].itens.filter(e => e.codigo == codigoprofissao).shift().rotulo
                //PLV-4393 - Fim
                inputProfissoes.setAttribute('disabled', 'true');

                if (inputProfissoes.value.toUpperCase() == "EMPRESÁRIO" || inputProfissoes.value.toUpperCase() == "EMPRESARIO") {
                    document.querySelector('.complementoEmpresario').classList.remove('hidden');
                }else{
                    document.querySelector('.complementoEmpresario').remove();
                }
            }
        }());

        (function scrollResumo() {
            if (window.innerWidth > 768) {
                let resumo = document.querySelector('.fixedResume');
                let scrollTop = document.documentElement.scrollTop;

                function posicionaResumo() {
                    scrollTop = document.documentElement.scrollTop;
                    if (scrollTop > 100)
                        resumo.style.top = (scrollTop - 100) + 'px';
                    else
                        resumo.style.top = 0 + 'px';
                }
                window.addEventListener('scroll', posicionaResumo);
                posicionaResumo();
            }
        }());

        (function botaoContratar() {
            let botao = document.querySelector('.btnPortoSuccess');
            let form = document.querySelector('.formulario');
            let resumo = document.querySelector('.resumo');
            let jsonReponseCalculo = window.localStorage.getItem('jsonResponseCalculo');
            let ResponseCalculo = JSON.parse(jsonReponseCalculo);
            ofertaSelecionada = ResponseCalculo.ofertas.filter(e => e.orcamento.numeroOrcamento == codOfertaSelecionada).shift() || ResponseCalculo.ofertas[0];

            //PLV-4325 - Início
            let coberturas = ofertaSelecionada.orcamento.contratantes[0].grupos[0].segurados?
                                ofertaSelecionada.orcamento.contratantes[0].grupos[0].segurados.length > 0?
                                    ofertaSelecionada.orcamento.contratantes[0].grupos[0].segurados[0].coberturas:
                                    ofertaSelecionada.orcamento.contratantes[0].grupos[0].coberturas:
                                ofertaSelecionada.orcamento.contratantes[0].grupos[0].coberturas;

            //Definir prioridades de exibição das garantias
            let prioridades = ofertaSelecionada.regras.coberturas.map(e => [e.prioridade, e.sigla]).sort((e, a) => e[0] - a[0]);

            //Ordenar listas por ordem de prioridade
            let listaOrdenada = [];
            prioridades.forEach((prioridade, indiceGarantia) => {
                listaOrdenada[indiceGarantia] = coberturas.filter(e => e.sigla == prioridade[1]).shift();
            });
            listaOrdenada = listaOrdenada.filter(e => e);
            //PLV-4325 - Fim

            botao.addEventListener('click', e => {
                //PLV-5066 INICIO
                //AV-85 INICIO
                let pagmentoIgnorado = apagarPagmento1();
                let jsonEntradaCalculo = JSON.parse(window.localStorage.getItem('jsonEntradaCalculo'));
                if(jsonEntradaCalculo.consultivo.codigoOfertaConsultiva == 'VIAGEM_VIDA_ON')findIdFormaPagamento();
                //AV-85 FIM
                e.preventDefault();
                if (validaCamposTransmissao()) {
                    //dados form
                    let nomePessoaForm = document.querySelector('input[name="DICIO_NOME"]').value;
                    let nomeCpfForm = document.querySelector('input[name="CPF"]').value;
                    let tipoPagamentoForm = pagmentoIgnorado?' ':document.querySelector('select[name="TIPOPAGAMENTO"]').value
                    let opcaoPagamento = pagmentoIgnorado?' ':document.querySelector('#OPCAO_PAGAMENTO').value;
                    let nomePlanoFrom = ofertaSelecionada.orcamento.rotulo;
                     //PLV-4325 - Início
                    let valorPremioForm = pagmentoIgnorado?' ':ofertaSelecionada.retornosCalculo.filter(e => e.opcao == opcaoPagamento).shift().precificacao.premio.total;
                    let dadosPagamento = '';

                    // PLV-4455 - INICIO
                    let opcaoPagamentoSelecionada = pagmentoIgnorado?' ':ofertaSelecionada.retornosCalculo.filter(e => e.opcao == opcaoPagamento).shift(); 
                    // PLV-4455 - FIM

                    //PLV-4600 - INICIO
                    let valorTotal = ofertaSelecionada.retornosCalculo[0].precificacao.premio.total;
                    if(checkOfertaSelecionadaIsEndossoViagem() && parseFloat(valorTotal) < 0) {/// ENDOSSO E PREMIO NEGATIVO
                        parcelamentoAtualEscolhidoPeloUsuario = null;
                    }else if (parcelamentoAtual) {
                        parcelamentoAtualEscolhidoPeloUsuario = parcelamentoAtual.find(e => e.qtdParcelas == document.querySelector('select[name="planoParcelamentos"]').value) || null;
                    }
                    //PLV-4600 - FIM

                    if(viagem){
                        // PLV-4455 - INICIO
                        carregaTabelaResumoViagem(opcaoPagamentoSelecionada, ofertaSelecionada.regras, listaOrdenada, valorPremioForm); 
                        // PLV-4455 - FIM
                    }else if(individual){
                        //PLV-5107 - INICIO
                        // let vigenciaInicialResumo = document.querySelector('.vigenciaInicialResumo');
                        // vigenciaInicialResumo.innerHTML = "Início de vigência: " + ofertaSelecionada.orcamento.vigenciaInicial.split('-').reverse().join('/');
                        // let vigenciaFinalResumo = document.querySelector('.vigenciaFinalResumo');
                        // vigenciaFinalResumo.innerHTML = "Término de vigência: " + ofertaSelecionada.orcamento.vigenciaFinal.split('-').reverse().join('/');
                        //PLV-5107 - FIM
                        carregaTabelaResumoVidaIndividual(ofertaSelecionada, listaOrdenada, valorPremioForm);
                    }

                    let nomePessoaResumo = document.querySelector('.nomePessoaResumo');
                    nomePessoaResumo.innerHTML = nomePessoaForm;
                    let cpfPessoaResumo = document.querySelector('.cpfPessoaResumo');
                    cpfPessoaResumo.innerHTML = nomeCpfForm.substring(0, 3) + '.***.***-' + nomeCpfForm.slice(-2);
                    let modoPagamentoResumo = document.querySelector('.modoPagamentoResumo span');
                    if(!pagmentoIgnorado){
                        modoPagamentoResumo.innerHTML = document.querySelector('select[name="planoParcelamentos"]').value + 'x no ' + translationsPayType[tipoPagamentoForm];
                    }
                    //PLV-5066 FIM
                    let nomePlanoResumo = document.querySelector('.nomePlano');
                    nomePlanoResumo.innerHTML = nomePlanoFrom;
 
                    //modoPagamentoResumo
                    let modoPagamentoResumoDados = document.querySelector('.modoPagamentoResumoDados');
                    modoPagamentoResumoDados.innerHTML = '';

                    // PLV-4600 - INICIO
                    if(checkOfertaSelecionadaIsEndossoViagem() && parseFloat(valorTotal) < 0) 
                        document.querySelector(".modoPagamentoResumo").parentElement.parentElement.setAttribute("hidden","hidden");
                    // PLV-4600 - FIM
                    
                    // PLV-4488 - INICIO
                    if (checkOfertaSelecionadaIsEndossoVI() && parseFloat(valorTotal) < 0)
                        document.querySelector(".modoPagamentoResumo").parentElement.parentElement.setAttribute("hidden","hidden");
                    // PLV-4488 - FIM

                    // let parcelasLabel = document.createElement('div');
                    // parcelasLabel.classList.add('col');
                    // parcelasLabel.classList.add('s6');
                    // parcelasLabel.innerHTML = 'Número de parcelas';

                    // let vencimentoLabel = document.createElement('div');
                    // vencimentoLabel.classList.add('col');
                    // vencimentoLabel.classList.add('s6');
                    // vencimentoLabel.innerHTML = 'Vencimento de cada parcela';

                    // let numeroParcelas = document.querySelector('#numeroParcelas').value;
                    // let numeroParcelas = 5;
                    // let f = document.getElementById('vencimentoParcela');
                    // let vencimentoParcela = f.options[f.selectedIndex].text;
                    // let vencimentoParcela = 20;

                    // let parcelas = document.createElement('div');
                    // parcelas.classList.add('col');
                    // parcelas.classList.add('s6');
                    // parcelas.classList.add('right-align');
                    // parcelas.innerHTML = numeroParcelas;

                    // let vencimento = document.createElement('div');
                    // vencimento.classList.add('col');
                    // vencimento.classList.add('s6');
                    // vencimento.classList.add('right-align');
                    // vencimento.innerHTML = 'Todo dia ' + vencimentoParcela;


                    // modoPagamentoResumoDados.appendChild(parcelasLabel);
                    // modoPagamentoResumoDados.appendChild(parcelas);
                    // modoPagamentoResumoDados.appendChild(vencimentoLabel);
                    // modoPagamentoResumoDados.appendChild(vencimento);


                    if (tipoPagamentoForm == 0) {

                        if(modoPagamentoResumo) 
                            modoPagamentoResumo.parentElement.parentElement.setAttribute("hidden","hidden"); //PLV-4889
                        //alert(tipoPagamentoForm);
                        /*let cardNumber = '1238.1093.2890.1283'; // mockei
                        let expiryInput = '12/09'; // mockei
                        let cvcInput = '099'; // mockei
                        let nameInput = 'teste'; // mockei

                        let nomeBandeira = '';
                        // mockei
                        // let creditCard = document.querySelector('.jp-card');

                        // creditCard.classList.forEach(e => {
                        //     if (translationsCardType[e])
                        //         nomeBandeira = translationsCardType[e];
                        // });

                        //inputls
                        let modeloLabel = document.createElement('div');
                        modeloLabel.classList.add('col');
                        modeloLabel.classList.add('s6');
                        modeloLabel.innerHTML = 'Modelo';

                        let numeroLabel = document.createElement('div');
                        numeroLabel.classList.add('col');
                        numeroLabel.classList.add('s6');
                        numeroLabel.innerHTML = 'Número';

                        let vencimentoCardLabel = document.createElement('div');
                        vencimentoCardLabel.classList.add('col');
                        vencimentoCardLabel.classList.add('s6');
                        vencimentoCardLabel.innerHTML = 'Vencimento do Cartão';

                        //dados
                        let modelo = document.createElement('div');
                        modelo.classList.add('col');
                        modelo.classList.add('s6');
                        modelo.classList.add('right-align');
                        modelo.innerHTML = 'Mastercard'; // mockei

                        let numeroCard = document.createElement('div');
                        numeroCard.classList.add('col');
                        numeroCard.classList.add('s6');
                        numeroCard.classList.add('right-align');
                        numeroCard.innerHTML = '****.****.****.' + cardNumber.substring(cardNumber.length - 4);

                        let vencimentoCard = document.createElement('div');
                        vencimentoCard.classList.add('col');
                        vencimentoCard.classList.add('s6');
                        vencimentoCard.classList.add('right-align');
                        vencimentoCard.innerHTML = expiryInput;


                        modoPagamentoResumoDados.appendChild(modeloLabel);
                        modoPagamentoResumoDados.appendChild(modelo);
                        modoPagamentoResumoDados.appendChild(numeroLabel);
                        modoPagamentoResumoDados.appendChild(numeroCard);
                        modoPagamentoResumoDados.appendChild(vencimentoCardLabel);
                        modoPagamentoResumoDados.appendChild(vencimentoCard);*/

                    } else if (tipoPagamentoForm == 2) {

                        //labels
                        let bancoLabel = document.createElement('div');
                        bancoLabel.classList.add('col');
                        bancoLabel.classList.add('s6');
                        bancoLabel.innerHTML = 'Banco';

                        let agenciaLabel = document.createElement('div');
                        agenciaLabel.classList.add('col');
                        agenciaLabel.classList.add('s6');
                        agenciaLabel.innerHTML = 'Agência';

                        let contaLabel = document.createElement('div');
                        contaLabel.classList.add('col');
                        contaLabel.classList.add('s6');
                        contaLabel.innerHTML = 'Conta Corrente';

                        let nomeLabel = document.createElement('div');
                        nomeLabel.classList.add('col');
                        nomeLabel.classList.add('s6');
                        nomeLabel.innerHTML = 'Nome';

                        let cpfLabel = document.createElement('div');
                        cpfLabel.classList.add('col');
                        cpfLabel.classList.add('s6');
                        cpfLabel.innerHTML = 'CPF';

                        //dados
                        let nomeDebito = document.getElementById('correntistaDebito').value;
                        let CpfDebito = document.getElementById('cpfDebito').value;
                        let e = document.getElementById('bancoDebito');
                        let bancoDebito = e.options[e.selectedIndex].text;
                        let agenciaDebito = document.getElementById('agenciaDebito').value;
                        let digitoContaDebito = document.getElementById('cidadeDebito').value;
                        let contaDebito = document.getElementById('contaDebito').value + '-' + digitoContaDebito;

                        let banco = document.createElement('div');
                        banco.classList.add('col');
                        banco.classList.add('s6');
                        banco.classList.add('right-align');
                        banco.innerHTML = bancoDebito;

                        let agencia = document.createElement('div');
                        agencia.classList.add('col');
                        agencia.classList.add('s6');
                        agencia.classList.add('right-align');
                        agencia.innerHTML = agenciaDebito;

                        let conta = document.createElement('div');
                        conta.classList.add('col');
                        conta.classList.add('s6');
                        conta.classList.add('right-align');
                        conta.innerHTML = contaDebito;

                        let nome = document.createElement('div');
                        nome.classList.add('col');
                        nome.classList.add('s6');
                        nome.classList.add('right-align');
                        nome.innerHTML = nomeDebito;

                        let cpf = document.createElement('div');
                        cpf.classList.add('col');
                        cpf.classList.add('s6');
                        cpf.classList.add('right-align');
                        cpf.innerHTML = CpfDebito.substring(0, 3) + '.***.***-' + CpfDebito.slice(-2);
                        //CpfDebito;

                        modoPagamentoResumoDados.appendChild(bancoLabel);
                        modoPagamentoResumoDados.appendChild(banco);
                        modoPagamentoResumoDados.appendChild(agenciaLabel);
                        modoPagamentoResumoDados.appendChild(agencia);
                        modoPagamentoResumoDados.appendChild(contaLabel);
                        modoPagamentoResumoDados.appendChild(conta);
                        modoPagamentoResumoDados.appendChild(nomeLabel);
                        modoPagamentoResumoDados.appendChild(nome);
                        modoPagamentoResumoDados.appendChild(cpfLabel);
                        modoPagamentoResumoDados.appendChild(cpf);

                    }
                    //PLV-4325 - Fim

                    resumo.classList.remove('hidden');
                    form.classList.add('hidden');
                }
            });
            document.querySelector('.voltar').addEventListener('click', e => {
                document.querySelector('.row.formulario').classList.remove('hidden');
                document.querySelector('.row.resumo').classList.add('hidden');
            });
            document.querySelector('.gerarContrato').addEventListener('click', e => {
                document.querySelector('.modalLoaderErro').classList.add('on');
                let jsonEntradaTransmissao = getjsonEntradaTransmissao();
                let jsonDadosVoucher = getJsonDadosVoucher(); //AV-85 INICIO/FIM
                // document.querySelector('#Transmissao').value = '{"devolutivasPropostas":[{"proposta":{"indice":1,"origem":18,"numero":"05001311","status":"Disponível para Contratação","arquivos":[{"nome":"Voucher e Carta Garantia","descricao":"Esse é o documento solicitado pelas áreas de migração dos países estrangeiros.","link":"https://enderecodocomponentedepdf","tamanhoBytes":32768}]},"retornoAceitacao":{"avisos":[{"codigo":10080,"descricao":"Segurado com risco de fraude.","area":"ACE","procedimento":"Informar ao sinistro e monitorar assistências solicitadas","mensagens":{"interna":"Inteligência artificial alerta para risco de fraude em assistências de viagem"}}]},"retornoFinanceiro":{"autorizacaoCartao":{"autorizado":true,"stargate":{"codigo":2,"mensagem":"APROVADO","codigoGateway":0,"mensagemGateway":"CAPTURED"}}}}]}';
                // gerarContrato();
                window.localStorage.setItem('jsonDadosVoucher', JSON.stringify(jsonDadosVoucher)); //AV-85 INICIO/FIM
                //console.log('jsonDadosVoucher', jsonDadosVoucher);
                window.localStorage.setItem('jsonEntradaTransmissao', JSON.stringify(jsonEntradaTransmissao));
                //console.log(jsonEntradaTransmissao);
                // let jsonEntradaTransmissao = getjsonEntradaTransmissaoMock();
                CallPagTransmissao(JSON.stringify(jsonEntradaTransmissao), JSON.stringify(jsonDadosVoucher));  //AV-85 INICIO/FIM
                //CallPagTransmissao(JSON.stringify(jsonEntradaTransmissao));
                // CallPagTransmissao(); /
            });
        }());

        //PLV-4325 - Início
        function carregaTabelaResumoViagem(pagamentoSelecionado, regrasGarantias, listaCoberturas, valorTotalForm){ //PLV-4455 - Inicio/fim
            //dados resumo
            let coberturaRow = document.querySelector('.resumo .row.cobertura');
            coberturaRow.innerHTML = '';

            //título 'Coberturas'
            let divH3Cobertura = document.createElement('div');
            divH3Cobertura.classList.add('col','s12','center-align');
            let titleH3Cobertura = document.createElement('h3');
            titleH3Cobertura.innerHTML = 'Coberturas';
            divH3Cobertura.appendChild(titleH3Cobertura);
            coberturaRow.appendChild(divH3Cobertura);

            //título da tabela
            let titleTableResumo = document.createElement('div');
            titleTableResumo.classList.add('col','s12','titleTableResumo','titleTable1');

            let titleArray = ["Cobertura","Capital","Prêmio"];
            titleArray.forEach((title, i) => {
                let divTitle = document.createElement("div");
                if(i === 0) divTitle.classList.add("col","s8");
                else divTitle.classList.add("col","s2");
                if(i == titleArray.length-1) divTitle.classList.add("right-align");
                divTitle.innerHTML = title;
                titleTableResumo.appendChild(divTitle);
            });
            coberturaRow.appendChild(titleTableResumo);

            //tabela de resumo
            let coberturasResumo = document.createElement('div');
            coberturasResumo.classList.add('col','s12','coberturasResumo');

            //PLV-4488 INICIO
            if (restituicao) {
                divH3Cobertura.classList.add('hidden');
                titleTableResumo.classList.add('hidden');
                coberturasResumo.classList.add('hidden');
            }
            //PLV-4488 FIM

            // PLV-4455 - Inicio
            const ordemExibicaoPrioridade = {}, 
                  ordemExibicao = [];
        
            regrasGarantias.coberturas.forEach((cobertura)=> ordemExibicaoPrioridade[cobertura.prioridade] = cobertura.sigla);

            for(const key in ordemExibicaoPrioridade) {
                if(!ordemExibicao.includes(ordemExibicaoPrioridade[key])) ordemExibicao.push(ordemExibicaoPrioridade[key]);
            }

            pagamentoSelecionado.precificacao.coberturas.forEach(item=>{
                if(!ordemExibicao.includes(item.sigla))ordemExibicao.push(item.sigla)
            });

            ordemExibicao.forEach(siglaGarantia => { 
                let coberturaInfo = regrasGarantias.coberturas.filter(e => e.sigla == siglaGarantia).shift();
                let nomeCobertura = coberturaInfo ? coberturaInfo.nome || siglaGarantia : siglaGarantia;

                let capitalInfo = listaCoberturas.filter((e) => e.sigla == siglaGarantia).shift();
                let moeda = capitalInfo ? capitalInfo.moeda : "BRL";
                let capitalCobertura = capitalInfo ? capitalInfo.valor : 0;

                let premioCobertura = pagamentoSelecionado.precificacao.coberturas.filter((e) => e.sigla == siglaGarantia).shift();
                    premioCobertura = premioCobertura ? premioCobertura.premio.total : 0;
                
                let coberturaContainer = document.createElement('div');
                    coberturaContainer.classList.add('col','s12');
                    coberturaContainer.innerHTML = '<div class="row"></div>'

                let cobertura = document.createElement('div');
                    cobertura.classList.add('col', 's8');
                    cobertura.innerHTML = nomeCobertura;

                let capital = document.createElement('div');
                    capital.classList.add('col', 's2');
                    capital.innerHTML = 'Sim';

                if(capitalCobertura > 0){
                    capital.innerHTML = Intl.NumberFormat('pt-BR', {
                        style: 'currency',
                        currency: moeda
                    }).format(capitalCobertura) 
                }

                let premio = document.createElement('div');
                    premio.classList.add('col', 's2', 'right-align');
                    
                premio.innerHTML = Intl.NumberFormat('pt-BR', {
                    style: 'currency',
                    currency: 'BRL'
                }).format(premioCobertura); 
                    
                  
                coberturaContainer.children[0].appendChild(cobertura);
                coberturaContainer.children[0].appendChild(capital);
                coberturaContainer.children[0].appendChild(premio);
                coberturasResumo.appendChild(coberturaContainer);
            });
            // PLV-4455 - fim
            coberturaRow.appendChild(coberturasResumo);

            //linha do valor total
            let totalBeneficiosResumo = document.createElement('div');
            totalBeneficiosResumo.classList.add('col','s12','totalBeneficiosResumo','titleTableTotal');
            
            let outerDiv = document.createElement('div');
            outerDiv.classList.add('col','s12');
            
            let innerDiv1 = document.createElement('div');
            innerDiv1.classList.add('col','s6');
            innerDiv1.innerHTML = restituicao ? 'Valor a ser restituído' : 'Total';
            
            let innerDiv2 = document.createElement('div');
            innerDiv2.classList.add('col','s3','offset-s3','totalPremioBeneficios','right-align');
            innerDiv2.innerHTML = '<span></span>';

            let span = document.createElement('span');
            if(restituicao){
                span.innerHTML = Intl.NumberFormat('pt-BR', {
                    style: 'currency',
                    currency: 'BRL'
                }).format(valorRestituicao);// PLV-4455 - INICIO/FIM
                innerDiv2.appendChild(span);
            }else{
                span.innerHTML = Intl.NumberFormat('pt-BR', {
                    style: 'currency',
                    currency: 'BRL'
                }).format(valorTotalForm); // PLV-4455 - INICIO/FIM
                innerDiv2.appendChild(span);
            }

            outerDiv.appendChild(innerDiv1);
            outerDiv.appendChild(innerDiv2);
            totalBeneficiosResumo.appendChild(outerDiv)
            coberturaRow.append(totalBeneficiosResumo);
        }

        function carregaTabelaResumoVidaIndividual(ofertaSelecionada, listaOrdenada, valorPremioForm){
            //dados resumo
            //PLV-4325 Fix 2 - Início - Validando por garantias que existem na oferta
            let setSiglas = new Set();
            let s;
            listaOrdenada.forEach(cobertura => {
                s = ofertaSelecionada.regras.coberturas.filter(e => e.sigla == cobertura.sigla).shift();
                typeof s !== 'undefined' ? setSiglas.add(s.sigla) : false;
            });

            let temCobertura = ofertaSelecionada.regras.coberturas.some(item => setSiglas.has(item.sigla) && item.tipoGarantia == 'Cobertura');
            let temAssistenciaBeneficio = ofertaSelecionada.regras.coberturas.some(item => setSiglas.has(item.sigla) && (item.tipoGarantia == 'Assistência' || item.tipoGarantia == 'Benefício'));
            //PLV-4325 Fix 2 - Fim

            let coberturaRow = document.querySelector('.resumo .row.cobertura');
            coberturaRow.innerHTML = '';

            // TKCL 240-FIX03 INICIO
            let assistenciaRow = document.querySelector('.resumo .row.assistenciaBeneficio');
            assistenciaRow.innerHTML = '';
            // TKCL 240-FIX03 FIM

            //título 'Coberturas'
            let divH3Cobertura = document.createElement('div');
            divH3Cobertura.classList.add('col','s12','center-align');
            let titleH3Cobertura = document.createElement('h3');
            titleH3Cobertura.innerHTML = 'Coberturas';
            divH3Cobertura.appendChild(titleH3Cobertura);
            coberturaRow.appendChild(divH3Cobertura);

            // TKCL 240-FIX03 INICIO
            //título 'Assistências e Benefícios'
            let divH3Assistencia = document.createElement("div");
            divH3Assistencia.classList.add("col","s12","center-align");
            let titleH3Assistencia = document.createElement("h3");
            titleH3Assistencia.innerHTML = "Assistências e Benefícios";
            divH3Assistencia.appendChild(titleH3Assistencia);
            assistenciaRow.appendChild(divH3Assistencia);
            // TKCL 240-FIX03 FIM
            
            //cabeçalho da tabela coberturas
            let titleTableResumo = document.createElement('div');
            titleTableResumo.classList.add('col','s12','titleTableResumo','titleTable1');

            // TKCL 240-FIX03 INICIO
            let titleArray = ["Cobertura","Capital","Carência","Franquia","Prêmio"];
            titleArray.forEach((title, i) => {
                let divTitle = document.createElement("div");
                if(i == 0) divTitle.classList.add("col","s4");
                else divTitle.classList.add("col","s2");
                if(i == titleArray.length-1) divTitle.classList.add("right-align");
                divTitle.innerHTML = title;
                titleTableResumo.appendChild(divTitle);
            });
            // TKCL 240-FIX03 FIM

            //cabeçalho da tabela assistencias e beneficios
            let titleTableResumoAB = document.createElement('div');
            titleTableResumoAB.classList.add('col','s12','titleTableResumo','titleTable1');

            // TKCL 240-FIX03 INICIO
            let titleArrayAB = ["Cobertura","Capital","Carência","Franquia","Prêmio"];
            titleArrayAB.forEach((title, i) => {
                let divTitleAB = document.createElement("div");
                if(i == 0) divTitleAB.classList.add("col","s4");
                else divTitleAB.classList.add("col","s2");
                if(i == titleArrayAB.length-1) divTitleAB.classList.add("right-align");
                divTitleAB.innerHTML = title;
                titleTableResumoAB.appendChild(divTitleAB);
            });
            // TKCL 240-FIX03 FIM

            // TKCL 240-FIX03 INICIO
            coberturaRow.appendChild(titleTableResumo);
            assistenciaRow.appendChild(titleTableResumoAB);
            // TKCL 240-FIX03 FIM 

            //tabela de resumo coberturas
            let coberturasResumo = document.createElement('div');
            coberturasResumo.classList.add('col','s12','coberturasResumo');

            // TKCL 240-FIX03 INICIO
            //tabela de resumo assistencias e beneficios
            let assistenciasResumo = document.createElement('div');
            assistenciasResumo.classList.add('col','s12','assistenciasResumo');
            // TKCL 240-FIX03 FIM

            //PLV-4488 INICIO
            if (restituicao) {
                divH3Cobertura.classList.add('hidden');
                divH3Assistencia.classList.add('hidden');
                titleTableResumo.classList.add('hidden');
                coberturasResumo.classList.add('hidden');
                assistenciasResumo.classList.add('hidden'); // TKCL 240-FIX03 INICIO/FIM
            }
            //PLV-4488 FIM

            let selectPlanoParc = document.querySelector('.planoParcelamentos option:checked');
            let percentual = selectPlanoParc && typeof selectPlanoParc.dataset.percentual != 'undefined' ? selectPlanoParc.dataset.percentual : 0
            
            let indice;
            ofertaSelecionada.retornosCalculo.forEach((item, index) => {
                console.log('indice', index);
                console.log('percentual', percentual);
                console.log('percentualItem', item.precificacao.descontoAgravo[0].percentual);
                if(item.precificacao.descontoAgravo[0].percentual===parseFloat(percentual)){
                    indice = index;
                }
            });
            console.log('indice', indice);
            let valorTotal = 0;
            //console.log('listaOrdenada', listaOrdenada);
            listaOrdenada.forEach(sigla => {

                let coberturaPremio = ofertaSelecionada.retornosCalculo[indice].precificacao.coberturas.filter(e => e.sigla == sigla.sigla).shift();
                let coberturaNome = ofertaSelecionada.regras.coberturas.filter(e => e.sigla == sigla.sigla).shift();
                console.log('Cobertura...',sigla);
                // Criando os elementos 
                let coberturaContainer = document.createElement('div');
                coberturaContainer.classList.add('col');
                coberturaContainer.classList.add('s12');
                coberturaContainer.innerHTML = '<div class="row"></div>'

                let cobertura = document.createElement('div');
                cobertura.classList.add('col');
                cobertura.classList.add('s4');

                let capital = document.createElement('div');
                capital.classList.add('col');
                capital.classList.add('s2');

                let carencia = document.createElement('div');
                carencia.classList.add('col');
                carencia.classList.add('s2');

                let franquia = document.createElement('div');
                franquia.classList.add('col');
                franquia.classList.add('s2');

                let premio = document.createElement('div');
                premio.classList.add('col');
                premio.classList.add('s2');
                premio.classList.add('right-align');

                cobertura.innerHTML = coberturaNome.nome;
                capital.innerHTML = sigla.valor ? Intl.NumberFormat('pt-BR', {
                    style: 'currency',
                    currency: sigla.moeda ? sigla.moeda : 'BRL'
                }).format(sigla.valor) : 'Sim';
                
                if(coberturaNome.carencias) {
                    carencia.innerHTML = 'Sim';
                } else {
                    carencia.innerHTML = 'Não';
                }

                if(coberturaNome.franquias) {
                    franquia.innerHTML = 'Sim';
                } else {
                    franquia.innerHTML = 'Não';
                }

                premio.innerHTML = Intl.NumberFormat('pt-BR', {
                    style: 'currency',
                    currency: 'BRL'
                }).format(coberturaPremio ? coberturaPremio.premio.total : 0);
                valorTotal = coberturaPremio? (valorTotal + parseFloat(coberturaPremio.premio.total)) : valorTotal;
                coberturaContainer.children[0].appendChild(cobertura);
                coberturaContainer.children[0].appendChild(capital);
                coberturaContainer.children[0].appendChild(carencia);
                coberturaContainer.children[0].appendChild(franquia);
                coberturaContainer.children[0].appendChild(premio);
                // TKCL 240-FIX03 INICIO
                if(coberturaNome && (coberturaNome.tipoGarantia == 'Cobertura')) {
                    console.log('coberturaRow......');
                    coberturasResumo.appendChild(coberturaContainer);
                    coberturaRow.appendChild(coberturasResumo);
                } else if (coberturaNome && (coberturaNome.tipoGarantia == 'Assistência')|| (coberturaNome.tipoGarantia == 'Benefício')) {
                    console.log('assistenciaRow......');
                    assistenciasResumo.appendChild(coberturaContainer);
                    assistenciaRow.appendChild(assistenciasResumo);
                }
                // TKCL 240-FIX03 FIM
            });  
            // TKCL 240-FIX03 INÍCIO
            if (!temCobertura) {
                coberturaRow.classList.add('hidden');
            }
            if (!temAssistenciaBeneficio) {
                assistenciaRow.classList.add('hidden');
            }
            // TKCL 240-FIX03 FIM

            // if(temAssistenciaBeneficio){
            //     let assistenciaBeneficio = document.querySelector(".assistenciaBeneficio");
            //     assistenciaBeneficio.innerHTML = "";
                
            //     let titleH3 = document.createElement("h3");
            //     titleH3.innerHTML = "Assistências e Benefícios";
            //     let titleContainer = document.createElement("div");
            //     titleContainer.classList.add("col","s12","center-align");
            //     titleContainer.appendChild(titleH3);
                
            //     let beneficiosAssistenciasResumo = document.createElement("div");
            //     beneficiosAssistenciasResumo.classList.add("col","s12","beneficiosAssistenciasResumo");
            //     beneficiosAssistenciasResumo.innerHTML = "";

            //     listaOrdenada.forEach(sigla => {
            //         let itemAtual = ofertaSelecionada.regras.coberturas.filter(e => e.sigla == sigla.sigla).shift();
            //         if(itemAtual && (itemAtual.tipoGarantia == 'Assistência' || itemAtual.tipoGarantia == 'Benefício')){
            //             let abContainer = document.createElement('div');
            //             abContainer.classList.add('col');
            //             abContainer.classList.add('s12');
            //             abContainer.innerHTML = '<div class="row"></div>';
                        
            //             let nome = document.createElement("div");
            //             nome.classList.add("col","s6");
            //             nome.innerHTML = itemAtual.nome;
                        
            //             let valor = document.createElement('div');
            //             valor.classList.add("col","s6","right-align");
            //             valor.innerHTML = (typeof sigla.caracteristicaespecial !== "undefined") ?
            //                 sigla.caracteristicaespecial.tipo : 'Sim';
                            
            //             abContainer.appendChild(nome);
            //             abContainer.appendChild(valor);
            //             beneficiosAssistenciasResumo.appendChild(abContainer);
            //         }
            //     });
                
            //     assistenciaBeneficio.appendChild(titleContainer);
            //     assistenciaBeneficio.appendChild(beneficiosAssistenciasResumo);
            // }

            //linha do valor total
            let totalBeneficiosResumo =  document.querySelector(".totalBeneficiosResumo");
            totalBeneficiosResumo.innerHTML = "";
            totalBeneficiosResumo.classList.add('col','s12','titleTableTotal');
            
            let outerDiv = document.createElement('div');
            outerDiv.classList.add('col','s12');
            
            let innerDiv1 = document.createElement('div');
            innerDiv1.classList.add('col','s6');
            innerDiv1.innerHTML = restituicao ? 'Valor a ser restituído' : 'Total';
            
            let innerDiv2 = document.createElement('div');
            innerDiv2.classList.add('col','s3','offset-s3','totalPremioBeneficios','right-align');
            innerDiv2.innerHTML = '<span></span>';

            let span = document.createElement('span');

            if (restituicao) {
                span.innerHTML = Intl.NumberFormat('pt-BR', {
                    style: 'currency',
                    currency: 'BRL'
                }).format(valorRestituicao); // PLV-4455 - INICIO/FIM
                innerDiv2.appendChild(span);
            } else {
                span.innerHTML = Intl.NumberFormat('pt-BR', {
                    style: 'currency',
                    currency: 'BRL'
                }).format(valorTotal); // PLV-4455 - INICIO/FIM
                innerDiv2.appendChild(span);
            }


            outerDiv.appendChild(innerDiv1);
            outerDiv.appendChild(innerDiv2);
            totalBeneficiosResumo.appendChild(outerDiv);
        }
        //PLV-4325 - Fim

        (function questionarioRisco() {
            let container = document.getElementById('questionarioRisco');
            let questionarios = ofertaSelecionada.regras.questionarios;
            let mensagemRepresentante = null;  //PLV-4854

            //PLV-4854 - INÍCIO
            if(ofertaSelecionada && ofertaSelecionada.retornoAceitacao && 
                Array.isArray(ofertaSelecionada.retornoAceitacao.decisoes) && 
                ofertaSelecionada.retornoAceitacao.decisoes.length){
                    
                    let tipoSubscricao = ofertaSelecionada.retornoAceitacao.decisoes.find(
                        e => e.tipo && e.acao && e.tipo.toUpperCase() === "RISCO" && (
                            e.acao.toUpperCase() == "AUTO" ||
                            e.acao.toUpperCase() == "TELE" ||
                            e.acao.toUpperCase() == "VIDEO"
                        )
                    );
                    if(tipoSubscricao && tipoSubscricao.mensagemRepresentante){
                        mensagemRepresentante = tipoSubscricao.mensagemRepresentante;
                    } 
            }
            //PLV-4854 - FIM
            
            if (questionarios!=null && questionarios.length>0 && !mensagemRepresentante) {  //PLV-4854
                questionarios.forEach((e, i) => {
                    let input;
                    if (e.tipoResposta === 'Opção') {
                        input = document.createElement('select');
                        //PLV-4797 - INÍCIO
                        if(e.obrigatorio){
                            input.setAttribute('required', e.obrigatorio);
                        }
                        input.id = "pergunta_"+e.idPergunta; //PLV-4934 - INICIO/FIM
                        input.innerHTML = '<option value="" selected="true" disabled="true">Selecione</option>'; 
                        //PLV-4797 - FIM
                        input.classList.add('col');
                        input.classList.add('s12');
                        input.classList.add('l12');
                        e.opcoesRespostas.split(';').forEach(option => {
                            let optionTag = document.createElement('option');
                            optionTag.innerHTML = option;
                            input.appendChild(optionTag);
                        });

                        let inputContain = document.createElement('div');
                        inputContain.classList.add('input-field');
                        inputContain.classList.add('col');
                        inputContain.classList.add('s12');
                        inputContain.classList.add('l12');
                        inputContain.classList.add('selecionePergunta');
                        let labelForInput = document.createElement('label');
                        labelForInput.setAttribute('for', "pergunta_"+e.idPergunta); //PLV-4934 - INICIO/FIM
                        labelForInput.innerText = e.pergunta;

                        inputContain.appendChild(input);
                        inputContain.appendChild(labelForInput);
                        container.querySelector('.campos').appendChild(inputContain);
                        inicializaSelects();
                    } else {
                        input = document.createElement('input');
                        input.type = 'text';
                        input.id = "pergunta_"+e.idPergunta; //PLV-4934 - INICIO/FIM

                        let inputContain = document.createElement('div');
                        //PLV-4797 - INÍCIO
                        if(e.obrigatorio){
                            input.setAttribute('required', e.obrigatorio);
                        }
                        //PLV-4797 - FIM
                        inputContain.classList.add('input-field');
                        inputContain.classList.add('col');
                        inputContain.classList.add('s12');
                        inputContain.classList.add('l12');

                        let labelForInput = document.createElement('label');
                        labelForInput.setAttribute('for', "pergunta_"+e.idPergunta); //PLV-4934 - INICIO/FIM
                        labelForInput.innerText = e.pergunta;

                        let helper = document.createElement('span');
                        // console.log('e.idPergunta');
                        // console.log(e.idPergunta);
                        helper.classList.add('helper-text');

                        if (e.tipoResposta == 'Número') {
                            input.classList.add('numberMask');
                        } else if (e.tipoResposta == 'Data') {
                            input.classList.add('dataMask');
                        } else {
                            input.classList.add('textMask');
                        }

                        inputContain.appendChild(input);
                        inputContain.appendChild(labelForInput);
                        inputContain.appendChild(helper);
                        container.querySelector('.campos').appendChild(inputContain);
                    }
                });
                mascararCampos();
            } else {
                 //PLV-4854 - INÍCIO
                if (document.getElementById('questionarioRisco')) {
                    if(!mensagemRepresentante)  document.getElementById('questionarioRisco').remove();
                    else {
                        let campoMensagemRep = document.createElement('p');
                        let containerMessageRep = document.createElement('div');
                        campoMensagemRep.classList.add("col");
                        campoMensagemRep.classList.add("s12");
                        campoMensagemRep.innerText = mensagemRepresentante;
                        containerMessageRep.appendChild(campoMensagemRep);
                        container.querySelector('.campos').appendChild(containerMessageRep);
                        //container.querySelector('h3').innerText = "Declaração de Saúde";
                    } 
                }
                 //PLV-4854 - FIM
            }
        }());

        //PLV-5131 INICIO
        
        (function formularioCamposExtra(){
            if(individual){
                let grauParentesco = document.getElementById('grauParentescoBeneficiario');
                let nacionalidade = document.getElementById('NACIONALIDADE');
                let entradaServicos = JSON.parse(window.localStorage.getItem('jsonServicos'));
                let retornoServico = entradaServicos['PAISRESIDENTE'];
                let servicos = {
                    data: {},
                };
                console.log('entradaServicos[2] '+ entradaServicos['PAISRESIDENTE']);
                grauParentesco.addEventListener('change', event => {
                    let outrosDescField = document.getElementById('beneficiarioGrauParentescoOutros');
                    if (grauParentesco.value.toLowerCase() == 'outros'){
                        outrosDescField.parentElement.classList.remove('hidden');
                        outrosDescField.required = 'true';
                    }else if (grauParentesco.value.toLowerCase() != 'outros'){
                        outrosDescField.parentElement.classList.add('hidden');
                        outrosDescField.removeAttribute('required');
                    }
                });
                nacionalidade.addEventListener('change', event => {
                    let nacionalidadeOriginField = document.getElementById('PAISDEORIGEM');
                    if (nacionalidade.value.toUpperCase() == 'ESTRANGEIRA'){
                        nacionalidadeOriginField.parentElement.classList.remove('hidden');
                        nacionalidadeOriginField.required = 'true';
                        retornoServico.records.forEach(item => servicos.data["" + item.Label] = null);
                        nacionalidadeOriginField.addEventListener('change', (event) => {
                            let validaServico = retornoServico.records.filter(item => item.Label == event.target.value);
                            nacionalidadeOriginField.dataset.valor = validaServico.length > 0 ? validaServico[0].codigo : '0';
                        });
                        M.Autocomplete.init(nacionalidadeOriginField, servicos);
                    }else if (nacionalidade.value.toUpperCase() != 'ESTRANGEIRA'){
                        nacionalidadeOriginField.parentElement.classList.add('hidden'); 
                        nacionalidadeOriginField.removeAttribute('required');
                    }
                });
                
                // PLV-5099 INICIO
                let cpfBeneficiarioField = document.getElementById('cpfBeneficiario');
                    cpfBeneficiarioField.addEventListener('change', (evt) => {
                        if (!validaCPF(evt.target.value)) {
                            buildHelper(evt.target, 'CPF inválido');
                            evt.target.classList.add('invalid');
                        } else {
                            resetHelper(evt.target);
                            evt.target.classList.remove('invalid');
                            evt.target.classList.add('valid'); 
                        }
                    });
                // PLV-5099 FIM

            }
        }());
        
        //PLV-5131 FIM

        (function progParcelamentos() {
            let selectParc = document.querySelector("#TIPOPAGAMENTO");
            let selectPlanoParc = document.querySelector('.planoParcelamentos'); // PLV-4762 INICIO/FIM

            let grpParcelamentos = [...new Set(parcelamentos.map(e => e.descricao))];
            grpParcelamentos.forEach(parc1 => {
                let parc = parcelamentos.find(e => e.descricao == parc1);
                let codigo = parc.codigo;
                let agrupamento = parc.agrupamento;
                let descricao =  parc.nomeFormaPagamento; // PLV-4743 INICIO - FIM 
                let idFormaPagamento = parc.idFormaPagamento;

                let option = document.createElement('option');
                option.setAttribute('value', codigo);
                option.setAttribute('data-id', idFormaPagamento);
                option.setAttribute('data-layout', agrupamento);
                option.innerHTML = descricao;

                selectParc.appendChild(option);
            });
            selectParc.addEventListener('change', event => {
                let descontoOpcao = {}
                parcelamentoAtual = parcelamentos.filter(parcelamento => parcelamento.idFormaPagamento == event.target.querySelector('option:checked').dataset.id );

                parcelamentos.forEach((parcelamento,indice) => {
                    descontoOpcao[parcelamento.descontoAgravo] = parcelamento.opcao
                });

                document.querySelector('#OPCAO_PAGAMENTO').value = parcelamentoAtual[0].opcao;
                //let planoParcelamentos = parcelamentoAtual;
                let valorPremioDesconto = ofertaSelecionada.retornosCalculo.filter(e => e.opcao == parcelamentoAtual[0].opcao).shift().precificacao.premio.total;

                let resumoAzul = document.querySelector('.resumoAzul');
                resumoAzul.querySelector('.row.total .investimento').innerHTML = 'Seu investimento total: ' + Intl.NumberFormat('pt-BR', {
                    style: 'currency',
                    currency: 'BRL'
                }).format(valorPremioDesconto);
                resumoAzul.querySelector('.row.total .investimento').classList.remove('hidden');


                //if(planoParcelamentos.length == 1){
                // PLV-4762 INICIO/FIM - Remoção de linha de código
                selectPlanoParc.innerHTML = '<option value="" selected="selected" disabled="true">Selecione</option>';
                selectPlanoParc.setAttribute('required', 'true');
                
                if(parcelamentoAtual)
                parcelamentoAtual.sort(function (a, b) {
                    return a.qtdParcelas - b.qtdParcelas;
                });

                parcelamentoAtual.forEach(planoParc => {
                    let optionPlanoParc = document.createElement('option');
                    // optionPlanoParc.setAttribute('value', planoParc.idPlanoParcelamento);
                    // optionPlanoParc.setAttribute('data-codReceb', planoParc.codigoMeioRecebimento);
                    // optionPlanoParc.setAttribute('selected', 'true');
                    optionPlanoParc.value = planoParc.qtdParcelas;
                    optionPlanoParc.setAttribute('data-ac',planoParc.antecipacaoComissao); //PLV-4344 - Início/Fim
                    optionPlanoParc.innerHTML =
                        (planoParc.qtdParcelas == 1) ?
                        planoParc.qtdParcelas +
                        "x de " +
                        Intl.NumberFormat("pt-BR", {
                            style: "currency",
                            currency: "BRL"
                        }).format(planoParc.valorPrimeiraParcela) :
                        "1x de " +
                        Intl.NumberFormat("pt-BR", {
                            style: "currency",
                            currency: "BRL"
                        }).format(
                            planoParc.valorPrimeiraParcela
                        ) +
                        " + " +
                        (planoParc.qtdParcelas - 1) +
                        "x de " +
                        Intl.NumberFormat("pt-BR", {
                            style: "currency",
                            currency: "BRL"
                        }).format(planoParc.valorDemaisParcelas);

                    let valorTotal = planoParc.valorPrimeiraParcela ? parseFloat(planoParc.valorPrimeiraParcela) : 0
                    valorTotal = planoParc.qtdParcelas===1 ? valorTotal : (valorTotal + ((planoParc.qtdParcelas-1) * parseFloat(planoParc.valorDemaisParcelas)))

                    optionPlanoParc.setAttribute('data-percentual',planoParc.descontoAgravo);
                    optionPlanoParc.setAttribute('data-valortotal',valorTotal.toFixed(2));
                    optionPlanoParc.setAttribute('data-opcao',descontoOpcao[planoParc.descontoAgravo]);
                    selectPlanoParc.appendChild(optionPlanoParc);
                });
                document.querySelector('.containerParc').classList.remove('hidden');
                
                //PLV-4344 - Início
                let rowAntecipaComissao = document.querySelector('.antecipacaoComissao');
                if(rowAntecipaComissao){
                    let radioFalse = rowAntecipaComissao.querySelector('#N_Antecipa');
                    antecipaComissaoTransmissao = 0;
                    radioFalse.checked = true;
                    if (parcelamentoAtual[0].agrupamento != 'CartaoCredito')
                        !rowAntecipaComissao.classList.contains('hidden') ? rowAntecipaComissao.classList.add('hidden') : false;
                }
                //PLV-4344 - Fim

                //PLV-4203-VI - Início - Ajuste de data de vencimento das parcelas
                //PLV-4438 - Início
                handleVisibilityMelhorDataVencimento(); // PLV-4762 INICIO/FIM
                //PLV-4438 - Fim
                inicializaSelects();
                //PLV-4203-VI - Fim - Ajuste de data de vencimento das parcelas
                displayCCWarning(); // PLV-5088 INICIO/FIM

            });

            //PLV-5252 INICIO
            let fieldCCName = document.getElementById('cardName');
            fieldCCName.addEventListener('change', event => {
                if(fieldCCName.value.length > 30){
                    fieldCCName.value = fieldCCName.value.substring(0,30);
                }
            });
            //PLV-5252 FIM

            selectPlanoParc.addEventListener('change', handleVisibilityMelhorDataVencimento); // PLV-4762 INICIO/FIM
        }());

        //PLV-4344 - Início
        (function progAntecipaComissao() {
            let selectPlanoParc = document.querySelector('.planoParcelamentos');
            let rowAntecipaComissao = document.querySelector('.antecipacaoComissao');
            selectPlanoParc.addEventListener('change', evt =>{
                let planoParc = evt.target.querySelector('option:checked');
                if(rowAntecipaComissao){
                    /* ---
                    antecipaComissaoTransmissao:
                    0 - false
                    1 - true
                    2 - Pega valor do campo radio selecionado na tela de proposta ao invés do valor deste campo
                    --- */

                    const dataUser = JSON.parse(window.localStorage.getItem('dadosUsuario'));
                    const entradaConsultivo = JSON.parse(window.localStorage.getItem('entradaConsultivo'));
		    
                    let agenciamento = dataUser.filter(du => du.id == 'DICIO_AGENCIAMENTO').shift();
                    agenciamento = typeof agenciamento !== "undefined" ? parseInt(agenciamento.conteudo) : null; //PLV - 4507 Inicio / Fim

                    let corretagem = dataUser.filter(du => du.id == 'DICIO_CORRETAGEM').shift();
                    corretagem = typeof corretagem !== "undefined" ? parseInt(corretagem.conteudo) : null; //PLV - 4507 Inicio / Fim

                    if(!entradaConsultivo.consultivo.Cliente && typeof planoParc.dataset.ac !== 'undefined' && rowAntecipaComissao && corretagem != null) { //PLV - 4507 Inicio / Fim
                        if(endosso) { //PLV-5108 - INICIO
                            rowAntecipaComissao.classList.contains('hidden') ? rowAntecipaComissao.classList.remove('hidden') : false;
                            rowAntecipaComissao.querySelector('.title-field').innerText = 'Não é permitida a antecipação de comissão no endosso';
                            rowAntecipaComissao.querySelectorAll('label')[0].classList.add('hidden');
                            rowAntecipaComissao.querySelectorAll('label')[1].classList.add('hidden');
                            let radioFalse = rowAntecipaComissao.querySelector('#N_Antecipa');
                            radioFalse.checked = true;
                            antecipaComissaoTransmissao = 0;
                        //PLV-4721 - INICIO
                        } else if (agenciamento != null && agenciamento != 0) { //PLV-5108 - FIM 
                            !rowAntecipaComissao.classList.contains('hidden') ? rowAntecipaComissao.classList.add('hidden') : false;
                            antecipaComissaoTransmissao = 0;
                        } else if (planoParc.dataset.ac === 'true') { 
                            //PLV-4721 - FIM
                            !rowAntecipaComissao.classList.contains('hidden') ? rowAntecipaComissao.classList.add('hidden') : false;
                            let radioFalse = rowAntecipaComissao.querySelector('#N_Antecipa');
                            antecipaComissaoTransmissao = 1;
                            radioFalse.checked = true;
                        } else {
                            let corretagemOK = false;
                            let remCorretagem = ofertaSelecionada.regras.remuneracoes.filter( rem => rem.tipoRemuneracao.toLowerCase() == 'corretagem' ).shift();
                            
                            if(remCorretagem && remCorretagem.antecipacaoComissoes){
                                let limites = remCorretagem.antecipacaoComissoes.filter(ac => ac.tipoEvento.toLowerCase().includes(ofertaSelecionada.orcamento.tipoSeguro.toLowerCase())).shift();
                                if(limites && limites.limiteMinimo && limites.limiteMaximo)
                                    corretagemOK = limites.limiteMinimo < corretagem && corretagem <= limites.limiteMaximo ? true : false;
                            }

                            if((agenciamento == 0 || agenciamento == null) && corretagemOK) { //PLV - 4507 Inicio/Fim  /  PLV-4507-VI-Fix
                                rowAntecipaComissao.classList.contains('hidden') ? rowAntecipaComissao.classList.remove('hidden') : false;
                                antecipaComissaoTransmissao = 2;
                            } else {
                                antecipaComissaoTransmissao = 0;
                                !rowAntecipaComissao.classList.contains('hidden') ? rowAntecipaComissao.classList.add('hidden') : false;
                            }
                        }
                    } else {
                        !rowAntecipaComissao.classList.contains('hidden') ? rowAntecipaComissao.classList.add('hidden') : false; //PLV-4721
                        antecipaComissaoTransmissao = 0;
                    }
                    //console.log('aCT ', antecipaComissaoTransmissao);
                }
                if(planoParc.dataset.valortotal){
                   let resumoAzul = document.querySelector('.resumoAzul');
                    resumoAzul.querySelector('.row.total .investimento').innerHTML = 'Seu investimento total: ' + Intl.NumberFormat('pt-BR', {
                        style: 'currency',
                        currency: 'BRL'
                    }).format(parseFloat(planoParc.dataset.valortotal));
                    document.querySelector('#OPCAO_PAGAMENTO').value = planoParc.dataset.opcao;
                    resumoAzul.querySelector('.row.total .investimento').classList.remove('hidden'); 
                }
            })
        }());
        //PLV-4344 - Fim       

        //PLV-4203-VI - Início - Ajuste de data de vencimento das parcelas
        //PLV-4438 - Código removido 
        //PLV-4203-VI - Fim - Ajuste de data de vencimento das parcelas

        (function formatarEnvioFormulario() {
            let formularioVigente = document.getElementById('formularioProposta') ?
                document.getElementById('formularioProposta') :
                document.getElementById('formularioPropostaViagem') ?
                document.getElementById('formularioPropostaViagem') :
                null;
            if (formularioVigente) {
                formularioVigente.addEventListener('submit', e => {
                    e.preventDefault();
                    return false;
                });
            }
        }());
        (function metodoResponsavelFinanceiro() {
            document.querySelectorAll('[name="RESPFINANCEIRO"]').forEach(elem => {
                elem.addEventListener('change', (event) => {
                    if (event.target.value == 'Nao') {
                        document.querySelector('.respfin').classList.remove('hidden');
                        let campos = document.querySelector('.respfin').querySelectorAll('select, input:not(#TELOPCIONALRESPFIN):not(#NUMERORESPFIN):not(#COMPLEMENTORESPFIN)');
                        campos.forEach(e => {
                            e.setAttribute('required', 'true');
                            e.removeAttribute('requiredRemoved');
                            //PLV-4203 - Início - Validação de cpf do responsável financeiro
                            if (e.id == 'CPFRESP') {
                                e.addEventListener('change', (evt) => {
                                    if (!validaCPF(evt.target.value)) {
                                        buildHelper(evt.target, 'CPF inválido');
                                        evt.target.classList.add('invalid');
                                    } else {
                                        resetHelper(evt.target);
                                        evt.target.classList.remove('invalid');
                                    }
                                });
                            }
                            //PLV-4203 - Fim - Validação de cpf do responsável financeiro
                        });
                    } else {
                        document.querySelector('.respfin').classList.add('hidden');
                        let campos = document.querySelector('.respfin').querySelectorAll('[required]');
                        campos.forEach(e => {
                            e.removeAttribute('required');
                            e.setAttribute('requiredRemoved', 'true');
                            e.classList.remove('invalid');
                            e.value = '';
                        });
                    }
                });
            });
        }());

        (function coCorretor() {
            let remuneracoes = ofertaSelecionada.orcamento.remuneracoes;

            //PLV-4367 - INÍCIO
			//Ajuste temporário, o correto é que as remunerações venham sem o agenciamento
			if (remuneracoes.length > 0) {
                remuneracoes = remuneracoes.filter((r) => { return r.tipoRemuneracao.toLowerCase() != "agenciamento"; });
			}
			//PLV-4367 - FIM 

            if (remuneracoes.length > 0) {
                let elemCorretagem = document.querySelector('.listacorretores');
                //PLV-4324 - Início
                if(ofertaSelecionada.orcamento.segmento == 'Individual'){
                    let spanInfo = document.createElement('span');
                    spanInfo.className = 'center-align';
                    spanInfo.innerHTML = 'As porcentagens de corretagem somadas não podem ultrapassar o valor de 100%, então distribua cautelosamente entre os favorecidos';
                    elemCorretagem.appendChild(spanInfo);
                }
                //PLV-4324 - Fim
                remuneracoes.forEach(remuneracao => {
                    let container = document.createElement('div');
                    container.classList.add('section');
                    container.classList.add('corretagem'); //PLV-5160
                    let row = document.createElement('div');
                    row.classList.add('row');
                    let colCorretor = document.createElement('div');
                    colCorretor.classList.add('col');
                    colCorretor.classList.add('s8');
                    colCorretor.innerHTML = '<p class="title-field">' + remuneracao.tipoRemuneracao + '</p>';
                    let colPercentual = document.createElement('div');
                    colPercentual.classList.add('col');
                    colPercentual.classList.add('s4');
                    colPercentual.classList.add('right-align');
                    colPercentual.innerHTML = remuneracao.percentual + '%';

                    row.appendChild(colCorretor);
                    row.appendChild(colPercentual);
                    container.appendChild(row);

                    let rowAdicionarFavorecido = document.createElement('div');
                    rowAdicionarFavorecido.classList.add('row');
                    let colAdicionar = document.createElement('div');
                    colAdicionar.classList.add('col');
                    colAdicionar.classList.add('s12');
                    colAdicionar.classList.add('center-align');
                    //colAdicionar.innerHTML = '<a href="#" class="addCorretor btn-flat btnPortoSimple">Adicionar favorecido</a>';
                    let textnode = document.createTextNode("Adicionar Favorecido");
                    let btnAdicionar = document.createElement('a');
                    btnAdicionar.href = '#';
                    btnAdicionar.appendChild(textnode);
                    btnAdicionar.classList.add('addCorretor');
                    btnAdicionar.classList.add('btn-flat');
                    btnAdicionar.classList.add('btnPortoSimple');
                    let iconPlus = document.createElement('i');
                    iconPlus.classList.add('material-icons');
                    iconPlus.classList.add('left');
                    iconPlus.innerText = 'add_circle';

                    btnAdicionar.appendChild(iconPlus);
                    colAdicionar.appendChild(btnAdicionar);

                    rowAdicionarFavorecido.appendChild(colAdicionar);
                    container.appendChild(rowAdicionarFavorecido);

                    if (remuneracao.tipoRemuneracao.toUpperCase() == 'CORRETAGEM')
                        gerarFavorecido(container, remuneracao.tipoRemuneracao.toUpperCase(), true);

                    colAdicionar.querySelector('.addCorretor').addEventListener('click', event => {
                        event.preventDefault();
                        gerarFavorecido(container, remuneracao.tipoRemuneracao.toUpperCase());
                    });
                    //PLV-5160 INICIO
                    if(document.getElementsByClassName('corretagem').length == 0){
                        elemCorretagem.appendChild(container);
                    }
                    //PLV-5160 FIM
                    let entradaConsultivo = JSON.parse(window.localStorage.getItem('entradaConsultivo'));
                    if (entradaConsultivo.consultivo.Cliente) {
                        elemCorretagem.classList.add('corretagemCliente');
                    }
                });
            }
        }());

        //PLV-4386 - Início
        (function inicializaMelhorPeriodo() {
            let selectPeriodo = document.getElementById("MELHORPERIODO");
            if (selectPeriodo !== null) {
                let canal = "AUTO";
                if(ofertaSelecionada && ofertaSelecionada.retornoAceitacao && Array.isArray(ofertaSelecionada.retornoAceitacao.decisoes) && ofertaSelecionada.retornoAceitacao.decisoes.length){
                    let tipoSubscricao = ofertaSelecionada.retornoAceitacao.decisoes.find(e => e.descricao && e.descricao.toUpperCase() === "TIPO SUBSCRIÇÃO");
                    if(tipoSubscricao && tipoSubscricao.acao) canal = tipoSubscricao.acao.toUpperCase();
                }
                if(canal){
                    canal = canal.toUpperCase().trim();
                    if(canal != "TELE" && canal != "VÍDEO" && canal != "VIDEO") {
                        selectPeriodo.value = "I";
                        selectPeriodo.setAttribute("disabled","true");
                    }
                } else {
                    selectPeriodo.value = "I";
                    selectPeriodo.setAttribute("disabled","true");
                }
                M.FormSelect.init(selectPeriodo,{});
            }
        }());
        //PLV-4386 - Fim

        //PLV-4324 - Início
        (function inicializaAgenciamento() {
            if(ofertaSelecionada.orcamento.segmento == 'Individual') {
                let respostas = JSON.parse(window.localStorage.getItem('dadosUsuario'));
                let conteudoAgenciamento = respostas.filter(r => r.id == 'DICIO_AGENCIAMENTO').shift();
                agenciamento = conteudoAgenciamento ? conteudoAgenciamento.conteudo : 0;

                let bloco = document.querySelector('#blocoagenciamento');
                let para = document.querySelector('#AGENCIAMENTO_PARA');
                let agenciador = document.querySelector('#AGENCIADOR');

                if(agenciamento == 0) {
                    para.removeAttribute('required');
                    agenciador.removeAttribute('required');
                    bloco.classList.add('hidden');
                } else {
                    para.setAttribute('required', 'required');
                    para.addEventListener('change', event => {
                        let camposBusca = document.querySelectorAll('.busca_agenciador');
                        camposBusca.forEach(input => {
                            input.parentNode.classList.remove('hidden');
                            input.value = "";
                        });
                        document.querySelector('#btn_busca_agenciador').parentNode.classList.remove('hidden');
                        document.querySelector('#AGENCIADOR').parentNode.parentNode.classList.add('hidden');
                        if(event.target.value == "CORRETOR"){
                            document.querySelector('#btn_busca_agenciador').parentNode.classList.add('hidden');

                            // INICIO PLV-4711
                            let cpfAgenciador = document.querySelector('#CPF_AGENCIADOR');
                            cpfAgenciador.parentNode.classList.add('hidden');
                            cpfAgenciador.setAttribute('disabled', 'disabled');
                            
                            let nomeAgenciador = document.querySelector('#NOME_AGENCIADOR');
                            nomeAgenciador.parentNode.classList.add('hidden');
                            nomeAgenciador.setAttribute('disabled', 'disabled');
                            
                            let codigoAgenciador = document.querySelector('#CODIGO_AGENCIADOR');
                            codigoAgenciador.parentNode.classList.add('hidden');
                            codigoAgenciador.setAttribute('disabled', 'disabled');

                            let agenciador = document.querySelector('#AGENCIADOR');
                            agenciador.parentNode.classList.add('hidden');
                            agenciador.setAttribute('disabled', 'disabled');
                            agenciador.removeAttribute('required');

                            let susepAgenciador = document.querySelector('#SUSEP_AGENCIADOR');
                            susepAgenciador.value = "";
                            susepAgenciador.removeAttribute('disabled');
                            susepAgenciador.setAttribute('required', 'required');
                            susepAgenciador.parentNode.classList.remove('hidden');
                            susepAgenciador.classList.remove('invalid');
                            susepAgenciador.classList.remove('valid');
                            susepAgenciador.addEventListener('keyup', function (e) {
                                clearTimeout(typingTimer);
                                typingTimer = setTimeout(function () { buscaCorretor(e.target); }, doneTypingInterval);
                            });
                            susepAgenciador.addEventListener('keydown', function () {
                                clearTimeout(typingTimer);
                            });
                            susepAgenciador.addEventListener('blur', function (e) { 
                                clearTimeout(typingTimer);
                                buscaCorretor(e.target);
                            });
                            // FIM PLV-4711

                            camposBusca.forEach(input => {
                                input.setAttribute('disabled', 'disabled');
                            });
                        }
                        if(event.target.value == "AGENCIADOR"){
                            document.querySelector('#btn_busca_agenciador').parentNode.classList.remove('hidden');
                            
                            // INICIO PLV-4711
                            let susepAgenciador = document.querySelector('#SUSEP_AGENCIADOR');
                            susepAgenciador.parentNode.classList.add('hidden');
                            susepAgenciador.setAttribute('disabled', 'disabled');
                            susepAgenciador.value = "";

                            let cpfAgenciador = document.querySelector('#CPF_AGENCIADOR');
                            cpfAgenciador.parentNode.classList.remove('hidden');
                            cpfAgenciador.removeAttribute('disabled');
                            
                            let nomeAgenciador = document.querySelector('#NOME_AGENCIADOR');
                            nomeAgenciador.parentNode.classList.remove('hidden');
                            nomeAgenciador.removeAttribute('disabled');
                            
                            let codigoAgenciador = document.querySelector('#CODIGO_AGENCIADOR');
                            codigoAgenciador.parentNode.classList.remove('hidden');
                            codigoAgenciador.removeAttribute('disabled');

                            let agenciador = document.querySelector('#AGENCIADOR');
                            agenciador.parentNode.classList.remove('hidden');
                            agenciador.removeAttribute('disabled');
                            agenciador.setAttribute('required', 'required');
                            // FIM PLV-4711

                            camposBusca.forEach(input => {
                                input.removeAttribute('disabled');
                            });
                        }
                        camposBusca.forEach(input => {
                            input.focus();
                            input.blur();
                        });
                    });
                    agenciador.addEventListener('change', event => {
                        let arrayAgenciadores = JSON.parse(window.localStorage.getItem('jsonAgenciadores')).agenciadores;
                        if(Array.isArray(arrayAgenciadores) && arrayAgenciadores.length){
                            arrayAgenciadores.forEach(ag => {
                                //if( ag.codigoAgenciador == event.target.value){
                                if( ag.cpf == event.target.value || ag.cnpj == event.target.value){
                                    let cnpj_cpf = ag.cpf;
                                    if(!cnpj_cpf || cnpj_cpf === "" || cnpj_cpf == "null") cnpj_cpf = ag.cnpj;
                                    if(ag.susep == null || ag.susep == "null") ag.susep = "";
                                    if(ag.codigoAgenciador == null || ag.codigoAgenciador == "null") ag.codigoAgenciador = "";
                                    document.querySelector('#SUSEP_AGENCIADOR').value = ag.susep;
                                    document.querySelector('#CPF_AGENCIADOR').value = cnpj_cpf;
                                    document.querySelector('#NOME_AGENCIADOR').value = ag.nome;
                                    document.querySelector('#CODIGO_AGENCIADOR').value = ag.codigoAgenciador;
                                    let camposBusca = document.querySelectorAll('.busca_agenciador');
                                    camposBusca.forEach(input => {
                                        if(input.hasAttribute("disabled")){
                                            input.removeAttribute('disabled');
                                            input.focus();input.blur();
                                            input.setAttribute('disabled', 'disabled');
                                        } else {
                                            input.focus();input.blur();
                                        }
                                    });
                                }
                            });                      
                        }
                    }); 
                }
            }
        }());
        //PLV-4324 - Fim

        (function preencherDadosPreenchidos() {
            console.log("tela proposta")
            if (window.localStorage.getItem('dadosTelaProposta')) {
                JSON.parse(window.localStorage.getItem('dadosTelaProposta')).forEach(e => {
                    let campo = document.getElementById(e.id);
                    console.log(campo);
                    if (campo){
                        if (campo.tagName == 'SELECT') {
                            campo.querySelectorAll('option').forEach(e => {
                                e.removeAttribute('selected');
                            });
                            //PLV-4912 - INÍCIO
                            let campoTemp = campo.querySelector('option[value="' + e.conteudo + '"]');

                            if(campoTemp){
                                campoTemp.setAttribute('selected', 'selected');
                                campo.M_FormSelect._handleSelectChangeBound();
                            }
                            //PLV-4912 - FIM
                        } else {
                            campo.value = e.conteudo
                        }
                    }
                });
                M.updateTextFields();

                window.localStorage.removeItem('dadosTelaProposta');
            }

            if (document.querySelectorAll('#formProposta .listaSegurados .segurado').length == window.localStorage.getItem('qtdSeguradosProposta')) {
                JSON.parse(window.localStorage.getItem('dadosSegurados')).forEach(e => {
                    let campo = e.id ?
                        document.getElementById(e.id) : [...document.querySelectorAll('[name="' + e.name + '"]')].find(e => e.checked);

                    if (campo.tagName == 'SELECT') {
                        campo.querySelectorAll('option').forEach(e => {
                            e.removeAttribute('selected');
                        });
                        campo.querySelector('option[value="' + e.conteudo + '"]').setAttribute('selected', 'selected');
                        campo.M_FormSelect._handleSelectChangeBound();
                    } else if (campo.type == 'radio') {
                        let input = [...document.querySelectorAll('[name="' + e.name + '"]')].find(elem => elem.value == e.conteudo);
                        input.checked = true;

                        if (input.value == 'RelacionamentoProximo') {
                            let prox = closestByClass(input, 'propPep').querySelector('.proxPep');
                            prox.classList.add('on');
                            prox.querySelectorAll('input, select').forEach(elem => {
                                elem.setAttribute('required', 'true');
                            });
                        }
                    } else {
                        campo.value = e.conteudo;
                    }
                });
                M.updateTextFields();

                window.localStorage.removeItem('dadosSegurados');
                window.localStorage.removeItem('qtdSeguradosProposta');
            }
        }());

        (function preencherValores() {
            let respostas = JSON.parse(window.localStorage.getItem('dadosUsuario'));
            let cliente = JSON.parse(window.localStorage.getItem('entradaConsultivo')).consultivo.Cliente;
            respostas.forEach(e => {
                if (document.querySelector('#' + e.id)) {
                    let input = document.querySelector('#' + e.id);
                    switch (input.tagName) {
                        case 'INPUT':
                            input.value = e.conteudo;
                            if (input.id == 'DICIO_CORRETAGEM' && cliente) {
                                input.setAttribute('hidden', 'hidden');
                                input.parentNode.classList.add('corretagemCliente');
                            }
                            if (input.id == 'DICIO_DATA_SAIDA' || input.id == 'DICIO_DATA_RETORNO') {
                                input.value = e.conteudo.split('-').reverse().join('/');
                            }
                            if (input.id == 'DICIO_DATANASCIMENTO') {
                                input.value = e.conteudo.split('-').reverse().join('/');
                            }
                            if (input.id != 'DICIO_NOME' && input.id != 'CPF') {
                                input.setAttribute('readonly', 'readonly');
                                input.setAttribute('disabled', 'disabled');
                            }
                            break;
                        case 'SELECT':
                            input.value = e.conteudo;
                            input.setAttribute('disabled', 'true');
                            input.querySelectorAll('option').forEach(e => {
                                e.removeAttribute('selected');
                                e.setAttribute('disabled', 'disabled');
                            });
                            let respostaSelect = e.conteudo.toString() == 'false' || e.conteudo.toString() == 'true' ?
                                e.conteudo.toString() == 'false' ? 'NAO' : 'SIM' :
                                e.conteudo;
                            input.querySelector('option[value="' + respostaSelect + '"]').setAttribute('selected', 'selected');
                            input.querySelector('option[value="' + respostaSelect + '"]').removeAttribute('disabled');
                    }
                }
            });
        }());

        (function progIdade() {
            let inputDtNascimento = document.getElementById('DICIO_DATANASCIMENTO').value;
            let birthDate = inputDtNascimento != null ? new Date(inputDtNascimento.split('/').reverse().join('-')) : false;
            if(birthDate){
                let ageDifMs = Date.now() - birthDate.getTime();
                let ageDate = new Date(ageDifMs);
                let retornoIdade =  Math.abs(ageDate.getUTCFullYear() - 1970);
                let inputIdade = document.getElementById('DICIO_IDADE');
                if(inputIdade) inputIdade.value = retornoIdade;
            }
        }());

        (function toogleFormaTrabalho() {
            let formaTrabalho = document.getElementById('DICIO_REGIME_TRABALHO');
            //let formaTrabalho = JSON.parse(window.localStorage.getItem('dadosUsuario')).filter(e => e.id == 'DICIO_REGIME_TRABALHO').shift().conteudo
            if (formaTrabalho) {
                let inputEmpresa = document.querySelector('#EMPRESATRABALHO');
                let inputRamoEmpresa = document.querySelector('#RAMOEMPRESA');
                if (formaTrabalho.value == "CLT") {
                    inputEmpresa.parentNode.classList.remove('hidden');
                    inputEmpresa.setAttribute('required', 'required');
                    inputRamoEmpresa.removeAttribute('required');               
                } else if (formaTrabalho.value == "PROFISSIONAL_LIBERAL") {
                    inputRamoEmpresa.parentNode.classList.remove('hidden');
                    inputRamoEmpresa.setAttribute('required', 'required');
                    inputEmpresa.removeAttribute('required');
                }else{
                    inputEmpresa.parentNode.classList.add('hidden');
                    inputRamoEmpresa.parentNode.classList.add('hidden');
                    inputEmpresa.removeAttribute('required');
                    inputRamoEmpresa.removeAttribute('required');
                }
            }
        }());

        (function toogleTermoGuarda() {
            let ResponseCalculo = JSON.parse(window.localStorage.getItem('jsonResponseCalculo'));
            let codOfertaSelecionada = window.localStorage.getItem('ofertaSelecionada');
            ofertaSelecionada = ResponseCalculo.ofertas.filter(e => e.orcamento.numeroOrcamento == codOfertaSelecionada).shift() || ResponseCalculo.ofertas[0];
            let retornoAceitacao = ofertaSelecionada.retornoAceitacao;
            if (retornoAceitacao && retornoAceitacao.decisoes!=null) {
                let verificaTermo = retornoAceitacao.decisoes.filter(e => e.acao == "TermoGuarda"); //PLV-4699
                if (verificaTermo.length > 0) {
                    let termoGuarda = document.querySelectorAll('.termoguarda');
                    termoGuarda.forEach(termo => {
                        termo.classList.remove('hidden');
                    });
                }
            }
        }());

        (function progTipoDocumento() {
            let tipoDocumento = document.getElementById('TIPODOCUMENTO');
            if (tipoDocumento) {
                 tipoDocumento.addEventListener('change', e => {
                     if(e.target.value != '0' ){
                        let numeroDocumento = document.querySelector('#NUMERODOCUMENTO');
                            numeroDocumento.setAttribute('required', 'required');
                        let orgaoEmissor = document.querySelector('#ORGAOEMISSOR');
                            orgaoEmissor.setAttribute('required', 'required');
                        let dataExpedicao = document.querySelector('#DATAEXPEDICAO');
                            dataExpedicao.setAttribute('required', 'required');
                     }
                 });
                 var event = new Event('change'); //PLV-4790 - INÍCIO
                 tipoDocumento.dispatchEvent(event); //PLV-4790 - FIM
            }
        }());

        if(checkOfertaSelecionadaIsEndossoVI()==true) setEndossoPage();
        else if(checkOfertaSelecionadaIsEndossoViagem()==true) setEndossoViagemPage(); //PLV-4600
    }
    formatacaoFormularioAPTLMK(); //TKCL-240 INICIO/FIM
    //AV-85 INICIO
    formatacaoFormularioPortoVidaON1();
    //AV-85 - FIM
});



function salvaDadosProposta(e) {
    e.preventDefault();

    let dadosProposta = [{
            id: 'DICIO_NOME',
            conteudo: document.getElementById('DICIO_NOME') ? document.getElementById('DICIO_NOME').value : null
        },
        {
            id: 'EMAIL',
            conteudo: document.getElementById('EMAIL') ? document.getElementById('EMAIL').value : null
        },
        {
            id: 'CPF',
            conteudo: document.getElementById('CPF') ? document.getElementById('CPF').value : null
        },
        {
            id: 'DICIO_DATANASCIMENTO',
            conteudo: document.getElementById('DICIO_DATANASCIMENTO') ? document.getElementById('DICIO_DATANASCIMENTO').value : null
        },
        {
            id: 'DICIO_SEXO',
            conteudo: document.getElementById('DICIO_SEXO') ? document.getElementById('DICIO_SEXO').value : null
        },
        {
            id: 'RESIDE_BRASIL',
            conteudo: document.getElementById('RESIDE_BRASIL') ? document.getElementById('RESIDE_BRASIL').value : null
        },
        {
            id: 'TIPO_VIAGEM',
            conteudo: document.getElementById('TIPO_VIAGEM') ? document.getElementById('TIPO_VIAGEM').value : null
        },
        {
            id: 'PAISRESIDENTE', //PLV-4912 - INÍCIO/FIM
            conteudo: document.getElementById('PAISRESIDENTE') ? document.getElementById('PAISRESIDENTE').value : null //PLV-4912 - INÍCIO/FIM
        },
        {
            id: 'DICIO_DATA_SAIDA',
            conteudo: document.getElementById('DICIO_DATA_SAIDA') ? document.getElementById('DICIO_DATA_SAIDA').value : null
        },
        {
            id: 'DICIO_DATA_RETORNO',
            conteudo: document.getElementById('DICIO_DATA_RETORNO') ? document.getElementById('DICIO_DATA_RETORNO').value : null
        },
        {
            id: 'DICIO_CORRETAGEM',
            conteudo: document.getElementById('DICIO_CORRETAGEM') ? document.getElementById('DICIO_CORRETAGEM').value : null
        },
        {
            id: 'DICIO_AVENTURA',
            conteudo: document.getElementById('DICIO_AVENTURA') ? document.getElementById('DICIO_AVENTURA').value : null
        },
        {
            id: 'DICIO_MOTOCICLETA',
            conteudo: document.getElementById('DICIO_MOTOCICLETA') ? document.getElementById('DICIO_MOTOCICLETA').value : null
        },
        {
            id: 'TELEFONE',
            conteudo: document.getElementById('TELEFONE') ? document.getElementById('TELEFONE').value : null
        },
        {
            id: 'CEP',
            conteudo: document.getElementById('CEP') ? document.getElementById('CEP').value : null
        },
        {
            id: 'TIPOENDERECO',
            conteudo: document.getElementById('TIPOENDERECO') ? document.getElementById('TIPOENDERECO').value : null
        },
        {
            id: 'LOGRADOUROCLIENTE',
            conteudo: document.getElementById('LOGRADOUROCLIENTE') ? document.getElementById('LOGRADOUROCLIENTE').value : null
        },
        {
            id: 'SEMNUMEROCLIENTE',
            conteudo: document.getElementById('SEMNUMEROCLIENTE') ? document.getElementById('SEMNUMEROCLIENTE').value : null
        },
        {
            id: 'NUMEROCLIENTE',
            conteudo: document.getElementById('NUMEROCLIENTE') ? document.getElementById('NUMEROCLIENTE').value : null
        },
        {
            id: 'COMPLEMENTO',
            conteudo: document.getElementById('COMPLEMENTO') ? document.getElementById('COMPLEMENTO').value : null
        },
        {
            id: 'BAIRROCLIENTE',
            conteudo: document.getElementById('BAIRROCLIENTE') ? document.getElementById('BAIRROCLIENTE').value : null
        },
        {
            id: 'CIDADECLIENTE',
            conteudo: document.getElementById('CIDADECLIENTE') ? document.getElementById('CIDADECLIENTE').value : null
        },
        {
            id: 'ESTADOCLIENTE',
            conteudo: document.getElementById('ESTADOCLIENTE') ? document.getElementById('ESTADOCLIENTE').value : null
        },
        {
            id: 'NOMECLIENTEALTERNATIVOSEGURADO0',
            conteudo: document.getElementById('NOMECLIENTEALTERNATIVOSEGURADO0') ? document.getElementById('NOMECLIENTEALTERNATIVOSEGURADO0').value : null
        },
        {
            id: 'TELCLIENTEALTERNATIVOSEGURADO0',
            conteudo: document.getElementById('TELCLIENTEALTERNATIVOSEGURADO0') ? document.getElementById('TELCLIENTEALTERNATIVOSEGURADO0').value : null
        },
    ];

    let segurados = document.querySelectorAll('#formProposta .listaSegurados .segurado');
    let dadosSegurados = [];

    window.localStorage.setItem('qtdSeguradosProposta', segurados.length);

    if (segurados.length > 0) {
        segurados.forEach((segurado, i) => {
            dadosSegurados = dadosSegurados.concat([{
                    id: 'NOMESEGURADO' + (i + 1),
                    conteudo: document.getElementById('NOMESEGURADO' + (i + 1)).value
                },
                {
                    id: 'CPFSEGURADO' + (i + 1),
                    conteudo: document.getElementById('CPFSEGURADO' + (i + 1)).value
                },
                {
                    id: 'DATANASCIMENTOSEGURADO' + (i + 1),
                    conteudo: document.getElementById('DATANASCIMENTOSEGURADO' + (i + 1)).value
                },
                {
                    id: 'SEXOSEGURADO' + (i + 1),
                    conteudo: document.getElementById('SEXOSEGURADO' + (i + 1)).value
                },
                {
                    id: 'RESIDEBRASILSEGURADO' + (i + 1),
                    conteudo: document.getElementById('RESIDEBRASILSEGURADO' + (i + 1)).value
                },
                {
                    id: 'TELEFONESEGURADO' + (i + 1),
                    conteudo: document.getElementById('TELEFONESEGURADO' + (i + 1)).value
                },
                {
                    id: 'NOMECLIENTEALTERNATIVOSEGURADO' + (i + 1),
                    conteudo: document.getElementById('NOMECLIENTEALTERNATIVOSEGURADO' + (i + 1)).value
                },
                {
                    id: 'TELCLIENTEALTERNATIVOSEGURADO' + (i + 1),
                    conteudo: document.getElementById('TELCLIENTEALTERNATIVOSEGURADO' + (i + 1)).value
                },
                {
                    id: null,
                    name: 'PEPUSUARIOSEGURADO' + (i + 1),
                    conteudo: [...document.querySelectorAll('[name="PEPUSUARIOSEGURADO' + (i + 1) + '"]')].find(e => e.checked).value
                },
                {
                    id: 'NOMEPESSOAEXPOSTASEGURADO' + (i + 1),
                    conteudo: document.getElementById('NOMEPESSOAEXPOSTASEGURADO' + (i + 1)).value
                },
                {
                    id: 'CPFPEPSEGURADO' + (i + 1),
                    conteudo: document.getElementById('CPFPEPSEGURADO' + (i + 1)).value
                },
                {
                    id: 'GRAUPARENTESCOPEPSEGURADO' + (i + 1),
                    conteudo: document.getElementById('GRAUPARENTESCOPEPSEGURADO' + (i + 1)).value
                },
            ]);
        });
    }

    window.localStorage.setItem('dadosSegurados', JSON.stringify(dadosSegurados));
    window.localStorage.setItem('dadosTelaProposta', JSON.stringify(dadosProposta));

    window.location.replace(e.target.href);
}


var cepResidencialEspecial = false; // PLV - 4852
var cepComercialEspecial = false; // PLV - 4852

// PLV - 4322 INICIO -> Alteração praticamente em função preencheendereço()
function preencheEndereco() {
    //console.log('cepAtualizado', cepAtualizado);
    let retornoEndereco = document.getElementById('retornoEndereco');
    //console.log(JSON.parse(retornoEndereco.value));
    let container = closestByClass(cepAtualizado, 'section');
    console.log('container', container);
    if (!JSON.parse(retornoEndereco.value).erro) {
        let objEnd =      JSON.parse(retornoEndereco.value).obterEnderecoPorCEPResponse.enderecosGuiaPostalEBO.enderecoGuiaPostalEBO;
        let objEndereco = objEnd.enderecoCompleto; // PLV - 4852
        console.log(objEnd);
        if (objEnd.cepCidade != null) {
            if (objEnd.cepName === 'CEPCOMERCIAL') {
                cepComercialEspecial = false; // PLV - 4852
                // PLV-4945-INICIO
                document.getElementById('ESTADOCOMERCIAL').parentNode.parentNode.classList.add('disabled'); // PLV - 4852
                if (objEndereco.bairro == " " || objEndereco.bairro == '' || objEndereco.bairro == null || objEndereco.bairro == undefined) {
                    container.querySelector('.bairrocom').parentNode.classList.remove('disabled');
                    document.getElementById('ESTADOCOMERCIAL').parentNode.parentNode.classList.remove('disabled');
                }else{
                    container.querySelector('.bairrocom').parentNode.classList.add('disabled');
                }
                if (objEndereco.cidade == " " || objEndereco.cidade == '' || objEndereco.cidade == null || objEndereco.cidade == undefined) {
                    container.querySelector('.cidadecom').parentNode.classList.remove('disabled');
                    document.getElementById('ESTADOCOMERCIAL').parentNode.parentNode.classList.remove('disabled');
                }else{
                    container.querySelector('.cidadecom').parentNode.classList.add('disabled');
                }
                if (objEndereco.logradouro == " " || objEndereco.logradouro == '' || objEndereco.logradouro == null || objEndereco.logradouro == undefined) {
                    container.querySelector('.logradourocom').parentNode.classList.remove('disabled');
                    document.getElementById('ESTADOCOMERCIAL').parentNode.parentNode.classList.remove('disabled');
                }else{
                    container.querySelector('.logradourocom').parentNode.classList.add('disabled');
                }
                // PLV-4945-FIM
                //PLV - 4801 - INICIO
                setEnderecoInputValue('.logradourocom', [objEndereco.tipoLogradouro, objEndereco.logradouro].join(' '));
                setEnderecoInputValue('.bairrocom', objEndereco.bairro ? objEndereco.bairro.slice(0,40) : ''); //PLV-5074
                setEnderecoInputValue('.cidadecom', objEndereco.cidade);
                //PLV - 4801 - FIM
                setEstadoEndereco('ESTADOCOMERCIAL', objEndereco.uf); // PLV - 4852

                //PLV-5176 INICIO
                document.getElementById('LOGRADOUROCOMERCIAL').classList.remove('invalid');
                document.getElementById('BAIRROCOMERCIAL').classList.remove('invalid');
                document.getElementById('CIDADECOMERCIAL').classList.remove('invalid');
                document.getElementById('LOGRADOUROCOMERCIAL').classList.add('valid');
                document.getElementById('BAIRROCOMERCIAL').classList.add('valid');
                document.getElementById('CIDADECOMERCIAL').classList.add('valid');
                //PLV-5176 FIM
                //container.querySelector('.estadocom').blur();//PLV-4900 INICIO/FIM - PEDRO AUGUSTO BRAZ
                document.getElementById('NUMEROCOMERCIAL').focus();//PLV-4900 INICIO/FIM - PEDRO AUGUSTO BRAZ
            } else if (objEnd.cepName === 'CEPRESPFIN') {
                cepResidencialEspecial = false;
                // PLV-4945-INICIO
                document.getElementById('ESTADORESPFIN').parentNode.parentNode.classList.add('disabled'); // PLV - 4852
                if (objEndereco.logradouro == " " || objEndereco.logradouro == '' || objEndereco.logradouro == null || objEndereco.logradouro == undefined) {
                    container.querySelector('.logradourorespfin').parentNode.classList.remove('disabled');
                    document.getElementById('ESTADORESPFIN').parentNode.parentNode.classList.remove('disabled'); // PLV - 4852
                }else{
                    container.querySelector('.logradourorespfin').parentNode.classList.add('disabled');
                }
                if (objEndereco.bairro == " " || objEndereco.bairro == '' || objEndereco.bairro == null || objEndereco.bairro == undefined) {
                    container.querySelector('.bairrorespfin').parentNode.classList.remove('disabled');
                    document.getElementById('ESTADORESPFIN').parentNode.parentNode.classList.remove('disabled'); // PLV - 4852
                }else{
                    container.querySelector('.bairrorespfin').parentNode.classList.add('disabled');
                }
                if (objEndereco.cidade == " " || objEndereco.cidade == '' || objEndereco.cidade == null || objEndereco.cidade == undefined) {
                    container.querySelector('.cidaderespfin').parentNode.classList.remove('disabled');
                    document.getElementById('ESTADORESPFIN').parentNode.parentNode.classList.remove('disabled'); // PLV - 4852
                }else{
                    container.querySelector('.cidaderespfin').parentNode.classList.add('disabled');
                }
                // PLV-4945-FIM
                //PLV - 4801 - INICIO
                setEnderecoInputValue('.logradourorespfin', [objEndereco.tipoLogradouro, objEndereco.logradouro].join(' '));
                setEnderecoInputValue('.bairrorespfin', objEndereco.bairro ? objEndereco.bairro.slice(0,40) : ''); //PLV-5074
                setEnderecoInputValue('.cidaderespfin', objEndereco.cidade);
                //PLV - 4801 - FIM

                setEstadoEndereco('ESTADORESPFIN', objEndereco.uf); // PLV - 4852
                //container.querySelector('.estado').blur();//PLV-4900 INICIO/FIM - PEDRO AUGUSTO BRAZ
                document.getElementById('NUMERORESPFIN').focus(); //PLV-4900 INICIO/FIM - PEDRO AUGUSTO BRAZ
            } else {
                cepResidencialEspecial = false; // PLV - 4852
                // PLV-4945-INICIO
                document.getElementById('ESTADOCLIENTE').parentNode.parentNode.classList.add('disabled'); // PLV - 4852
                if (objEndereco.logradouro == " " || objEndereco.logradouro == '' || objEndereco.logradouro == null || objEndereco.logradouro == undefined) {
                    container.querySelector('.logradouro').parentNode.classList.remove('disabled');
                    document.getElementById('ESTADOCLIENTE').parentNode.parentNode.classList.remove('disabled'); // PLV - 4852
                }else{
                    container.querySelector('.logradouro').parentNode.classList.add('disabled');
                }
                if (objEndereco.bairro == " " || objEndereco.bairro == '' || objEndereco.bairro == null || objEndereco.bairro == undefined) {
                    container.querySelector('.bairro').parentNode.classList.remove('disabled');
                    document.getElementById('ESTADOCLIENTE').parentNode.parentNode.classList.remove('disabled'); // PLV - 4852
                }else{
                    container.querySelector('.bairro').parentNode.classList.add('disabled');
                }
                if (objEndereco.cidade == " " || objEndereco.cidade == '' || objEndereco.cidade == null || objEndereco.cidade == undefined) {
                    container.querySelector('.cidade').parentNode.classList.remove('disabled');
                    document.getElementById('ESTADOCLIENTE').parentNode.parentNode.classList.remove('disabled'); // PLV - 4852
                }else{
                    container.querySelector('.cidade').parentNode.classList.add('disabled');
                }
                // PLV-4945-FIM
                if (objEndereco.logradouro == " ") {
                    container.querySelector('.logradouro').parentNode.classList.remove('disabled');
                }
                //PLV - 4801 - INICIO
                setEnderecoInputValue('.logradouro', [objEndereco.tipoLogradouro, objEndereco.logradouro].join(' '));
                setEnderecoInputValue('.bairro', objEndereco.bairro ? objEndereco.bairro.slice(0,40) : ''); //PLV-5074
                setEnderecoInputValue('.cidade', objEndereco.cidade);
                //PLV - 4801 - FIM
                //PLV-5176 INICIO
                document.getElementById('LOGRADOUROCLIENTE').classList.remove('invalid');
                document.getElementById('BAIRROCLIENTE').classList.remove('invalid');
                document.getElementById('CIDADECLIENTE').classList.remove('invalid');
                document.getElementById('LOGRADOUROCLIENTE').classList.add('valid');
                document.getElementById('BAIRROCLIENTE').classList.add('valid');
                document.getElementById('CIDADECLIENTE').classList.add('valid');
                //PLV-5176 FIM

                setEstadoEndereco('ESTADOCLIENTE', objEndereco.uf); // PLV - 4852
                //container.querySelector('.estado').blur();//PLV-4900 INICIO/FIM - PEDRO AUGUSTO BRAZ
                document.getElementById('NUMEROCLIENTE').focus();//PLV-4900 INICIO/FIM - PEDRO AUGUSTO BRAZ
            }
        }else{
            if (cepAtualizado.name == 'CEPCLIENTE') {
                cepResidencialEspecial = true; // PLV - 4852

                container.querySelector('.logradouro').parentNode.classList.remove('disabled');
                container.querySelector('.bairro').parentNode.classList.remove('disabled');
                container.querySelector('.cidade').parentNode.classList.remove('disabled');
                document.getElementById('ESTADOCLIENTE').parentNode.parentNode.classList.remove('disabled'); // PLV - 4852

                if (cepComercialEspecial == false) {
                    container.querySelector('.logradourocom').parentNode.classList.add('disabled');
                    container.querySelector('.bairrocom').parentNode.classList.add('disabled');
                    container.querySelector('.cidadecom').parentNode.classList.add('disabled');
                    document.getElementById('ESTADOCOMERCIAL').parentNode.parentNode.classList.add('disabled'); // PLV - 4852
                }
                //PLV-5176 INICIO
                if(cepAtualizado.id == 'CEPCOMERCIAL'){
                    document.getElementById('NUMEROCOMERCIAL').focus();                 
                }else{
                    document.getElementById('NUMEROCLIENTE').focus(); //PLV-4900 INICIO/FIM - PEDRO AUGUSTO BRAZ //PLV-5374 INICIO/FIM
                }
                //PLV 5176 FIM
            } else if (cepAtualizado.name == 'CEPRESPFIN') {
                if (!viagem) { // PLV - 4852
                    cepComercialEspecial = true; // PLV - 4852

                    container.querySelector('.logradourocom').parentNode.classList.remove('disabled');
                    container.querySelector('.bairrocom').parentNode.classList.remove('disabled');
                    container.querySelector('.cidadecom').parentNode.classList.remove('disabled');
                    document.getElementById('ESTADOCOMERCIAL').parentNode.parentNode.classList.remove('disabled'); // PLV - 4852

                    if (cepResidencialEspecial == false) { // PLV - 4852
                        container.querySelector('.logradouro').parentNode.classList.add('disabled');
                        container.querySelector('.bairro').parentNode.classList.add('disabled');
                        container.querySelector('.cidade').parentNode.classList.add('disabled');
                        document.getElementById('ESTADOCLIENTE').parentNode.parentNode.classList.add('disabled'); // PLV - 4852
                    }

                } else { // PLV - 4852
                    container.querySelector('.logradouro').parentNode.classList.remove('disabled');
                    container.querySelector('.bairro').parentNode.classList.remove('disabled');
                    container.querySelector('.cidade').parentNode.classList.remove('disabled');
                    document.getElementById('ESTADOCLIENTE').parentNode.parentNode.classList.remove('disabled');
                    document.getElementById('NUMEROCLIENTE').focus(); //PLV-4900 INICIO/FIM - PEDRO AUGUSTO BRAZ
                }
            }else{
                if (!viagem) { // PLV - 4852
                    cepComercialEspecial = true; // PLV - 4852
                    
                    container.querySelector('.logradourocom').parentNode.classList.remove('disabled');
                    container.querySelector('.bairrocom').parentNode.classList.remove('disabled');
                    container.querySelector('.cidadecom').parentNode.classList.remove('disabled');
                    document.getElementById('ESTADOCOMERCIAL').parentNode.parentNode.classList.remove('disabled'); // PLV - 4852

                    if (cepResidencialEspecial == false) { // PLV - 4852
                        container.querySelector('.logradouro').parentNode.classList.add('disabled');
                        container.querySelector('.bairro').parentNode.classList.add('disabled');
                        container.querySelector('.cidade').parentNode.classList.add('disabled');
                        document.getElementById('ESTADOCLIENTE').parentNode.parentNode.classList.add('disabled'); // PLV - 4852
                    }
                    //PLV-5176 INICIO
                    if(cepAtualizado.id == 'CEPCOMERCIAL'){
                        document.getElementById('NUMEROCOMERCIAL').focus();                 
                    }
                    //PLV-5176 FIM
                } else { // PLV - 4852
                    container.querySelector('.logradouro').parentNode.classList.remove('disabled');
                    container.querySelector('.bairro').parentNode.classList.remove('disabled');
                    container.querySelector('.cidade').parentNode.classList.remove('disabled');
                    document.getElementById('ESTADOCLIENTE').parentNode.parentNode.classList.remove('disabled');
                    document.getElementById('NUMEROCOMERCIAL').focus();//PLV-4900 INICIO/FIM - PEDRO AUGUSTO BRAZ //PLV-5176 INICIO/FIM
                }
            }
        }
    }else{
        if (objEnd.cepCidade != null) {
            if (objEnd.cepName === 'CEPCOMERCIAL') {
                document.querySelector('.logradourocom').value = '';
                document.querySelector('.logradourocom').classList.remove('disabled');
                document.querySelector('.bairrocom').value = '';
                document.querySelector('.bairrocom').classList.remove('disabled');
                document.querySelector('.cidadecom').value = '';
                document.querySelector('.cidadecom').classList.remove('disabled');
                document.getElementById('ESTADOCOMERCIAL').parentNode.querySelector('input').value = ''; // PLV - 4852
                document.getElementById('ESTADOCOMERCIAL').parentNode.parentNode.classList.remove('disabled'); // PLV - 4852
            }else{
                //PLV - 4801 - INICIO
                setEnderecoInputValue('.logradouro', [objEndereco.tipoLogradouro, objEndereco.logradouro].join(' '));
                setEnderecoInputValue('.bairro', objEndereco.bairro ? objEndereco.bairro.slice(0,40) : ''); //PLV-5074
                setEnderecoInputValue('.cidade', objEndereco.cidade);
                //PLV - 4801 - FIM
                setEstadoEndereco('ESTADOCLIENTE', objEndereco.uf); // PLV - 4852
                //container.querySelector('.estado').blur();//PLV-4900 INICIO/FIM - PEDRO AUGUSTO BRAZ
            }
        } else {
            if (cepAtualizado.name == 'CEPCLIENTE') {
                cepResidencialEspecial = true; // PLV - 4852
                container.querySelector('.logradouro').parentNode.classList.remove('disabled');
                container.querySelector('.bairro').parentNode.classList.remove('disabled');
                container.querySelector('.cidade').parentNode.classList.remove('disabled');
                document.getElementById('ESTADOCLIENTE').parentNode.parentNode.classList.remove('disabled'); // PLV - 4852

                if (cepComercialEspecial == false) { // PLV - 4852
                    container.querySelector('.logradourocom').parentNode.classList.add('disabled');
                    container.querySelector('.bairrocom').parentNode.classList.add('disabled');
                    container.querySelector('.cidadecom').parentNode.classList.add('disabled');
                    document.getElementById('ESTADOCOMERCIAL').parentNode.parentNode.classList.add('disabled');
                }
            } else {
                if (!viagem) { // PLV - 4852
                    cepComercialEspecial = true; // PLV - 4852
                    
                    container.querySelector('.logradourocom').parentNode.classList.remove('disabled');
                    container.querySelector('.bairrocom').parentNode.classList.remove('disabled');
                    container.querySelector('.cidadecom').parentNode.classList.remove('disabled');
                    document.getElementById('ESTADOCOMERCIAL').parentNode.parentNode.classList.remove('disabled'); // PLV - 4852

                    if (cepResidencialEspecial == false) { // PLV - 4852
                        container.querySelector('.logradouro').parentNode.classList.add('disabled');
                        container.querySelector('.bairro').parentNode.classList.add('disabled');
                        container.querySelector('.cidade').parentNode.classList.add('disabled');
                        document.getElementById('ESTADOCLIENTE').parentNode.parentNode.classList.add('disabled');
                    }
                } else { // PLV - 4852
                    container.querySelector('.logradouro').parentNode.classList.remove('disabled');
                    container.querySelector('.bairro').parentNode.classList.remove('disabled');
                    container.querySelector('.cidade').parentNode.classList.remove('disabled');
                    document.getElementById('ESTADOCLIENTE').parentNode.parentNode.classList.remove('disabled');
                }
            }
        }
    }
    //PLV - 4801 - INICIO
    function setEnderecoInputValue(inputClass, value){
        let inputEl = container.querySelector(inputClass);

        if(!inputEl) return;

        inputEl.value = value;
        //inputEl.focus();//PLV-4900 - INICIO / FIM PEDRO AUGUSTO BRAZ

        let label = inputEl.parentNode.querySelector('label');
        if(!label) return;

        label.classList.add('active');
        
    }
    //PLV - 4801 - FIM

    // PLV - 4852 - INICIO
    function setEstadoEndereco(id, value) {
        let endereco = document.getElementById(id);
        if (!endereco) return;
        endereco.value = value; // set select element to value
    
        let enderecoInput = endereco.parentNode.querySelector('input');
        if (!enderecoInput) return;
        enderecoInput.value = value; // set materialize input to value

        let label = endereco.parentNode.parentNode.querySelector('label');
        if(!label) return;

        label.classList.add('active');
    }
    // PLV - 4852 - FINAL
}
// PLV - 4322 FINAL

function numeroComNCaracteres(numero, caracteres) {
    return numero.toString().split('').length < caracteres ? Array(caracteres - numero.toString().split('').length).fill(0).concat(numero.toString().split('')).join('') : numero;
}



// function gerarContrato() {
//     document.querySelector('.modalLoaderErro').classList.remove('on');
//     window.localStorage.setItem('retornoTransmissao', document.querySelector('#Transmissao').value);
//     let retornoTransmissao = window.localStorage.getItem('retornoTransmissao');
//     let objTransmissao = JSON.parse(retornoTransmissao);

//     let objPropostas = JSON.parse(window.localStorage.getItem('jsonEntradaTransmissao'));
//     let validacaoTransmissao = objTransmissao.devolutivasPropostas.some(e=>e.proposta);

//     if(validacaoTransmissao){
//         let pageContrato = document.getElementById('pageContrato');
//         document.querySelector('#formProposta').classList.add('hidden'); 
//         pageContrato.classList.remove('hidden');
//         irPasso(0,3);

//         objTransmissao.devolutivasPropostas.forEach(e=>{
//             let propostaContainer = document.createElement('tr');
//             let nomeProposta = document.createElement('td');
//                 nomeProposta.innerHTML = objPropostas.propostas.find(proposta=> proposta.indice == (e.proposta? e.proposta.indice: e.indice)).contratantes[0].grupos[0].segurados[0].pessoa.nome;
//             let numeroProposta = document.createElement('td');
//                 numeroProposta.innerHTML = e.message || e.proposta.origem + '-' + numeroComNCaracteres(e.proposta.numero, 8);

//             let iconVoucher = document.createElement('i');
//                 iconVoucher.classList.add('fas');
//                 iconVoucher.classList.add('fa-file-download');
//             let linkVoucher = document.createElement('a');
//                 linkVoucher.setAttribute('target', '_blank');
//                 linkVoucher.href = 'https://' + window.location.hostname + '/apex/VoucherPage1?numero=' + e.proposta.origem + '-' + numeroComNCaracteres(e.proposta.numero, 8);
//                 linkVoucher.classList.add('buttonPorto');
//                 linkVoucher.classList.add('download');
//                 linkVoucher.appendChild(iconVoucher);
//             let voucher = document.createElement('td');
//                 voucher.appendChild(linkVoucher);

//             propostaContainer.appendChild(nomeProposta);
//             propostaContainer.appendChild(numeroProposta);
//             propostaContainer.appendChild(voucher);
//             pageContrato.querySelector('.retornoPropostas table').appendChild(propostaContainer);
//         });
//     }
// }

//AV-85 INICIO
function storeRetornoId(idFormaPagamento){
    let jsonEntradaCalculo = JSON.parse(window.localStorage.getItem('jsonEntradaCalculo'));
    if(jsonEntradaCalculo.consultivo.codigoOfertaConsultiva == 'VIAGEM_VIDA_ON')window.localStorage.setItem('idFormaPagamento', idFormaPagamento);
}
//AV-85 FIM

function gerarContrato() {
    document.querySelector('.modalLoaderErro').classList.remove('on');
    window.localStorage.setItem('retornoTransmissao', document.querySelector('#Transmissao').value);
    let retornoTransmissao = window.localStorage.getItem('retornoTransmissao');
    let objTransmissao = JSON.parse(retornoTransmissao);
    let objPropostas = JSON.parse(window.localStorage.getItem('jsonEntradaTransmissao'));
    let validacaoPagamento = true;
    // AV-530 INICIO
    
    //let objTransmissao = JSON.parse('{"validacoesEstruturais":{"valido":false,"problemas":[{"indice":1,"codigo":10,"descricao":"Mesmo CPF aparece para dois segurados diferentes."},{"indice":1,"codigo":12,"descricao":"CPF inválido: dígito do CPF não bate com o número."},{"indice":3,"codigo":10,"descricao":"Mesmo CPF aparece para dois segurados diferentes."},{"integracao":"2.1","codigo":21,"descricao":"Corretor com bloqueio na Porto Seguro."},{"integracao":"2.4.1","codigo":241,"descricao":"Número de cartão inválido ou não reconhecido."},{"integracao":"2.4.2","codigo":242,"descricao":"Cartão recusado na validação."}]},"retornoFinanceiro":{"autorizacaoCartao":{"codigo":2,"mensagem":"APROVADO","codigoGateway":0,"mensagemGateway":"CAPTURED"}},"devolutivasPropostas":[{"proposta":{"origem":18,"numero":"18161","status":"Disponível para contratação","indice":1,"arquivos":[{"nome":"Voucher","link":"https://portoseguro--c.na59.content.force.com/sfc/dist/version/download/?oid=00Df4000000oD2K&ids=068f400000GlzPc&d=%2Fa%2Ff4000000giHH%2FzqJZFHFiLDe1iovFiyvBMc4bUpk4crqHYXHqShwv2aU&asPdf=true"}]},"retornoAceitacao":{"avisos":[{"codigo":10080,"descricao":"Segurado com risco de fraude.","area":"ACE","procedimento":"Informar ao sinistro e monitorar assistências solicitadas","mensagens":{"interna":"Inteligência artificial alerta para risco de fraude em assistências de viagem","representante":"Cliente com alto risco de fraude, verificar registro civil","cliente":"Problemas ao verificar CPF, entre em contato com o seu corretor"}}]}}]}');
    hasErroVidaOn = retornoTransmissao.includes("erroVidaOnMessage");
    //let hasErroVidaOn = false

    if(hasErroVidaOn){
        document.querySelector('#formProposta > .row.resumo').classList.add('hidden');
        let pageErrosVidaOn = document.getElementById('pageErros');
        pageErrosVidaOn.classList.remove('hidden');

        let botaoVoltar = document.querySelector('.voltarErroTransmissao');
        botaoVoltar.addEventListener('click', event => {
            pageErrosVidaOn.classList.add('hidden');
            document.querySelector('#formProposta > .formulario').classList.remove('hidden');
        });

        pageErrosVidaOn.querySelector('.errosGenericos').innerHTML = '';
        let erroVidaOn = document.createElement('span');
            erroVidaOn.classList.add('label-error');
            erroVidaOn.classList.add('col');
            erroVidaOn.classList.add('s12');
            erroVidaOn.innerHTML = objTransmissao.erroVidaOnMessage;
            pageErrosVidaOn.querySelector('.errosGenericos').appendChild(erroVidaOn);

        return;
    }
    // AV-530 FIM

    //PLV-4438 - Inicio
    //TKCL-458 - Inicio
    console.log('Retorno Financeiro: ......................', JSON.stringify(objTransmissao.retornoFinanceiro));
    if (objTransmissao.retornoFinanceiro) console.log('OBJ STARGATE: ......................', JSON.stringify(objTransmissao.retornoFinanceiro.autorizacaoCartao.stargate));
    if (objTransmissao.retornoFinanceiro) console.log('OBJ PORTOPAG: ......................', JSON.stringify(objTransmissao.retornoFinanceiro.autorizacaoCartao.portopag));
    let temCriticaPortopag = false;
    let cobrancaRejeitadaPortopag = false;
    if (objTransmissao.retornoFinanceiro && objTransmissao.retornoFinanceiro.autorizacaoCartao && 
            objPropostas.propostas[0].contratantes[0].dadosPagamento.dadosCartaoCredito!=null){ // PLV-4790
                console.log('Entrou no validacao cartao criticas');
               
                if (objTransmissao.retornoFinanceiro.autorizacaoCartao.portopag) {
                    cobrancaRejeitadaPortopag = objTransmissao.retornoFinanceiro.autorizacaoCartao.portopag.cobrancas && objTransmissao.retornoFinanceiro.autorizacaoCartao.portopag.cobrancas.some(cobranca => {
                        return cobranca.detalhes && cobranca.detalhes !== 'APPROVED';
                    });
                    console.log('CobrancaRejeitadaPortoPag?......',cobrancaRejeitadaPortopag);
                    temCriticaPortopag = ! objTransmissao.retornoFinanceiro.autorizacaoCartao.portopag.cobrancas || cobrancaRejeitadaPortopag;
                }
                console.log('Tem critica PortoPag?', temCriticaPortopag);
                validacaoPagamento = ( objTransmissao.retornoFinanceiro.autorizacaoCartao.stargate &&
                                       objTransmissao.retornoFinanceiro.autorizacaoCartao.stargate.codigo == 2) || 
                                     ( objTransmissao.retornoFinanceiro.autorizacaoCartao.portopag &&
                                      ! temCriticaPortopag) || false;
    }
    console.log('VALIDAÇÃO PAGAMENTO: ......................', validacaoPagamento);
    //TKCL-458 - Fim
    //PLV-4438 - Fim

    let validaTransmissao = [
        objTransmissao.validacoesEstruturais.valido,
        validacaoPagamento,
        objTransmissao.devolutivasPropostas.every(e => {
            return e.retornoAceitacao.recusas ? e.retornoAceitacao.recusas.length == 0 : true &&
                e.retornoAceitacao.analises ? e.retornoAceitacao.analises.length == 0 : true &&
                e.retornoAceitacao.avisos ? e.retornoAceitacao.avisos.length == 0 : true
        })
    ].every(e => e); //PLV-4790 - Removido nó 'pendência'

    

    if (validaTransmissao) {
        
        let pageContrato = document.getElementById('pageContrato');
        document.querySelector('#formProposta').classList.add('hidden');
        pageContrato.classList.remove('hidden');
        irPasso(0, 3);

        //PLV-4790 - INÍCIO
        if(!viagem &&  pageContrato.querySelector('#fieldPassageiro')){
            pageContrato.querySelector('#fieldPassageiro').innerText  = "Nome do segurado"; 
        }
        //PLV-4790 - FIM

        // TKCL 463 - INICIO
        let isAPTLMK = objPropostas.propostas[0].codigoProdutoVida == 'APTLMKT' ? true : false;
        // TKCL 463 - FIM

        //PLV-5121 - INÍCIO
       
         if(!isAPTLMK && !viagem && pageContrato.querySelector('#avisoCovid')){ // TKCL 463 - INICIO/FIM 
             pageContrato.querySelector('#avisoCovid').innerHTML = '<p>Se seu cliente tomou vacina para Covid-19, acesse o link e anexe o comprovante de vacinação ou salve o link para envio posterior. Lembre-se de ter em mãos o CPF ou numero da proposta do cliente</p> <a href="https://forms.gle/RVFkVLHck8tZAFgy8" target="_blank" rel="noopener noreferrer">Link para anexo de comprovante de vacinação</a>';
        }

        //PLV-5121 - FIM

        objTransmissao.devolutivasPropostas.forEach(e => {
            let propostaContainer = document.createElement('tr');
            let nomeProposta = document.createElement('td');
            nomeProposta.innerHTML = objPropostas.propostas.find(proposta => proposta.indice == (e.proposta ? e.proposta.indice : e.indice)).contratantes[0].grupos[0].segurados[0].pessoa.nome;
            let numeroProposta = document.createElement('td');
            const numeroDaProposta = e.proposta.origem + '-' + numeroComNCaracteres(e.proposta.numero, 8);
            numeroProposta.innerHTML = e.message || numeroDaProposta;

            // PLV-4754 - INICIO
            propostaContainer.appendChild(nomeProposta);
            propostaContainer.appendChild(numeroProposta);

            // PLV-5447 - INICIO
            const entradaConsultivo = JSON.parse(window.localStorage.getItem('entradaConsultivo'));
            if (entradaConsultivo.consultivo.codigoOfertaConsultiva === 'VIDA_INDIVIDUAL') {
                const entradaTransmissao = JSON.parse(window.localStorage.getItem('jsonEntradaTransmissao'));
                const proposta = entradaTransmissao.propostas[0];
                const showPdf = !proposta.termoGuarda && !proposta.assinaturaEletronica && !proposta.reaproveitarAssinatura;
                console.log('------------proposta-----------');
                console.log(proposta);
                console.log('-------------------------------');
                if (showPdf) {
                    const imprimirPdfAssinatura = document.createElement('td');
                    imprimirPdfAssinatura.classList.add('center-align');
                    imprimirPdfAssinatura.innerHTML = '<section class="modalLoaderErro" style="opacity: 1; background: none; position: relative; visibility: visible; width: auto; height: auto;"><div class="content"><div class="loader" style="width: 25px; height: 25px;"></div><div><p>Carregando PDF...</p></div></div></section>';
                    imprimirPdfAssinatura.id = 'pdfUrl';
                    propostaContainer.appendChild(imprimirPdfAssinatura);

                    if (numeroDaProposta !== null) {
                        const pdfInterval = setInterval(() => {
                            console.log("Visualforce", Visualforce);
                            Visualforce.remoting.Manager.invokeAction(
                                controllerActionName,
                                numeroDaProposta,
                                function(result, event) {
                                    if (result) {
                                        console.log("result", result);
                                        const pdfUrl = document.getElementById('pdfUrl');
                                        if (pdfUrl) {
                                            imprimirPdfAssinatura.innerHTML = '<a href=' + result + ' target="_blank" rel="noopener noreferrer" style="display: inline-block"><div style="width: 25px"><?xml version="1.0" encoding="UTF-8"?><svg enable-background="new 0 0 512 512" version="1.1" viewBox="0 0 512 512" xml:space="preserve" xmlns="http://www.w3.org/2000/svg"><path d="M128,0c-17.6,0-32,14.4-32,32v448c0,17.6,14.4,32,32,32h320c17.6,0,32-14.4,32-32V128L352,0H128z" fill="#E2E5E7"/><path d="m384 128h96l-128-128v96c0 17.6 14.4 32 32 32z" fill="#B0B7BD"/><polygon points="480 224 384 128 480 128" fill="#CAD1D8"/><path d="M416,416c0,8.8-7.2,16-16,16H48c-8.8,0-16-7.2-16-16V256c0-8.8,7.2-16,16-16h352c8.8,0,16,7.2,16,16  V416z" fill="#F15642"/><g fill="#fff"><path d="m101.74 303.15c0-4.224 3.328-8.832 8.688-8.832h29.552c16.64 0 31.616 11.136 31.616 32.48 0 20.224-14.976 31.488-31.616 31.488h-21.36v16.896c0 5.632-3.584 8.816-8.192 8.816-4.224 0-8.688-3.184-8.688-8.816v-72.032zm16.88 7.28v31.872h21.36c8.576 0 15.36-7.568 15.36-15.504 0-8.944-6.784-16.368-15.36-16.368h-21.36z"/><path d="m196.66 384c-4.224 0-8.832-2.304-8.832-7.92v-72.672c0-4.592 4.608-7.936 8.832-7.936h29.296c58.464 0 57.184 88.528 1.152 88.528h-30.448zm8.064-72.912v57.312h21.232c34.544 0 36.08-57.312 0-57.312h-21.232z"/><path d="m303.87 312.11v20.336h32.624c4.608 0 9.216 4.608 9.216 9.072 0 4.224-4.608 7.68-9.216 7.68h-32.624v26.864c0 4.48-3.184 7.92-7.664 7.92-5.632 0-9.072-3.44-9.072-7.92v-72.672c0-4.592 3.456-7.936 9.072-7.936h44.912c5.632 0 8.96 3.344 8.96 7.936 0 4.096-3.328 8.704-8.96 8.704h-37.248v0.016z"/></g><path d="m400 432h-304v16h304c8.8 0 16-7.2 16-16v-16c0 8.8-7.2 16-16 16z" fill="#CAD1D8"/></svg></div></a><div style="font-size: 12px;"><div class="tooltip" style="display: inline-block" data-descricao="Após impressão e assinatura encaminhar os documentos para emissao@vidaindividual.com.br"><i class="fas fa-info-circle"></i></div> Imprimir PDF da proposta para assinatura</div>';
                                            propostaContainer.appendChild(imprimirPdfAssinatura);
                                        }
                                        clearInterval(pdfInterval);
                                    }
                                }
                            );
                        }, 1500);
                    } else {
                        alert('Erro ao carregar pdf para impressão. Recarregue a página.');
                    }
                }
                // PLV-5478 - INICIO
                const showQuestionarioCorretor = proposta.remuneracoes.some(remuneracao => remuneracao.favorecidos.some(favorecido => favorecido.corretorLider && favorecido.corretorResponde));
                if (showQuestionarioCorretor && numeroDaProposta !== null) {
                    const questionario = document.createElement('td');
                    questionario.classList.add('center-align');
                    questionario.innerHTML = '<section class="modalLoaderErro" style="opacity: 1; background: none; position: relative; visibility: visible; width: auto; height: auto;"><div class="content"><div class="loader" style="width: 25px; height: 25px;"></div><div><p>Carregando Link...</p></div></div></section>';
                    propostaContainer.appendChild(questionario);
                    const questionarioInterval = setInterval(() => {
                        Visualforce.remoting.Manager.invokeAction(
                            controllerActionUrl,
                            numeroDaProposta,
                            function(result, event) {
                                console.log("result", result);
                                if (result) {
                                    console.log("result", result);
                                    questionario.innerHTML = '<div style="width: 15px; margin: auto;"><?xml version="1.0" encoding="iso-8859-1"?><svg version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 490 490" style="enable-background:new 0 0 490 490;" xml:space="preserve"><g><g id="XMLID_25_"><g><polygon style="fill:#AFB6BB;" points="430,100 340,100 340,10"/><polygon style="fill:#FFFFFF;" points="430,100 430,480 60,480 60,10 340,10 340,100 "/></g><g><path style="fill:#231F20;" d="M439.976,100c-0.001-2.602-0.993-5.159-2.905-7.071l-90-90c-1.913-1.912-4.47-2.904-7.071-2.905V0H60c-5.523,0-10,4.477-10,10v470c0,5.523,4.477,10,10,10h370c5.523,0,10-4.477,10-10V100H439.976z M350,34.142L405.858,90H350V34.142z M70,470V20h260v80c0,5.523,4.477,10,10,10h80v360H70z"/><rect x="130" y="160" style="fill:#231F20;" width="260" height="20"/><rect x="100" y="220" style="fill:#231F20;" width="290" height="20"/><rect x="100" y="280" style="fill:#231F20;" width="290" height="20"/><rect x="100" y="340" style="fill:#231F20;" width="290" height="20"/><rect x="100" y="400" style="fill:#231F20;" width="230" height="20"/><rect x="355" y="400" style="fill:#231F20;" width="35" height="20"/><rect x="100" y="45" style="fill:#231F20;" width="60" height="20"/><rect x="100" y="80" style="fill:#231F20;" width="120" height="20"/></g></g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g></svg></div><p style="font-size: 12px;">Clique <a href="' + result + '" target="_blank" rel="noopener noreferrer">aqui</a> para abrir o questionário</p>';
                                    propostaContainer.appendChild(questionario);
                                    clearInterval(questionarioInterval);
                                }
                            }
                        );
                    }, 1500);
                }
                // PLV-5478 - FIM
            }
            // PLV-5447 - FIM
            if(objPropostas.propostas[0].segmento == 'Viagem'){

                let iconVoucher = document.createElement('i');
                iconVoucher.classList.add('fas');
                iconVoucher.classList.add('fa-file-download');
                let linkVoucher = document.createElement('a');
                linkVoucher.setAttribute('target', '_blank');
                linkVoucher.href = 'https://' + window.location.hostname + '/apex/VoucherPage1?numero=' + e.proposta.origem + '-' + numeroComNCaracteres(e.proposta.numero, 8);
                linkVoucher.classList.add('btnPortoSuccess');
                linkVoucher.classList.add('download');
                linkVoucher.appendChild(iconVoucher);
                let voucher = document.createElement('td');
                voucher.appendChild(linkVoucher);
                propostaContainer.appendChild(voucher);
            }
            // PLV-4754 - FIM
            pageContrato.querySelector('.retornoPropostas table').appendChild(propostaContainer);
        });
        // PLV-4754 - INICIO
        if(objPropostas.propostas[0].segmento != 'Viagem'){
            document.querySelector('#fieldVoucher').classList.add('hidden')
        }
        // PLV-4754 - FIM

        // PLV-4790 - INÍCIO - Verificar se proposta passou com pendências
        let retornoPendencias = false;
        if(objTransmissao.devolutivasPropostas.length > 0) {
            retornoPendencias = objTransmissao.devolutivasPropostas.every(e => {
                return (e.retornoAceitacao && e.retornoAceitacao.pendencias ? e.retornoAceitacao.pendencias.length > 0 : false)
            });
        }
   
        if (retornoPendencias) {
            pageContrato.querySelector('.retornoPropostas').innerHTML += '<div id="pendenciasProposta" class="col s12"></div>';
            
            let titlePassageiros = document.createElement('th');
            if(viagem) titlePassageiros.innerHTML = 'Passageiro';
            else titlePassageiros.innerHTML = 'Segurado';
            let statusPassageiros = document.createElement('th');
            statusPassageiros.innerHTML = 'Status';
            let headerPassageiros = document.createElement('tr');
            headerPassageiros.appendChild(titlePassageiros);
            headerPassageiros.appendChild(statusPassageiros);
            let tabelaPassageiros = document.createElement('table');
            tabelaPassageiros.appendChild(headerPassageiros);

            if(!viagem)  tabelaPassageiros = document.createElement('div'); //PLV-4854
            
            
            let entradaTransmissao = JSON.parse(window.localStorage.getItem('jsonEntradaTransmissao'));
            pageContrato.querySelector('#pendenciasProposta').innerHTML = '<h1 class="center-align">Pendências</h1>';
        
        
            objTransmissao.devolutivasPropostas.forEach(proposta => {
        
                let nomeString = entradaTransmissao.propostas.find(e => e.indice == proposta.proposta.indice).contratantes[0].grupos[0].segurados[0].pessoa.nome;
                
                let retornosAceitacao = (proposta.retornoAceitacao) ? proposta.retornoAceitacao.pendencias : null;
        
                if (retornosAceitacao && retornosAceitacao.length > 0) {
                    retornosAceitacao.forEach(retorno => {
                        let nomePassageiro = document.createElement('td');
                        nomePassageiro.classList.add('nowrap');
                        nomePassageiro.innerHTML = '<span style="margin-right: 20px">' + proposta.proposta.indice + '.</span> ' + nomeString;
        
                        let erro = document.createElement('div');
                        erro.classList.add('label-warning');
                        erro.innerHTML = retorno.mensagens.cliente;
        
                        let statusPassageiro = document.createElement('td');
                        statusPassageiro.appendChild(erro);
        
                        let linhaPassageiro = document.createElement('tr');
                        linhaPassageiro.appendChild(nomePassageiro);
                        linhaPassageiro.appendChild(statusPassageiro);
        
                        if(viagem) tabelaPassageiros.appendChild(linhaPassageiro); //PLV-4854
                        else tabelaPassageiros.appendChild(erro); //PLV-4854
                    });
                }
            });
            
            pageContrato.querySelector('#pendenciasProposta').appendChild(tabelaPassageiros);
        }
        // PLV-4790 - FIM

    } else {
        
        document.querySelector('#formProposta > .row.resumo').classList.add('hidden');
        let pageErros = document.getElementById('pageErros');
        pageErros.classList.remove('hidden');

        let botaoVoltar = document.querySelector('.voltarErroTransmissao');
        botaoVoltar.addEventListener('click', event => {
            pageErros.classList.add('hidden');
            document.querySelector('#formProposta > .formulario').classList.remove('hidden');
        });

        (function errosGenericos() {
            pageErros.querySelector('.errosGenericos').innerHTML = '';
            let hasErros = false;
            if (!objTransmissao.validacoesEstruturais.valido || !validacaoPagamento) {
                let errosEstruturais = objTransmissao.validacoesEstruturais.problemas.filter(e => !e.indice);
                errosEstruturais.length > 0 ?
                    pageErros.querySelector('.errosGenericos').innerHTML += "<b>Contratação</b>" :
                    null;

                errosEstruturais.forEach(e => {
                    let erro = document.createElement('span');
                    erro.classList.add('label-error');
                    erro.classList.add('col');
                    erro.classList.add('s12');
                    //PLV-4438 - Inicio
                    erro.innerHTML = typeof e.integracao !== 'undefined' ? e.integracao + ' - ' + e.descricao : 
                                     typeof e.codigo !== 'undefined' ? e.codigo + ' - ' + e.descricao : e.descricao;
                    //PLV-4438 - Fim

                    pageErros.querySelector('.errosGenericos').appendChild(erro);
                    hasErros = true
                });
            }
            console.log('hasErros?...',hasErros);
            if (!hasErros && (!validacaoPagamento || 
                    (objTransmissao.retornoFinanceiro && objTransmissao.retornoFinanceiro.autorizacaoCartao.stargate.codigo != 2 && 
                    objTransmissao.retornoFinanceiro.autorizacaoCartao.stargate.codigo != null))) { // PLV-4790
                pageErros.querySelector('.errosGenericos').innerHTML += "<b>Efetivação do pagamento</b>";

                let erro = document.createElement('span');
                erro.classList.add('label-error');
                erro.classList.add('col');
                erro.classList.add('s12');
                // TKCL-458 - Inicio
                if (objTransmissao.retornoFinanceiro.autorizacaoCartao.stargate) {
                    erro.innerHTML = objTransmissao.retornoFinanceiro.autorizacaoCartao.stargate.mensagem != '' ?
                        objTransmissao.retornoFinanceiro.autorizacaoCartao.stargate.mensagem :
                        objTransmissao.validacoesEstruturais.problemas[0].descricao != '' ?
                        objTransmissao.validacoesEstruturais.problemas[0].descricao : 'Transação inválida';
                }
                if (objTransmissao.retornoFinanceiro.autorizacaoCartao.portopag) {
                     erro.innerHTML = cobrancaRejeitadaPortopag ? 'Cobrança não Autorizada' :
                        objTransmissao.retornoFinanceiro.autorizacaoCartao.portopag.mensagem != '' ?
                        objTransmissao.retornoFinanceiro.autorizacaoCartao.portopag.mensagem :
                        objTransmissao.validacoesEstruturais.problemas[0].descricao != '' ?
                        objTransmissao.validacoesEstruturais.problemas[0].descricao : 'Transação inválida';
                }
                 // TKCL-458 - Fim
                pageErros.querySelector('.errosGenericos').appendChild(erro);
            }
        }());

        (function errosEspecificos() {
            pageErros.querySelector('.errosEspecificos').innerHTML = '';

            let retornoAceitacao = objTransmissao.devolutivasPropostas.every(e => {
                //return (e.retornoAceitacao.pendencias ? e.retornoAceitacao.pendencias.length == 0 : true) &&  PLV-4790
                return (e.retornoAceitacao.recusas ? e.retornoAceitacao.recusas.length == 0 : true) &&
                    (e.retornoAceitacao.analises ? e.retornoAceitacao.analises.length == 0 : true) &&
                    (e.retornoAceitacao.avisos ? e.retornoAceitacao.avisos.length == 0 : true)
            })

            let errosEstruturais = objTransmissao.validacoesEstruturais.problemas.filter(e => e.indice);

            if (!objTransmissao.validacoesEstruturais.valido && errosEstruturais.length > 0) {
                pageErros.querySelector('.errosEspecificos').innerHTML += '<b>VALIDAÇÃO DOS DADOS DA CONTRATAÇÃO</b>';

                let entradaTransmissao = JSON.parse(window.localStorage.getItem('jsonEntradaTransmissao'));

                let titlePassageiros = document.createElement('th');
                if(viagem) titlePassageiros.innerHTML = 'Passageiro'; //PLV-4790
                else titlePassageiros.innerHTML = 'Segurado'; //PLV-4790
                let statusPassageiros = document.createElement('th');
                statusPassageiros.innerHTML = 'Status';
                let headerPassageiros = document.createElement('tr');
                headerPassageiros.appendChild(titlePassageiros);
                headerPassageiros.appendChild(statusPassageiros);
                let tabelaPassageiros = document.createElement('table');
                tabelaPassageiros.appendChild(headerPassageiros);

                pageErros.querySelector('.errosEspecificos').appendChild(tabelaPassageiros);

                entradaTransmissao.propostas.forEach(entrada => {

                    let erros = errosEstruturais.filter(e => e.indice == entrada.indice);
                    if (erros.length > 0) {
                        erros.forEach(erro => {
                            let nomeString = entradaTransmissao.propostas.find(proposta => proposta.indice == erro.indice).contratantes[0].grupos[0].segurados[0].pessoa.nome;

                            let nomePassageiro = document.createElement('td');
                            nomePassageiro.innerHTML = '<span style="margin-right: 20px;">' + erro.indice + '.</span> ' + nomeString;

                            let erroContainer = document.createElement('span');
                            erroContainer.classList.add('label-error');
                            erroContainer.innerHTML = erro.descricao;

                            let statusPassageiro = document.createElement('td');
                            statusPassageiro.appendChild(erroContainer);

                            let linhaPassageiro = document.createElement('tr');
                            linhaPassageiro.appendChild(nomePassageiro);
                            linhaPassageiro.appendChild(statusPassageiro);

                            tabelaPassageiros.appendChild(linhaPassageiro);
                        });
                    } else {
                        let nomeString = entrada.contratantes[0].grupos[0].segurados[0].pessoa.nome;

                        let nomePassageiro = document.createElement('td');
                        nomePassageiro.innerHTML = '<span style="margin-right: 20px;">' + entrada.indice + '.</span> ' + nomeString;

                        let erroContainer = document.createElement('span');
                        erroContainer.classList.add('label-success');
                        if(viagem) erroContainer.innerHTML = 'Tudo certo para a contratação desse passageiro'; //PLV-4790
                        else erroContainer.innerHTML = 'Tudo certo para a contratação desse segurado'; //PLV-4790
                       

                        let statusPassageiro = document.createElement('td');
                        statusPassageiro.appendChild(erroContainer);

                        let linhaPassageiro = document.createElement('tr');
                        linhaPassageiro.appendChild(nomePassageiro);
                        linhaPassageiro.appendChild(statusPassageiro);

                        tabelaPassageiros.appendChild(linhaPassageiro);
                    }
                });
            }
            if (!retornoAceitacao) {
                pageErros.querySelector('.errosEspecificos').innerHTML += '<b>Processo de aceitação da seguradora</b>';

                let titlePassageiros = document.createElement('th');
                if(viagem) titlePassageiros.innerHTML = 'Passageiro'; //PLV-4790
                else titlePassageiros.innerHTML = 'Segurado'; //PLV-4790
                let statusPassageiros = document.createElement('th');
                statusPassageiros.innerHTML = 'Status';
                let headerPassageiros = document.createElement('tr');
                headerPassageiros.appendChild(titlePassageiros);
                headerPassageiros.appendChild(statusPassageiros);
                let tabelaPassageiros = document.createElement('table');
                tabelaPassageiros.appendChild(headerPassageiros);

                let entradaTransmissao = JSON.parse(window.localStorage.getItem('jsonEntradaTransmissao'));


                objTransmissao.devolutivasPropostas.forEach(proposta => {

                    let nomeString = entradaTransmissao.propostas.find(e => e.indice == proposta.proposta.indice).contratantes[0].grupos[0].segurados[0].pessoa.nome;

                    let retornosAceitacao = proposta.retornoAceitacao.avisos
                        .concat(proposta.retornoAceitacao.analises)
                        //.concat(proposta.retornoAceitacao.pendencias) PLV-4790
                        .concat(proposta.retornoAceitacao.recusas);

                    if (retornosAceitacao.length > 0) {
                        retornosAceitacao.forEach(retorno => {
                            let nomePassageiro = document.createElement('td');
                            nomePassageiro.innerHTML = '<span style="margin-right: 20px">' + proposta.proposta.indice + '.</span> ' + nomeString;

                            let erro = document.createElement('span');
                            erro.classList.add('label-error');
                            erro.innerHTML = retorno.mensagens.cliente;

                            let statusPassageiro = document.createElement('td');
                            statusPassageiro.appendChild(erro);

                            let linhaPassageiro = document.createElement('tr');
                            linhaPassageiro.appendChild(nomePassageiro);
                            linhaPassageiro.appendChild(statusPassageiro);

                            tabelaPassageiros.appendChild(linhaPassageiro);
                        });
                    } else {
                        let nomePassageiro = document.createElement('td');
                        nomePassageiro.innerHTML = '<span style="margin-right: 20px">' + proposta.proposta.indice + '.</span> ' + nomeString;

                        let sucesso = document.createElement('span');
                        sucesso.classList.add('label-success');
                        if(viagem)  sucesso.innerHTML = 'Tudo certo para a contratação desse passageiro'; //PLV-4790
                        else  sucesso.innerHTML = 'Tudo certo para a contratação desse segurado'; //PLV-4790

                        let statusPassageiro = document.createElement('td');
                        statusPassageiro.appendChild(sucesso);

                        let linhaPassageiro = document.createElement('tr');
                        linhaPassageiro.appendChild(nomePassageiro);
                        linhaPassageiro.appendChild(statusPassageiro);

                        tabelaPassageiros.appendChild(linhaPassageiro);
                    }
                });

                pageErros.querySelector('.errosEspecificos').appendChild(tabelaPassageiros);
            }
        }());
    }
    window.scrollTo({ top: 0, behavior: 'smooth' }); //PLV-4854
}
/********* PLV-4367 - INÍCIO ***********/
function callConsultaAgenciadores(){
    let select = document.querySelector('#AGENCIADOR');
    let para = document.querySelector('#AGENCIAMENTO_PARA');
    select.parentNode.parentNode.classList.add('hidden'); 
    select.innerHTML = '';
    select.innerHTML = '<option disabled="true" selected="selected" value="0">Selecione</option>';
    window.localStorage.setItem('jsonAgenciadores', '{agenciadores:[]}');
 
    let cnpj_cpf = document.querySelector('#CPF_AGENCIADOR').value + "";
    let cpf = "";
    let cnpj = "";
    cnpj_cpf = cnpj_cpf.replace(/\D/g, "");
    if(cnpj_cpf.length == 11) cpf = cnpj_cpf;
    else cnpj = cnpj_cpf;
    
    let dados = {susep: document.querySelector('#SUSEP_AGENCIADOR').value,
                 codigoAgenciador: document.querySelector('#CODIGO_AGENCIADOR').value, 
                 cpf: cpf, 
                 cnpj: cnpj, 
                 nome: document.querySelector('#NOME_AGENCIADOR').value,
                 papel: para.value
                 };
    //console.log(JSON.stringify(dados)); 
    
    consultaAgenciadores(JSON.stringify(dados));
}
function retornoCallAgenciadores(){
    let para = document.querySelector('#AGENCIAMENTO_PARA');
    let jsonAgenciadores = document.querySelector('#retornoAgenciadores').value;
       window.localStorage.setItem('jsonAgenciadores', jsonAgenciadores);
    let arrayAgenciadores = JSON.parse(window.localStorage.getItem('jsonAgenciadores')).agenciadores;
    let select = document.querySelector('#AGENCIADOR');
    
    if(Array.isArray(arrayAgenciadores) && arrayAgenciadores.length){
        arrayAgenciadores.forEach(ag => {
            let opt = document.createElement('option');
            let cod = ag.codigoAgenciador;
            if(cod == null || cod == "null") cod = "???";
            let cnpj_cpf = ag.cpf;
            if(cnpj_cpf == null || cnpj_cpf == "null") cnpj_cpf = ag.cnpj;
            opt.value = cnpj_cpf;
            opt.innerHTML = cod + " - " + ag.nome;
            select.appendChild(opt);
        });
        if(arrayAgenciadores.length == 1 || para.value == "Corretor"){ 
            select.selectedIndex = 1;
            select.dispatchEvent(new Event('change'));
        }
    }
    
    M.FormSelect.init(select,{});
    document.querySelector('#AGENCIADOR').parentNode.parentNode.classList.remove('hidden');
}
//PLV-4324 - Início/Fim - Método transferido
/********** PLV-4367 - FIM ***********/
/********** PLV-4475 - INÍCIO ***********/		
function retornoCallCorretores(){
    let respostaCorretores = document.querySelector('#retornoCorretores').value;
    let respostaJson = JSON.parse(respostaCorretores);
    //console.log(respostaJson);
    let inputsCorretores = document.querySelectorAll('.listacorretores .row.corretorFavorecido input[type="text"]:not([disabled])');
    [].forEach.call(inputsCorretores, (input)=>{
            if(input.value == respostaJson.corretor){
            if(respostaJson.encontrado){
                input.classList.add("valid");
                input.classList.remove("invalid");
            } else {
                input.classList.remove("valid");
                input.classList.add("invalid");
            }
        }
    });

    // INICIO PLV-4711
    let inputSusepAgenciador = document.querySelector("#SUSEP_AGENCIADOR");
    if (inputSusepAgenciador.value == respostaJson.corretor) {
        if (respostaJson.encontrado) {
            inputSusepAgenciador.classList.add("valid");
            inputSusepAgenciador.classList.remove("invalid");
        } else {
            inputSusepAgenciador.classList.remove("valid");
            inputSusepAgenciador.classList.add("invalid");
        }
    }
    // FIM PLV-4711
}
/********** PLV-4475 - FIM ***********/
// PLV-4762 INICIO
function handleVisibilityMelhorDataVencimento(){
    let dataVenc = document.querySelector('.dataVenc');
    let selectParc = document.querySelector(".planoParcelamentos");

    if(!dataVenc) return;

    let isBoletoADC = selectParc && parcelamentoAtual[0].agrupamento == 'ADC' || parcelamentoAtual[0].codigo == 52 || parcelamentoAtual[0].codigo == 41;

    if (parcelamentoAtual[0].agrupamento == 'CartaoCredito' || parcelamentoAtual[0].codigo == 11) {
        dataVenc.classList.add('hidden');
    } else if(isBoletoADC && selectParc.value == 1){
        dataVenc.classList.add('hidden');
    }else if(isBoletoADC && selectParc.value != 1){
        dataVenc.classList.remove('hidden');
    }else if (parcelamentoAtual[0].agrupamento == 'Boleto' ){
        dataVenc.classList.remove('hidden');
    }
}
// PLV-4762 FIM

// PLV-5088 INICIO
function displayCCWarning(){
    let warningDIV = document.querySelector('.ccWarningMessage');
    let tipoSelecionado = parcelamentoAtual[0].codigo
    if (tipoSelecionado == 62){
        warningDIV.classList.remove('hidden');
    }else if (tipoSelecionado != 62){
        warningDIV.classList.add('hidden');
    }
}
// PLV-5088 FIM

//AV-85 - INICIO

//PLV-5066 INICIO 
function checkEndossoPgmt(){
    let oferta = getOfertaSelecionada()
    
    if(oferta.orcamento.tiposEndosso && oferta.orcamento.tiposEndosso.cad && oferta.orcamento.contratantes[0].manterPlanoParcelamento){
        let classFormaPag = document.querySelector(`.formapagamento`);
        classFormaPag.classList.add('hidden');
    }
}
function apagarPagmento1(){
    let oferta = getOfertaSelecionada()
    let jsonEntradaCalculoApagarPGM = JSON.parse(window.localStorage.getItem('jsonEntradaCalculo'));
    if(oferta.orcamento.tiposEndosso && oferta.orcamento.tiposEndosso.cad && oferta.orcamento.contratantes[0].manterPlanoParcelamento){
        let classFormaPag = document.querySelector(`.formapagamento`);
        classFormaPag.innerHTML = '';
        return true;
    }
}
//PLV-5066 FIM

//TKCL-240 INICIO
function formatacaoFormularioAPTLMK(){
    let codigoOfertaConsultiva = window.localStorage.getItem('jsonEntradaCalculo');
    //let segmentoOferta = window.localStorage.getItem('jsonOfertasMin');
    if(codigoOfertaConsultiva != null){
        //segmentoOferta = JSON.parse(segmentoOferta).ofertas[0].orcamento.segmento;
        codigoOfertaConsultiva = JSON.parse(codigoOfertaConsultiva).consultivo.codigoOfertaConsultiva;
        if(codigoOfertaConsultiva == 'APTLMK'){
            //Oculta campos do SEGURADO INFORMAÇÕES PESSOAIS
            //document.querySelector('#userInfo').classList.add('hidden');
            //Manipula campos do SEGURADO INFORMAÇÕES PESSOAIS
            document.querySelector('#NUMERODOCUMENTO').value = '';
            document.querySelector('#ORGAOEMISSOR').value = '';
            document.querySelector('#DATAEXPEDICAO').value = '';
            document.querySelector('#TIPODOCUMENTO').removeAttribute("required");
            document.querySelector('#NUMERODOCUMENTO').removeAttribute("required");
            document.querySelector('#ORGAOEMISSOR').removeAttribute("required");
            document.querySelector('#DATAEXPEDICAO').removeAttribute("required");
            document.querySelector('#DICIO_FUMANTE').removeAttribute("required");
            //TKCL-558 INICIO
            //document.querySelectorAll('.vacina, .blocoTrabalho, #BLOCOFUMANTE').forEach(element => element.classList.add('hidden'));
            document.querySelectorAll('.vacina, #BLOCOFUMANTE').forEach(element => element.classList.add('hidden'));
            //TKCL-558 FIM
            //Oculta o campo Regime Trabalho
            document.querySelector('.regimeTrabalho').classList.add('hidden'); //TKCL-558 INICIO-FIM
            //Manipula valor do campo de Vacina
            document.querySelector('#DICIO_CICLOCOVID option:first-child').setAttribute('selected', 'selected');
            //Manipula valor do campo EMPRESATRABALHO
            document.querySelector('#DICIO_REGIME_TRABALHO').value = 'Regime Trabalho';
            //Manipula valor do campo Forma de Trabalho
            document.querySelector('#EMPRESATRABALHO').value = 'Empresa Trabalho';
            //Manipula valor do campo RAMOEMPRESA
            document.querySelector('#RAMOEMPRESA').value = 'Ramo Empresa';
            //Manipula valor do campo RENDAMENSAL
            //document.querySelector('#RENDAMENSAL').value = '3000,00'; //TKCL-558 INICIO-FIM
            //Manipula valor do campo Fumante
            document.querySelector('#DICIO_FUMANTE option:first-child').setAttribute('selected', 'selected');
            console.log('Até aqui está ok');
            //Oculta campo de Endereço Comercial
            let blocoEndComercial = document.getElementById('BLOCOENDCOMERCIAL');
            blocoEndComercial.style.display = 'none';
            //Tirar de oculto o Termo de Guarda
            document.querySelectorAll('.termoguarda').forEach(element => element.classList.remove('hidden'));
            //document.querySelectorAll('.blocoPagamentoCartao').forEach(element => element.style.display = 'none');
            document.querySelector('#pergunta_2').style.margin = '25px 0 0 0';
            //Alterar texto do termo de guarda
            document.querySelector('.termoPadrao').classList.add('hidden');
            document.querySelector('.termoAPTLMKT').classList.remove('hidden');
            // document.querySelector('.termoguarda').innerHTML.add(`
            // <div class="col s12">
            //     <p>TERMO DE COMPROMISSO DO CORRETOR DE SEGUROS (PESSOA FÍSICA OU JURÍDICA) COM AS NORMAS
            //         PARA CONTRATAÇÃO DE SEGURO, MEDIANTE UTILIZAÇÃO DA CONFIRMAÇÃO ELETRÔNICA.</p>
            //     <p>Para agilizar o processo, disponibilizamos a opção de análise e emissão de propostas
            //         sem a necessidade do envio da proposta para Cia. Para mais informações, leia o Termo
            //         de Aceite no link abaixo</p>
            //     <a href="http://aplweb/docs/formularios/vida/termodecompromisso.pdf">Clique aqui para ler o Termo de Guarda</a>
            // </div>
            // `);
            let codRamo = JSON.parse(window.localStorage.getItem('jsonResponseCalculo')).ofertas[0].orcamento.ramoSeguro;
            let descricao = JSON.parse(window.localStorage.getItem('jsonResponseCalculo')).ofertas[0].orcamento.rotulo;
            let ofertaSelecionada = window.localStorage.getItem('ofertaSelecionada');
            console.log('ofertaSelecionada:' + ofertaSelecionada);
            let parcelas = JSON.parse(window.localStorage.getItem('jsonResponseCalculo')).ofertas[0].parcelamentos.length;
            const selectTipoPagamento = document.querySelector('#TIPOPAGAMENTO');
            selectTipoPagamento.addEventListener('change', (e) => {
                // debito em conta = '52', cartao de credito = '62', cartao porto = '97'
                if (e.target.value == '70' || e.target.value == '97') { //TKCL-441 FIX02 INICIO
                    Visualforce.remoting.Manager.invokeAction(
                        controllerActionAptlmk,
                        codRamo,
                        descricao,
                        ofertaSelecionada,
                        parcelas,
                        function(result) {
                            console.log('resultado request: ', result);
                            console.log('ofertaSelecionada:' + ofertaSelecionada);
                            if (result) {
                                const link = JSON.parse(result).link;
                                const token = link.split('&token=')[1];
                                window.localStorage.setItem('tokenAPI', token);
                                document.querySelectorAll('.blocoPagamentoCartao').forEach((element) => {element.style.display = 'none';
                                element.childNodes.forEach(element => {
                                    console.log('antes do if');
                                    element.innerHTML = '';
                                })
                                });
                                let a = document.getElementById('testePop');
                                let b = document.getElementById('testeModal');
                                a.style.display = 'block';
                                a.style.textAlign = 'center';
                                b.innerHTML = `<iframe src=${link} height=1200px width=700px frameborder=0 scrolling=no style="overflow-x:hidden;overflow-y:hidden;"></iframe>`;
                                //<button onclick="this.parentElement.style.display='none';" style = "position:relative; right:-705px; top:-750px; color:blue;" >X</button>`;
                                window.addEventListener("message", event => {
                                    console.log('event:', event);
                                    let dadosCartao = JSON.parse(event.data.message);
                                    window.localStorage.setItem('idCartao', dadosCartao.idCartao);
                                    const myTimeout = setTimeout(timeOutIframe, 5000);
                                    console.log(dadosCartao.idCartao);
                                })
                                return;
                            }
                        },
                        {escape: false}
                    );
                };
                if(e.target.value  == '52'){
                    document.getElementById('testePop').style.display = 'none';
                };
                function timeOutIframe() {
                    document.getElementById('testePop').style.display = 'none';
                  }
                  
            });
        }
    }
}

function formatacaoFormularioAPTLMK1(){
    let codigoOfertaConsultiva = window.localStorage.getItem('jsonEntradaCalculo');
    //let segmentoOferta = window.localStorage.getItem('jsonOfertasMin');
    if(codigoOfertaConsultiva != null){
        //segmentoOferta = JSON.parse(segmentoOferta).ofertas[0].orcamento.segmento;
        codigoOfertaConsultiva = JSON.parse(codigoOfertaConsultiva).consultivo.codigoOfertaConsultiva;
        if(codigoOfertaConsultiva == 'APTLMK'){        
            //Oculta aassinatura eletronica
            document.querySelector('#blocoAssinaturaEletronica').classList.add('hidden');
            //Manipula valor assinatura eletronica
            document.querySelector('#blocoAssinaturaEletronica').value = 'NAO';
        }
    }
}
//TKCL-240 FIM

function formatacaoFormularioPortoVidaON1(){
    let codigoOfertaConsultiva = window.localStorage.getItem('jsonEntradaCalculo');
    if(codigoOfertaConsultiva != null){
        codigoOfertaConsultiva = JSON.parse(codigoOfertaConsultiva).consultivo.codigoOfertaConsultiva;
        if(codigoOfertaConsultiva == 'VIAGEM_VIDA_ON'){

            //Carrega o CPF OK
            //AV-564 INICIO
            let CPF = JSON.parse(window.localStorage.getItem('jsonEntradaCalculo'));
            let arrayLength = CPF.consultivo.respostas.length;
            console.log('arrayLength', arrayLength);
            for(i = 0; i < arrayLength; i++){  
                if(CPF.consultivo.respostas[i].id == 'DICIO_CPFVOUCHER') {
                    CPF = CPF.consultivo.respostas[i].conteudo;
                    break
                }
            }
            document.querySelector('.cpfMask').value = CPF;
            //AV-564 FIM
            document.querySelector('.cpfMask').classList.add('disabled');

            //Esconde o campo de corretagem OK

            let campoCorretagem = document.querySelector('#DICIO_CORRETAGEM');
            campoCorretagem.classList.add('hidden');
            campoCorretagem.labels[0].innerHTML = '';
            document.querySelector('#DICIO_CORRETAGEM').value = '5';

            //esconde os pagamentos 
            document.querySelector(`.formapagamento`).classList.add('hidden');;
            document.querySelector(`#TIPOPAGAMENTO`).required = false;

            //esconde os corretores 
            document.querySelector('.listacorretores').classList.add('hidden');


            //Manipula os campos motocicleta e aventura

            document.querySelector('#DICIO_MOTOCICLETA').value = 'NAO';
            document.querySelector('#DICIO_AVENTURA').value = 'NAO';
        }
    }
}

function formatacaoFormularioPortoVidaON2(){
    let codigoOfertaConsultiva = window.localStorage.getItem('jsonEntradaCalculo');
    if(codigoOfertaConsultiva != null){
        codigoOfertaConsultiva = JSON.parse(codigoOfertaConsultiva).consultivo.codigoOfertaConsultiva;
        if(codigoOfertaConsultiva == 'VIAGEM_VIDA_ON'){
            document.querySelector('#DICIO_MOTOCICLETA').parentElement.classList.add('hidden');
            document.querySelector('#DICIO_AVENTURA').parentElement.classList.add('hidden');
        }
        //AV-428 INICIO
        if(codigoOfertaConsultiva == 'VIDA_ON'){

            //Oculta o campo de corretagem OK

            let campoCorretagem = document.querySelector('#DICIO_CORRETAGEM');
            campoCorretagem.classList.add('hidden');
            campoCorretagem.labels[0].innerHTML = '';
            document.querySelector('#DICIO_CORRETAGEM').value = '5';

            // Oculta o bloco de endereço comercial
            let blocoEndComercial = document.getElementById('BLOCOENDCOMERCIAL');
            blocoEndComercial.style.display = 'none';

            // Oculta o bloco de beneficiários
            let blocoBeneficiarios = document.getElementById('BLOCOBENEFICIARIOS');
            blocoBeneficiarios.style.display = 'none';

            // Manipula o valor de beneficiário
            document.querySelector('#BENEFICIARIOS').value = 'Herdeiros legais, conforme artigo 792 do código civil.';

            // Torna obrigatório o pais residente
            //if(document.querySelector('#RESIDE_BRASIL').value == 'NÃO')
            //document.querySelector('#PAISRESIDENTE').required = true;
            

            //Oculta os corretores 
            document.querySelector('.listacorretores').classList.add('hidden');
            document.querySelector('.blocoRemuneracao').classList.add('hidden');

            //Manipula o campo de assinatura eletrônica
            document.querySelector('#blocoAssinaturaEletronica').value = 'NAO';
            
            //Oculta assinatura eletrônica
            document.querySelector('#blocoAssinaturaEletronica').classList.add('hidden');
            
            //AV-501 INICIO
            //Manipula e oculta o campo de regime de trabalho 
            document.querySelector('#DICIO_REGIME_TRABALHO').value = 'CLT';
            document.querySelector('#DICIO_REGIME_TRABALHO').classList.add('hidden');
            document.querySelector('#DICIO_REGIME_TRABALHO').parentElement.classList.add('hidden');

            //Manipula e oculta o campo de fumante
            document.querySelector('#BLOCOFUMANTE').classList.add('hidden');
        
            //AV-501 FIM
        }
        //AV-428 FIM
    }
}
//AV-85 - FIM

// PLV-5441 - INICIO
document.addEventListener('DOMContentLoaded', () => {
    const getDados = () => {
        try {
            // inicial
            const dadosProposta = JSON.parse(window.localStorage.getItem('dadosProposta'));

            // atualizado
            const dadosUsuarioRaw = window.localStorage.getItem('dadosUsuario');
            const dadosUsuario = !!dadosUsuarioRaw ? JSON.parse(dadosUsuarioRaw).filter((dado) => dado.id !== 'DICIO_RENDA') : [];
            dadosUsuario.forEach(({ id, conteudo }) => {
                Object.assign(dadosProposta, { [id]: conteudo});
            });
            return Object.entries(dadosProposta).map(([id, value]) => ({ id, value }));
        } catch {
            return [];
        }
    }

    // PLV-5477 - INICIO
    const formatEstadoCivil = (estado) => {
        switch (estado) {
            case 'Casado (a)':
                return 'CASADO';
            case 'Divorciado(a)':
                return 'DIVORCIADO';
            case 'Solteiro (a)':
                return 'SOLTEIRO';
            case 'União estável':
                return 'VIVEMARITALMENTE';
            case 'Viúvo(a)':
                return 'VIUVO';
            case 'Separado(a)':
                return 'DIVORCIADO';
            case 'Desquitado(a)':
                return 'DESQUITADO';
            case 'Vive maritalmente':
                return 'VIVEMARITALMENTE';
            case 'Não informado':
            default:
                return '0';
        }
    };
    // PLV-5477 - FIM

    const setValue = (id, value) => {
        if (value === null) return;

        const removeAcento = (text) => {
            text = text.toLowerCase();                                                         
            text = text.replace(new RegExp('[ÁÀÂÃ]','gi'), 'a');
            text = text.replace(new RegExp('[ÉÈÊ]','gi'), 'e');
            text = text.replace(new RegExp('[ÍÌÎ]','gi'), 'i');
            text = text.replace(new RegExp('[ÓÒÔÕ]','gi'), 'o');
            text = text.replace(new RegExp('[ÚÙÛ]','gi'), 'u');
            text = text.replace(new RegExp('[Ç]','gi'), 'c');
            return text;                 
        }
        console.log(id, value);
        const element = document.getElementById(id);
        if (!!element) {
            console.log("Elemento existe");
            element.value = value;
            // Aplicar formatação das máscaras
            element.dispatchEvent(new KeyboardEvent('keyup', {'key': ''}));
            if (['TIPOENDERECORESPFIN', 'grauParentescoBeneficiario', 'TIPOEMPRESA', 'RESIDE_BRASIL'].includes(id)) return; // PLV-5477 - INICIO/FIM PLV-5475 - INICIO/FIM

            if (element.tagName === 'SELECT') {
                console.log(id);
                switch (id) {
                    case 'ESTADOCIVIL':
                        value = formatEstadoCivil(value);
                        break;
                }


                value = removeAcento(value).toUpperCase();
                element.M_FormSelect._handleSelectChangeBound();
                element.querySelector('option[value="' + value + '"]').setAttribute('selected', 'selected');
                element.querySelector('option[value="' + value + '"]').removeAttribute('disabled');
            }
        }
    }

    const dados = getDados();

    // yyyy-mm-dd => dd/mm/yyyy
    function formatDate(date) {
        const dateArray = date.split("-");
        return `${dateArray[2]}/${dateArray[1]}/${dateArray[0]}`
    }

    // PLV-5477 - INICIO
    const hideResponsavelFields = (hide) => {
        const responsavelContainer = document.getElementsByClassName('respfin')[0];
        if (hide) {
            responsavelContainer.classList.add('hidden');
        }
        else {
            responsavelContainer.classList.remove('hidden');
        }
    }

    const setResponsavel = (value) => {
        const responsavel = value === 'true';
        hideResponsavelFields(responsavel);
        const [sim, nao] = document.getElementsByName('RESPFINANCEIRO');
        if (responsavel) {
            sim.checked = true;
            nao.checked = false;
        } else {
            sim.checked = false;
            nao.checked = true;
        }
    }
    // PLV-5477 - FIM

    // PLV-5475 - INICIO
    const setBeneficiario = (beneficiarios) => {
        const addButton = document.querySelector('a.addBeneficiario');
        const element = document.getElementById('BENEFICIARIOS');
        beneficiarios.forEach((beneficiario) => {
            if (beneficiario.DICIO_BENEFTIPO === "Herdeiros legais, conforme artigo 792 do código civil.") {
                element.value = 'Herdeiros legais, conforme artigo 792 do código civil.';
                return;
            }
            const containerBeneficiarios = document.getElementsByClassName('listaBeneficiarios cliente')[0];
            element.value = 'Nome do beneficiário';
            containerBeneficiarios.classList.add('on');

            setValue('nomeBeneficiario', beneficiario.DICIO_BENEFNOME);
            setValue('cpfBeneficiario', beneficiario.DICIO_BENEFCPF);
            setValue('nascimentoBeneficiario', formatDate(beneficiario.DICIO_BENEFDATA));
            setValue('sexoBeneficiario', beneficiario.DICIO_BENEFSEXO);
            setValue('grauParentescoBeneficiario', beneficiario.DICIO_BENEFPAREN);
            setValue('percentualBeneficio', beneficiario.DICIO_BENEFPERCEN);
            const sim = document.getElementById('imprimirApoliceSim');
            const nao = document.getElementById('imprimirApoliceNao');
            if (beneficiario.DICIO_BENEFIMPRIMI === "true") {
                sim.click();
            } else {
                nao.click();
            }
            addButton.click();
        });

        

    }
    // PLV-5475 - FIM

    const setCnpjMei = (type, value) => {
      switch (type.toLowerCase()) {
        case "cnpj":
          setValue("CNPJEMPRESA", value);
          break;
        case "mei":
          setValue("MEIEMPRESA", value);
          break;
      }

      const tipoEmpresaElement = document.getElementById("TIPOEMPRESA");
      tipoEmpresaElement.value = type.toLowerCase();
      tipoEmpresaElement.dispatchEvent(new Event("change"));
    };

    // PLV-5636 - INICIO
    const setAgenciamento = (value) => {
        const id = 'AGENCIAMENTO_PARA';
        const option = value === 'Agenciador' ? 'AGENCIADOR' : 'CORRETOR';
        setValue(id, option);
        const element = document.getElementById(id);

        if (!!element) {
            element.dispatchEvent(new Event('change'));
        }
    }
    // PLV-5636 - FIM

    dados.forEach(({id, value}) => {
        if (!value) return;

        switch (id) {
            case 'DICIO_RESIDEBRASIL':
                console.log('--------reside brasil');
                setValue('RESIDE_BRASIL', value.toUpperCase());
                break;
            case 'DICIO_RENDA':
                setValue('RENDAMENSAL', value.replace('.', ','));
                break;
            case 'DICIO_PAIS':
                setValue('PAISRESIDENTE', value);
                break;
            case 'DICIO_ORGAOEXPEDIDOR':
                setValue('ORGAOEMISSOR', value);
                break;
            case 'DICIO_ESTADOCIVIL':
                setValue('ESTADOCIVIL', value);
                break;
            case 'DICIO_EMPRESA':
                setValue('EMPRESATRABALHO', value);
                break;
            case 'DICIO_DOCIDENTIFICACAO':
                setValue('NUMERODOCUMENTO', value);
                break;
            case 'DICIO_DATAEXPEDICAO':
                setValue('DATAEXPEDICAO', formatDate(value));
                break;
            case 'DICIO_CPF':
                setValue('CPF', value);
                break;
            case 'DICIO_ENDERECORES_CEP':
                setValue('CEPCLIENTE', value);
                break;
            case 'DICIO_ENDERECORES_BAIRRO':
                setValue('BAIRROCLIENTE', value);
                break;
            case 'DICIO_ENDERECORES_NUMERO':
                setValue('NUMEROCLIENTE', value);
                break;
            case 'DICIO_ENDERECOCOM_NUMERO':
                setValue('NUMEROCOMERCIAL', value);
                break;
            case 'DICIO_ENDERECORES_LOGRADOURO':
                setValue('LOGRADOUROCLIENTE', value);
                break;
            case 'DICIO_ENDERECOCOM_LOGRADOURO':
                setValue('LOGRADOUROCOMERCIAL', value);
                break;
            case 'DICIO_ENDERECOCOM_COMPLEMENTO':
                setValue('COMPLEMENTO', value);
                break;
            case 'DICIO_ENDERECORES_CIDADE':
                setValue('CIDADECLIENTE', value);
                break;
            case 'DICIO_ENDERECOCOM_CIDADE':
                setValue('CIDADECOMERCIAL', value);
                break;
            case 'DICIO_ENDERECOCOM_CEP':
                setValue('CEPCOMERCIAL', value);
                break;
            case 'DICIO_ENDERECOCOM_BAIRRO':
                setValue('BAIRROCOMERCIAL', value);
                break;
            case 'DICIO_EMAIL':
                setValue('EMAIL', value);
                setValue('EMAILCONFIRMATION', value);
                break;
            case 'DICIO_CELULAR':
                setValue('CELULARCLIENTE', value);
                break;
            case 'DICIO_ENDERECORES_ESTADO':
                setValue('ESTADOCLIENTE', value);
                break;
            case 'DICIO_ENDERECOCOM_ESTADO':
                setValue('ESTADOCOMERCIAL', value);
                break;
            case 'DICIO_TELEFONERES':
                setValue('TELEFONECLIENTE', value);
                break;
            // PLV-5477 - INICIO
            case 'DICIO_RESPONSAVEL':
                setResponsavel(value);
                break;
            case 'DICIO_RESPONSAVELNAME':
                setValue('NOMERESP', value);
                break;
            case 'DICIO_RESPONSAVELCPF':
                setValue('CPFRESP', value);
                break;
            case 'DICIO_RESPONSAVELVINCULO':
                setValue('VINCULORESP', value);
                break;
            case 'DICIO_RESPONSAVELSEXO':
                setValue('SEXORESP', value);
                break;
            case 'DICIO_RESPONSAVELDATA':
                setValue('DTNASCRESP', formatDate(value));
                break;
            case 'DICIO_RESPONSAVELCIVIL':
                setValue('ESTADOCIVILRESP', formatEstadoCivil(value));
                break;
            case 'DICIO_RESPONSAVELEMAIL':
                setValue('EMAILRESPFIN', value);
                setValue('EMAILCONFIRMATIONRESPFIN', value);
                break;
            case 'DICIO_RESPONSAVELCEP':
                setValue('CEPRESPFIN', value);
                break;
            case 'DICIO_RESPONSAVELTIPO':
                setValue('TIPOENDERECORESPFIN', value);
                break;
            case 'DICIO_RESPONSAVELRUA':
                setValue('LOGRADOURORESPFIN', value);
                break;
            case 'DICIO_RESPONSAVELESTADO':
                setValue('ESTADORESPFIN', value);
                break;
            case 'DICIO_RESPONSAVELCIDADE':
                setValue('CIDADERESPFIN', value);
                break;
            case 'DICIO_RESPONSAVELTELEFONE1':
                setValue('CELULARRESPFIN', value);
                break;
            case 'DICIO_RESPONSAVELTELEFONE2':
                setValue('TELEFONERESPFIN', value);
                break;
            case 'DICIO_RESPONSAVELTELEFONE3':
                setValue('TELOPCIONALRESPFIN', value);
                break;
            case 'DICIO_RESPONSAVELBAIRRO':
                setValue('BAIRRORESPFIN', value);
                break;
            case 'DICIO_RESPONSAVELNUMERO':
                setValue('NUMERORESPFIN', value);
                break;
            // PLV-5477 - FIM
            // PLV-5475 - INICIO
            case 'DICIO_LSTBENEF':
                setBeneficiario(value);
                break;
            // PLV-5475 - FIM
            case 'DICIO_RAMOATIVIDADE':
                setValue('RAMOEMPRESA', value);
                break;
            case 'DICIO_TIPOEMPRESA':
                setValue('TIPOEMPRESA', value);
                break;
            case 'DICIO_CNPJMEI':
                const tipoEmpresa = dados.find(d => d.id === "DICIO_TIPOEMPRESA").value;
                setCnpjMei(tipoEmpresa, value);
                break;
            case 'DICIO_QTDFUNCIONARIOS':
                setValue('QTDFUNCIONARIOS', value);
                break;
            // PLV-5636 - INICIO
            case 'DICIO_NOME_AGENCIADOR':
                setValue('NOME_AGENCIADOR', value);
                break;
            case 'DICIO_CPF_AGENCIADOR':
            case 'DICIO_CNPJ_AGENCIADOR':
                setValue('CPF_AGENCIADOR', value);
                const searchAgenciadorButton = document.getElementById('btn_busca_agenciador');
                if (!!searchAgenciadorButton) {
                    searchAgenciadorButton.click();
                }
                break;
            case 'DICIO_CODIGOAGENCIADOR':
                setValue('CODIGO_AGENCIADOR', value);
                break;
            case 'DICIO_SUSEPAGENCIADOR':
                setValue('SUSEP_AGENCIADOR', value);
                break;
            case 'DICIO_TIPOREMUNERACAO':
                setAgenciamento(value);
                break;
            // PLV-5636 - FIM
        }
    });

    if (dados.length) {
        M.updateTextFields();
    }
});
// PLV-5441 - FIM

// PLV-5478 - INICIO
document.addEventListener('DOMContentLoaded', () => {
  const entradaConsultivo = JSON.parse(window.localStorage.getItem('entradaConsultivo'));
  const segmentoQuest = window.localStorage.getItem('segmento'); //RVI-209 INICIO/FIM
  if (segmentoQuest !== 'Individual') return;  //RVI-209 INICIO/FIM

  const numOfertaSelecionada = localStorage.getItem('ofertaSelecionada');
  const jsonResponseCalculo = JSON.parse(
    localStorage.getItem('jsonResponseCalculo')
  );
  if (!numOfertaSelecionada || !jsonResponseCalculo) return;
  const mostrarQuestionario = jsonResponseCalculo.ofertas.some(
    (oferta) =>
      oferta.orcamento.numeroOrcamento === numOfertaSelecionada &&
      oferta.retornoAceitacao.decisoes.some(
        (decisao) => decisao.acao === 'auto'
      )
  );

  if (mostrarQuestionario) {
    const switchQuestionarioCorretor = document.getElementById(
      'switchQuestionarioCorretor'
    );
    const blockCelularCorretor = document.getElementsByClassName(
      'blockCelularCorretor'
    );
    const obsQuestionario = document.getElementsByClassName('obsQuestionario');
    const celularCliente = document.getElementById('CELULARCLIENTE');
    const celularCorretor = document.getElementById('CELULARCORRETOR');
    const naoEsquecaCorretor = document.getElementsByClassName('naoEsquecaCorretor');

    document.querySelectorAll('.relCorretor').forEach(function (el) {
      el.classList.remove('hidden');
    });

    switchQuestionarioCorretor.addEventListener('change', (e) => {
      if (e.currentTarget.checked) {
        blockCelularCorretor[0].classList.remove('disabled');
        obsQuestionario[0].classList.remove('hidden');
        celularCorretor.nextElementSibling.classList.add('hidden');
        naoEsquecaCorretor[0].classList.remove('hidden');
        celularCorretor.value = celularCliente.value;
      } else {
        blockCelularCorretor[0].classList.add('disabled');
        obsQuestionario[0].classList.add('hidden');
        naoEsquecaCorretor[0].classList.add('hidden');
        celularCorretor.nextElementSibling.classList.remove('hidden');
        celularCorretor.value = '';
      }
    });

    celularCliente.addEventListener('blur', (event) => {
        if (switchQuestionarioCorretor.checked) {
            celularCorretor.value = event.target.value;
        }
    });

    switchQuestionarioCorretor.dispatchEvent(new Event('change'));
  }
});
// PLV-5478 - FIM

//PLV-5447 INICIO
document.addEventListener('DOMContentLoaded', () => {
  const entradaConsultivo = JSON.parse(window.localStorage.getItem('entradaConsultivo'));
  if (entradaConsultivo.consultivo.codigoOfertaConsultiva !== 'VIDA_INDIVIDUAL') return;

  function assinaturaEletronica5447(mostrar) {
    const blocoAssinaturaEletronica = document.getElementById(
      'blocoAssinaturaEletronica'
    );
    const inputAssinaturaEletronica = document.querySelectorAll(
      '#blocoAssinaturaEletronica input'
    );
    const labelAssinaturaEletronica = document.querySelectorAll(
      '#blocoAssinaturaEletronica span'
    );
    if (
      blocoAssinaturaEletronica &&
      inputAssinaturaEletronica &&
      labelAssinaturaEletronica
    ) {
      if (mostrar === false) {
        blocoAssinaturaEletronica.classList.add('hidden');
        inputAssinaturaEletronica[1].click();
      } else {
        blocoAssinaturaEletronica.classList.remove('hidden');
        inputAssinaturaEletronica[0].click();
        labelAssinaturaEletronica[0].innerHTML = 'Assinatura Eletrônica';
        labelAssinaturaEletronica[1].innerHTML = 'Assinatura Manual';
      }
    }
  }

  if (document.querySelectorAll('.termoguarda:not(.hidden)').length > 0) {
    const termoGuarda = document.querySelectorAll('.termoguarda input');
    if (termoGuarda.length) {
      termoGuarda.forEach(function (termo) {
        termo.addEventListener('change', (e) => {
          e.currentTarget.value === 'Sim'
            ? assinaturaEletronica5447(false)
            : assinaturaEletronica5447(true);
        });
        termo.dispatchEvent(new Event('change'));
      });
    }
  } else {
    assinaturaEletronica5447(true);
  }
});
//PLV-5447 FIM

// PLV-5643 INICIO
document.addEventListener('DOMContentLoaded', () => {
  const entradaConsultivo = JSON.parse(
    window.localStorage.getItem('entradaConsultivo')
  );
  const dadosProposta = JSON.parse(
    window.localStorage.getItem("dadosProposta")
  );
  if (
    entradaConsultivo.consultivo.codigoOfertaConsultiva !== "VIDA_INDIVIDUAL" ||
    !dadosProposta
  )
    return;
  const nome = document.getElementById('DICIO_NOME');
  const cpf = document.getElementById('CPF');
  const dataNascimento = document.getElementById('DICIO_DATANASCIMENTO');
  const switchReaproveitarAssinatura = document.querySelectorAll(
    'input[name="switchReaproveitarAssinatura"]'
  );
  const reaproveitarAssinatura = document.getElementsByClassName(
    'reaproveitarAssinatura'
  );
  const btnPortoSuccess = document.querySelectorAll(
    '#formProposta .rodape-resumo-fixo .btnPortoSuccess'
  )[0];
  const total = document.querySelector('#formProposta .total .investimento');
  const propostaAnterior = document.querySelector(
    '#formProposta .reaproveitarAssinatura .propostaAnterior'
  );

  switchReaproveitarAssinatura.forEach(function (assinatura) {
    assinatura.addEventListener('change', (e) => {
      if (e.currentTarget.checked) {
        if (e.currentTarget.value === 'true') {
          propostaAnterior.classList.remove('hidden');
        } else {
          propostaAnterior.classList.add('hidden');
        }
      }
    });
  });

  const showReaproveitarAssinatura = () => {
    if (
        dadosProposta.DICIO_REAPROVEITAR_ASSINATURA === 'true' &&
        parseFloat(dadosProposta.DICIO_TOTAL).toString().replace(/\D/g, '') ===
          total.innerHTML.replace(/\D/g, '') &&
        nome.value === dadosProposta.DICIO_NOME &&
        cpf.value === dadosProposta.DICIO_CPF &&
        dataNascimento.value === formatDate(dadosProposta.DICIO_DATANASCIMENTO)
      ) {
        switchReaproveitarAssinatura[0].checked = true;
        reaproveitarAssinatura[0].classList.remove('hidden');
        propostaAnterior.classList.remove('hidden');
        propostaAnterior.innerHTML =
          'Estou de acordo com as condições e reaproveitando a assinatura da proposta ' +
          dadosProposta.DICIO_ORIGEM +
          ' (anterior)';
      } else {
        switchReaproveitarAssinatura[1].checked = true;
        reaproveitarAssinatura[0].classList.add('hidden');
      }
  }

  total.addEventListener('DOMSubtreeModified', showReaproveitarAssinatura);
  cpf.addEventListener('change', showReaproveitarAssinatura);
  nome.addEventListener('change', showReaproveitarAssinatura);

  total.dispatchEvent(new Event('DOMSubtreeModified'));
});
// PLV-5643 FIM