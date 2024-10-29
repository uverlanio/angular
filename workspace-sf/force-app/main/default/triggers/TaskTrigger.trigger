trigger TaskTrigger on Task (Before Delete) {
    
    for(Task t : trigger.old){
        
        String perfil = UserInfo.getProfileId();
        
        Profile p = [SELECT Id, Name FROM Profile WHERE Id =: perfil];
        
        List<String> lBlockedProfiles = new List<String>();
        lBlockedProfiles.add('Administrador Porto');
        lBlockedProfiles.add('Sinistro e Benefícios');
        lBlockedProfiles.add('Processos e Projetos');
        
        String nomePerfil = p.Name;
        
        if(lBlockedProfiles.contains(nomePerfil))
        	t.adderror('Você não pode deletar tarefas');
    }

}