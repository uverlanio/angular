import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { TemplateDrivenFormsComponent } from './components/forms/template-driven-forms/template-driven-forms.component';
import { ContentComponent } from './components/content/content.component';
import { HostElementsComponent } from './components/host-elements/host-elements.component';
import { LifeCycleComponent } from './components/life-cycle/life-cycle.component';
import { ReactiveFormsComponent } from '@components/forms/reactive-forms/reactive-forms.component';
import { ConsumeServiceComponent } from "./components/consume-service/consume-service.component";
import { TranslateComponent } from '@components/translate/translate.component';
import { OptImageComponent } from '@components/opt-image/opt-image.component';
import { AnimationsComponent } from '@components/animations/animations.component';

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
    ConsumeServiceComponent,
    TranslateComponent,
    OptImageComponent,
    AnimationsComponent
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
    <app-host-elements />
    
    @if(boolean){
      <app-life-cycle [inputMyNumber]="myNumber()">
        <p #text>Text</p>
      </app-life-cycle>
    } 

    <button (click)="boolean = !boolean">Destroy Component</button>
    <app-consume-service />
    <app-translate />
    <app-opt-image />-->
    <app-animations />
  `,  
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class AppComponent {

  constructor(){}
  
}
