import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { ReactiveFormsComponent } from './components/forms/reactive-forms/reactive-forms.component';
import { TemplateDrivenFormsComponent } from './components/forms/template-driven-forms/template-driven-forms.component';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [
    CommonModule,
    RouterOutlet,
    ReactiveFormsComponent,
    TemplateDrivenFormsComponent,
  ],
  template: ` <h1>Curso de Angular</h1>
    <!--<app-template-driven-forms />-->
    <app-reactive-forms />
    `,
})
export class AppComponent {}
