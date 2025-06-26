import { CanDeactivateFn } from '@angular/router';
import ServicosPrestadoComponent from 'app/pages/servicos-prestado/servicos-prestado.component';

export const canDeactivateGuard: CanDeactivateFn<ServicosPrestadoComponent> = (component, currentRoute, currentState, nextState) => {
  
  console.log(component.getId())

  if(component.form.get('name')?.dirty){
    return confirm('Você deseja sair?');
  }
  
  return true;
};
