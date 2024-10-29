const gerarMensagemDeErro = (error) => {
    let mensagem = undefined;
    if (error) {
        if (Array.isArray(error?.body)) {
            mensagem = error?.body?.map(e => e?.message).join(',');
        } else if (typeof error?.body?.message === 'string') {
            mensagem = error.body.message;
        } else if (error?.message) {
            mensagem = error.message;
        }
    }
    return mensagem;
}
export { gerarMensagemDeErro }