import { CommonModule } from '@angular/common';
import { ChangeDetectionStrategy, Component, OnInit, signal } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { ReactiveFormsComponent } from './components/forms/reactive-forms/reactive-forms.component';
import { TemplateDrivenFormsComponent } from './components/forms/template-driven-forms/template-driven-forms.component';
import { ContentComponent } from './components/content/content.component';
import { HostElementsComponent } from './components/host-elements/host-elements.component';
import { LifeCycleComponent } from './components/life-cycle/life-cycle.component';
import { HomeComponent } from "./modules/portfolio/pages/home/home.component";

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
    HomeComponent
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

    <button (click)="boolean = !boolean">Destroy Component</button>-->
    <app-home />
  `,  
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class AppComponent implements OnInit{
  public myNumber = signal(0);
  public boolean = true;

  ngOnInit(): void {
     setInterval(() => {
      this.myNumber.update((oldValue) => {
        return oldValue + 1;
      })
    }, 1000);
  }
}
