trigger EventTrigger on Event (Before Delete) {
    
    for(Event e : trigger.old){
        
        List<String> lBlockedProfiles = new List<String>();
        lBlockedProfiles.add('Administrador Porto');
        lBlockedProfiles.add('Sinistro e Benefícios');
        lBlockedProfiles.add('Processos e Projetos');

        
        String perfil = UserInfo.getProfileId();
        
        Profile p = [SELECT Id, Name FROM Profile WHERE Id =: perfil];
        
        String nomePerfil = p.Name;
        
        if(lBlockedProfiles.contains(nomePerfil))
        	e.adderror('Você não pode deletar Compromissos');
    }
    
}