import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { NewComponent } from './components/new-component/new.component';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, NewComponent],
  template: `
    <h2>Curso de Angular</h2>
      <div class="dark-theme">
      <app-new-component />
    </div>
  `
})
export class AppComponent {
  title = 'meu-primeiro-projeto-latest';
}
