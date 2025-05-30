import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { ReactiveFormsComponent } from './components/forms/reactive-forms/reactive-forms.component';
import { TemplateDrivenFormsComponent } from './components/forms/template-driven-forms/template-driven-forms.component';
import { ContentComponent } from './components/content/content.component';
import { HostElementsComponent } from './components/host-elements/host-elements.component';
import { LifeCycleComponent } from './components/life-cycle/life-cycle.component';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [
    CommonModule,
    RouterOutlet,
    ReactiveFormsComponent,
    TemplateDrivenFormsComponent,
    ContentComponent,
    HostElementsComponent,
    LifeCycleComponent,
  ],
  template: `
    <h1>Curso de Angular</h1>
    <!--<app-template-driven-forms />-->
    <!--<app-content>
      <header id="header">
        <p>header</p>
      </header>
      <p text>Text</p>
      <footer class="footer">
        <p>Class footer</p>
      </footer>
      <p text>Text</p>
    </app-content>
    <app-host-elements />-->
    <app-life-cycle [number]="addFatherNumber()" />
  `,
})
export class AppComponent {
  public myNumber = 0;

  public addFatherNumber() {
    setInterval(() => {
      this.myNumber++;
    }, 2000);

    return this.myNumber;
  }
}
