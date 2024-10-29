({
	toggleSecao : function(component, event) {
		let conteudoSecao = component.find("conteudoSecao");
		$A.util.toggleClass(conteudoSecao, "hide");
	}
})