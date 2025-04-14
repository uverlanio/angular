import { Component } from '@angular/core';
import { NewComponent } from './components/new-component/new.component';
import { CommonModule } from '@angular/common';
import { TemplateBindingComponent } from './components/template/template-binding/template-binding.component';
import { TemplateVariablesComponent } from './components/template/template-variables/template-variables.component';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule, NewComponent, TemplateBindingComponent, TemplateVariablesComponent],
  styles: ``,
  template: `
    <h2>Curso de Angular</h2>
    <app-template-binding />
    <app-template-variables />
  `
})
export class AppComponent {
  title = 'meu-primeiro-projeto-latest';
}
